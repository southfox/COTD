//
//  COTDParse.m
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "COTDParse.h"
#import <Parse/Parse.h>
#import "COTDImage.h"
#import "COTDUserImage.h"
#import "NSError+COTD.h"
#import "NSDate+COTD.h"



NSString *const COTDParseServiceQueryDidFinishNotification = @"COTDParseServiceQueryDidFinishNotification";

@interface COTDParse()

@property (nonatomic) BOOL isUpdating;
@property (nonatomic) NSArray *images;
@property (nonatomic) NSArray *userImages;
@end

@implementation COTDParse

- (void)dealloc
{
    for (NSValue *imageObject in self.userImages)
    {
        COTDUserImage *userImage = (COTDUserImage *)[imageObject pointerValue];
        delete userImage;
    }
    for (NSValue *imageObject in self.images)
    {
        COTDImage *image = (COTDImage *)[imageObject pointerValue];
        delete image;
    }
}

+ (COTDParse *)sharedInstance
{
    static COTDParse *_sharedInstance = nil;
    
    @synchronized (self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [Parse setApplicationId:@"4w57EiBsbDCULkdlP5q1Q0R5bLPDupCbokbNT4KU" clientKey:@"0zDVtm3iDrB1mWEyg5860SFrLYpdsJMYbSFxLhBO"];
    }
    return self;
}

- (void)configureWithLaunchOptions:(NSDictionary *)launchOptions finishBlock:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    __weak typeof(self) wself = self;
    
    __block PFUser *user = [PFUser currentUser];
    __block void(^bfinishBlock)(BOOL succeeded, NSError *error) = finishBlock;

    void(^blockAfterSave)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error)
    {
        typeof(self) sself = wself;
        PFACL *defaultACL = [PFACL ACL];
        
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
        [sself querys:^(BOOL succeeded, NSError *error) {
            typeof(self) sself = wself;
            sself.isUpdating = NO;
            bfinishBlock(YES, nil);
        }];
    };
    
    if ([user username])
    {
        blockAfterSave(YES, nil);
    }
    else
    {
        [PFUser enableAutomaticUser];
        user = [PFUser currentUser];
        
        [user saveInBackgroundWithBlock:blockAfterSave];
    }
    
}


- (void)querys:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    if (self.isUpdating)
    {
        return;
    }
    __block void(^bfinishBlock)(BOOL succeeded, NSError *error) = finishBlock;
    
    self.isUpdating = YES;
    __weak typeof(self) wself = self;
    
    [wself queryImages:^(BOOL succeeded, NSError *error) {
        
        typeof(self) sself = wself;
        
        [sself queryUserImages:^(BOOL succeeded, NSError *error) {
            if (bfinishBlock)
            {
                bfinishBlock(succeeded, error);
            }

            sself.isUpdating = NO;
            NSValue *userImageObject = [self.userImages lastObject];
            if (userImageObject)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
            }
        }];
        
    }];
}

- (void)queryImages:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    PFQuery *query = [PFQuery queryWithClassName:@"COTDImage"];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            finishBlock(NO, error);
            return;
        }
        else
        {
            if (objects.count)
            {
                NSMutableArray* images = [NSMutableArray new];
                COTDImage *image = new COTDImage();
                for (PFObject *object in objects)
                {
                    image->setObjectId((std::string)[object.objectId UTF8String]);
                    image->setFullUrl((std::string)[object[@"fullUrl"] UTF8String]);
                    image->setLikes([object[@"likes"] intValue]);
                    [images addObject:[NSValue valueWithPointer:image]];
                }
                self.images = [NSMutableArray arrayWithArray:images];
                finishBlock(YES, nil);
            }
            else
            {
                finishBlock(NO, [NSError errorWithMessage:@"cannot get COTDImage"]);
            }
        }
    }];
}

- (void)queryUserImages:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    PFQuery *query = [PFQuery queryWithClassName:@"COTDUserImage"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            finishBlock(NO, error);
            return;
        }
        else
        {
            if (objects.count)
            {
                NSMutableArray* userImages = [NSMutableArray new];
                COTDUserImage *userImage = new COTDUserImage();
                for (PFObject *object in objects)
                {
                    if ([[object.createdAt formattedDate] isEqualToString:[[NSDate date] formattedDate]])
                    {
                        PFObject *image = object[@"image"];
                        userImage->setImage((char *)[image.objectId UTF8String]);
                        [userImages addObject:[NSValue valueWithPointer:userImage]];
                    }
                }
                self.userImages = [NSMutableArray arrayWithArray:userImages];
                finishBlock(YES, nil);
            }
            else
            {
                finishBlock(NO, [NSError errorWithMessage:@"cannot get COTDImage"]);
            }
        }
    }];
}


- (NSString *)currentUserImageUrl
{
    NSValue *userImageObject = [self.userImages lastObject];
    COTDUserImage *userImage = (COTDUserImage *)[userImageObject pointerValue];
    if (!userImage)
    {
        return nil;
    }
    NSString *imageUrlString = nil;
    for (NSValue *imageObject in self.images)
    {
        COTDImage *image = (COTDImage *)[imageObject pointerValue];
        if (image->getObjectId() == userImage->getImage())
        {
            imageUrlString = [NSString stringWithUTF8String:image->getFullUrl().c_str()];
            break;
        }
    }
    return imageUrlString;
}

- (void)changeUserImageUrl:(NSString *)imageUrl;
{
    std::string imageUrlString = [imageUrl UTF8String];
    NSString *imageObjectId = nil;
    for (NSValue *imageObject in self.images)
    {
        COTDImage *image = (COTDImage *)[imageObject pointerValue];
        if (image->getFullUrl() == imageUrlString)
        {
            imageObjectId = [NSString stringWithUTF8String:image->getObjectId().c_str()];
            break;
        }
    }
    if (imageObjectId)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"COTDImage"];
        [query getObjectInBackgroundWithId:imageObjectId
                                     block:^(PFObject *object, NSError *error) {
                                         [self changeImageInCurrentUser:object];
                                     }];

    }
    else
    {
        // Create a new image instance
        PFObject *image = [PFObject objectWithClassName:@"COTDImage"];
        image[@"fullUrl"] = imageUrl;
        image[@"likes"] = @(0);
        [image saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                // Assign the image instance into user image
                [image fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [self changeImageInCurrentUser:object];
                }];
            }
        }];
    }
}

- (void)changeImageInCurrentUser:(PFObject *)object
{
    PFObject *userImage = [PFObject objectWithClassName:@"COTDUserImage"];
    userImage[@"image"] = object;
    userImage[@"user"] = [PFUser currentUser];
    [userImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
    }];

}

@end
