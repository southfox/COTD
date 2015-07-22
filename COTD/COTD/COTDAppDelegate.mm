//
//  COTDAppDelegate.m
//  COTD
//
//  Created by Javier Fuchs on 7/20/15.
//  Copyright (c) 2015 relbane. All rights reserved.
//

#import "COTDAppDelegate.h"
#import "COTDParse.h"
#import "COTDGoogle.h"
#import "COTDAlert.h"

@interface COTDAppDelegate ()

@end

@implementation COTDAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    __weak typeof(self) wself = self;

    [[COTDParse sharedInstance] configureWithLaunchOptions:launchOptions finishBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"error = %@", error);
        }
        else
        {
            if (![[COTDParse sharedInstance] currentUserImageUrl])
            {
                typeof(self) sself = wself;

                [sself queryTerm];
            }
        }
    }];
    return YES;
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
            
            [COTDAlert alertWithFrame:sself.window.frame title:@"Error" message:error.description leftTitle:@"Retry" leftBlock:^{
                typeof(self) sself = wself;
                [sself queryTerm];
            } rightTitle:@"Close" rightBlock:^{
                exit(0);
            }];
        }
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
