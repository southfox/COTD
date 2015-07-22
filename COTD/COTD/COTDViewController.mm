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


@interface COTDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gridButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;

@end

@implementation COTDViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
