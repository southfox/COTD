//
//  COTDViewController.m
//  COTD
//
//  Created by Javier Fuchs on 7/20/15.
//  Copyright (c) 2015 relbane. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import "COTDViewController.h"
#import "UIView+COTD.h"
#import "COTDParse.h"
#import "COTDAlert.h"
#import "COTDGoogle.h"


@interface COTDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gridButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property (nonatomic) NSString *searchTerm;

@end

@implementation COTDViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UITapGestureRecognizer* tap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refineSearchAction)];
    [self.imageView addGestureRecognizer:tap];
    self.imageView.userInteractionEnabled = YES;

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleParseFinishNotification:) name:COTDParseServiceQueryDidFinishNotification object: nil];

    [self.view startSpinnerWithString:@"Loading..." tag:1];
    
}

- (void)handleParseFinishNotification:(NSNotification *)notification
{
    [self.view stopSpinner:1];
    
    NSString *imageUrl = [[COTDParse sharedInstance] currentUserImageUrl];
    self.title = [[COTDParse sharedInstance] currentUserSearchTerm] ? : @"Capybara";
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
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
    } leftTitle:@"Cancel" leftBlock:^{} rightTitle:@"Search" rightBlock:^{
        typeof(wself) sself = wself;
        [[COTDParse sharedInstance] changeCurrentUserSearchTerm:sself.searchTerm];
        [sself queryTerm];
    }];
}

- (void)queryTerm
{
    __weak typeof(self) wself = self;
    
    [[COTDGoogle sharedInstance] queryTerm:[[COTDParse sharedInstance] currentUserSearchTerm] excludeTerms:[[COTDParse sharedInstance] currentUserExcludeTerms] finishBlock:^(BOOL succeeded, NSString *link, NSString *title, NSError *error) {
        if (succeeded)
        {
            [[COTDParse sharedInstance] updateImage:link title:title searchTerm:nil];
        }
        else
        {
            typeof(self) sself = wself;
            
            [COTDAlert alertWithFrame:sself.view.frame title:@"Error" message:error.description leftTitle:@"Retry" leftBlock:^{
                typeof(self) sself = wself;
                [sself queryTerm];
            } rightTitle:@"Close" rightBlock:^{
                exit(0);
            }];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
