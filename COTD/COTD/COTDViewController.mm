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


@interface COTDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
