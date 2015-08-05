//
//  COTDViewController.m
//  COTD
//
//  Created by Javier Fuchs on 7/20/15.
//  Copyright (c) 2015 javierfuchs. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "COTDViewController.h"
#import "UIView+COTD.h"
#import "COTDParse.h"
#import "COTDAlert.h"
#import "COTDGoogle.h"
#import "COTDImage.h"

#define COTD @"Capybara of the Day"

@interface COTDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gridButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSArray *topTenArray;
@end

@implementation COTDViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridButton.enabled = NO;
    self.likeButton.enabled = NO;

    UITapGestureRecognizer* tap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refineSearchAction)];
    [self.imageView addGestureRecognizer:tap];
    self.imageView.userInteractionEnabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleParseFinishNotification:) name:COTDParseServiceQueryDidFinishNotification object: nil];

    __weak typeof(self) wself = self;
    
    [self.view startSpinnerWithString:@"Loading..." tag:1];
    [[COTDParse sharedInstance] topTenImages:^(NSArray *objects, NSError *error) {
        typeof(wself) sself = wself;
        sself.topTenArray = objects;
        sself.gridButton.enabled = (sself.topTenArray.count);
    }];
    

}

- (void)handleParseFinishNotification:(NSNotification *)notification
{
    NSString *imageUrl = [[COTDParse sharedInstance] currentUserImageUrl];
    self.likeButton.enabled = (imageUrl);
    self.title = [[COTDParse sharedInstance] currentUserSearchTerm] ? : COTD;
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    __weak typeof(self) wself = self;
    [[COTDParse sharedInstance] topTenImages:^(NSArray *objects, NSError *error) {
        typeof(wself) sself = wself;
        sself.gridButton.enabled = (!error && objects.count);
        [sself.view stopSpinner:1];
    }];
}


- (IBAction)buttonAction:(id)sender {
    if (sender == self.gridButton)
    {
        [self performSegueWithIdentifier:@"COTDMostLikedViewController" sender:self];
    }
    else if (sender == self.likeButton)
    {
        __weak typeof(self) wself = self;
        
        [COTDAlert alertWithFrame:self.view.frame
                            title:[[COTDParse sharedInstance] currentUserImageTitle]
                          message:@"Do you like this image?"
                        leftTitle:@"No" leftBlock:^{
                        } rightTitle:@"Yes" rightBlock:^{
                            typeof(wself) sself = wself;
                            [sself likeAction];
                        }];
    }
}

- (void)likeAction
{
    __weak typeof(self) wself = self;
    
    [self.view startSpinnerWithString:@"Liking..." tag:1];
    
    [[COTDParse sharedInstance] likeCurrentImage:^(BOOL succeeded, NSError *error) {
        typeof(wself) sself = wself;
        [sself.view stopSpinner:1];
        if (succeeded)
        {
            [COTDAlert alertWithFrame:sself.view.frame title:@"Congratulations" message:@"Successfull action" leftTitle:@"Ok" leftBlock:^{} rightTitle:nil rightBlock:nil];
            [sself handleParseFinishNotification:nil];
        }
        else
        {
            [COTDAlert alertWithFrame:sself.view.frame title:@"Error" message:error.description leftTitle:@"Retry" leftBlock:^{
                [sself likeAction];
            } rightTitle:@"Cancel" rightBlock:^{}];
        }
    }];
}

- (void)refineSearchAction
{
    __weak typeof(self) wself = self;

    NSString *searchTerm = [[COTDParse sharedInstance] currentUserSearchTerm];
    [COTDAlert alertWithFrame:self.view.frame prompt:@"Refine Search" placeholder:@"Add more text" value:searchTerm ?: nil textBlock:^(NSString *text) {
        typeof(wself) sself = wself;
        sself.searchTerm = text;
        [[COTDParse sharedInstance] changeCurrentUserSearchTerm:sself.searchTerm];
        [sself queryTerm];

    } leftTitle:@"Cancel" leftBlock:^{} rightTitle:@"Search" rightBlock:^{
        typeof(wself) sself = wself;
        [[COTDParse sharedInstance] changeCurrentUserSearchTerm:sself.searchTerm];
        [sself queryTerm];
    }];
}

- (void)queryTerm
{
    __weak typeof(self) wself = self;
    
    [self.view startSpinnerWithString:[NSString stringWithFormat:@"Searching [%@]...", self.searchTerm] tag:1];

    [[COTDGoogle sharedInstance] queryTerm:[[COTDParse sharedInstance] currentUserSearchTerm] start:[[COTDParse sharedInstance] currentStart] finishBlock:^(BOOL succeeded, NSString *link, NSString *thumbnailLink, NSString *title, NSError *error) {
        typeof(self) sself = wself;

        [sself.view stopSpinner:1];
        
        if (succeeded)
        {
            if (link)
            {
                if ([[COTDParse sharedInstance] isLinkRepeated:link])
                {
                    [COTDAlert alertWithFrame:sself.view.frame title:@"Warning" message:@"Result repeated. Random failed" leftTitle:@"Cancel" leftBlock:^{
                        
                    } rightTitle:@"Retry" rightBlock:^{
                        typeof(self) sself = wself;
                        [sself queryTerm];
                    }];
                }
                else
                {
                    [[COTDParse sharedInstance] updateImage:link thumbnailUrl:thumbnailLink title:title searchTerm:wself.searchTerm finishBlock:^(BOOL succeeded, COTDImage *image, NSError *error) {
                        typeof(self) sself = wself;
                        
                        if (succeeded)
                        {
                            if (!image)
                            {
                                [COTDAlert alertWithFrame:sself.view.frame title:@"Info" message:@"Cannot open image" leftTitle:@"Cancel" leftBlock:^{
                                    
                                } rightTitle:@"Retry" rightBlock:^{
                                    typeof(self) sself = wself;
                                    [sself queryTerm];
                                }];
                            }
                            else
                            {
                                NSString *imageUrl = [NSString stringWithUTF8String:image->getFullUrl().c_str()];
                                sself.likeButton.enabled = (imageUrl.length);
                                sself.title = sself.searchTerm ? : COTD;
                                [sself.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
                            }
                        }
                        else
                        {
                            [COTDAlert alertWithFrame:sself.view.frame title:@"Error" message:error
                             .description leftTitle:@"Cancel" leftBlock:^{
                                 
                             } rightTitle:@"Retry" rightBlock:^{
                                 typeof(self) sself = wself;
                                 [sself queryTerm];
                             }];
                            
                        }
                        
                    }];
                }
            }
            else
            {
                [COTDAlert alertWithFrame:sself.view.frame title:@"Info" message:@"No results" leftTitle:@"Cancel" leftBlock:^{
                    
                } rightTitle:@"Retry" rightBlock:^{
                    typeof(self) sself = wself;
                    [sself queryTerm];
                }];
            }
        }
        else
        {
            
            [COTDAlert alertWithFrame:sself.view.frame title:@"Error" message:error.description leftTitle:@"Cancel" leftBlock:^{
                
            } rightTitle:@"Retry" rightBlock:^{
                typeof(self) sself = wself;
                [sself queryTerm];
            }];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
