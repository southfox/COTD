//
//  COTDUserImage.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <Parse/Parse.h>

@class COTDImage;

@interface COTDUserImage : PFObject

@property (nonatomic) PFUser *user;
@property (nonatomic) COTDImage *image;

@end
