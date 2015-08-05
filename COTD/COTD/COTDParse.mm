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
@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray *userImages;
@property (nonatomic) NSString *searchTerm;
@end

@implementation COTDParse

- (void)dealloc
{
    for (NSValue *userImageObject in self.userImages)
    {
        COTDUserImage *userImage = (COTDUserImage *)[userImageObject pointerValue];
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
        self.userImages = [NSMutableArray array];
        self.images = [NSMutableArray array];
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
            if (succeeded)
            {
                typeof(self) sself = wself;
                sself.isUpdating = NO;
                bfinishBlock(YES, nil);
            }
            else
            {
                bfinishBlock(NO, error);
            }
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
//        user.ACL = [self postACL];
        [user saveInBackgroundWithBlock:blockAfterSave];
    }
    
}

- (PFACL *)postACL
{
    PFACL *postACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [postACL setPublicReadAccess:YES];
    [postACL setPublicWriteAccess:YES];
    return postACL;
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
    
    [wself queryImagesUsingLimit:1000 onlyLikes:NO finishBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            bfinishBlock(NO, error);
            return;
        }
        else
        {
            __strong typeof(wself) sself = wself;

            if (objects.count)
            {
                sself.images = [NSMutableArray new];
                for (PFObject *object in objects)
                {
                    COTDImage *image = new COTDImage([object.objectId UTF8String],
                                                     [object[@"fullUrl"] UTF8String],
                                                     [object[@"thumbnailUrl"] UTF8String],
                                                     [object[@"imageTitle"] UTF8String],
                                                     [object[@"likes"] intValue]);
                    [sself.images addObject:[NSValue valueWithPointer:image]];
                }
            }
            
            [sself queryUserImages:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    sself.isUpdating = NO;
                    COTDUserImage *userImage = [sself userImage];
                    if (userImage)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
                    }
                    else
                    {
                        // Not really an error, no user image, so create one
                        bfinishBlock(YES, nil);
                    }
                }
                else
                {
                    bfinishBlock(NO, error);
                }
            }];
        }
    }];
}

- (void)queryImagesUsingLimit:(int)limit onlyLikes:(BOOL)onlyLikes finishBlock:(void (^)(NSArray *objects, NSError *error))finishBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"COTDImage"];
    if (onlyLikes)
    {
        [query whereKey:@"likes" greaterThan:@(0)];
        [query orderByDescending:@"likes"];
    }
    query.limit = limit;
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [query findObjectsInBackgroundWithBlock:finishBlock];
}


- (void)queryUserImages:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    __block void(^bfinishBlock)(BOOL succeeded, NSError *error) = finishBlock;

    __weak typeof(self) wself = self;

    PFQuery *query = [PFQuery queryWithClassName:@"COTDUserImage"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    NSDate *aWeekAgo = [[self today] addDays:-7];
    [query whereKey:@"savedAt" greaterThanOrEqualTo:aWeekAgo];

    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error)
        {
            bfinishBlock(NO, error);
            return;
        }
        else
        {
            if (objects.count)
            {
                __strong typeof(self) sself = wself;

                sself.userImages = [NSMutableArray new];
                for (PFObject *object in objects)
                {
                    PFObject *image = object[@"image"];
                    std::string objectId = [image.objectId UTF8String];
                    NSDate *savedAt = object[@"savedAt"];
                    COTDUserImage *userImage = new COTDUserImage([image.objectId UTF8String], [[savedAt formattedDate] UTF8String]);
                    [sself.userImages addObject:[NSValue valueWithPointer:userImage]];
                }
            }
            bfinishBlock(YES, nil);
        }
    }];
}

- (void)likeCurrentImage:(void (^)(BOOL succeeded, NSError *error))finishBlock
{
    __block void(^bfinishBlock)(BOOL succeeded, NSError *error) = finishBlock;

    COTDUserImage *userImage = [self userImage];
    if (!userImage)
    {
        finishBlock(NO, [NSError errorWithMessage:@"Cannot identify image"]);
        return;
    }
    
    NSString *imageObjectId = [NSString stringWithFormat:@"%s", userImage->getImage().c_str()];
    
    if (imageObjectId)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"COTDImage"];
        [query getObjectInBackgroundWithId:imageObjectId
                                     block:^(PFObject *object, NSError *error) {
                                         if (!error)
                                         {
                                             object[@"likes"] = @([object[@"likes"] intValue] + 1);
                                             object.ACL = [self postACL];
                                             [object saveInBackgroundWithBlock:bfinishBlock];
                                         }
                                         else
                                         {
                                             bfinishBlock(NO, error);
                                         }
                                     }];
    }
    else
    {
        finishBlock(NO, [NSError errorWithMessage:@"Cannot get image from memory"]);
    }

}

- (COTDUserImage *)userImage
{
    std::string todayStr = [[[self today] formattedDate] UTF8String];
    COTDUserImage *userImage = nil;
    for (NSValue *userImageObject in self.userImages)
    {
        userImage = (COTDUserImage *)[userImageObject pointerValue];
        if (userImage->getSavedAt() == todayStr)
        {
            return userImage;
        }
    }
    return nil;
}

- (NSString *)currentUserImageTitle
{
    COTDUserImage *userImage = [self userImage];
    if (!userImage)
    {
        return nil;
    }
    NSString *imageTitle = nil;
    for (NSValue *imageObject in self.images)
    {
        COTDImage *image = (COTDImage *)[imageObject pointerValue];
        if (image->getObjectId() == userImage->getImage())
        {
            imageTitle = [NSString stringWithUTF8String:image->getImageTitle().c_str()];
            break;
        }
    }
    return imageTitle;
}

- (BOOL)isLinkRepeated:(NSString *)fullUrl
{
    std::string fullUrlString = [fullUrl UTF8String];
    for (NSValue *userImageObject in self.userImages)
    {
        COTDUserImage *userImage = (COTDUserImage *)[userImageObject pointerValue];

        for (NSValue *imageObject in self.images)
        {
            COTDImage *image = (COTDImage *)[imageObject pointerValue];
            if (image->getObjectId() == userImage->getImage())
            {
                if (image->getFullUrl() == fullUrlString)
                {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSString *)currentUserImageUrl
{
    COTDUserImage *userImage = [self userImage];
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


- (NSString *)currentUserSearchTerm
{
    return self.searchTerm;
}
- (void)changeCurrentUserSearchTerm:(NSString *)searchTerm;
{
    self.searchTerm = searchTerm;
}

- (NSUInteger)currentStart
{
    NSInteger num = self.userImages.count + self.images.count + 1;
    NSInteger r = num + arc4random()%15;
    return r;
}

- (void)updateImage:(NSString *)imageUrl thumbnailUrl:(NSString *)thumbnailUrl title:(NSString *)title searchTerm:(NSString *)searchTerm finishBlock:(void (^)(BOOL succeeded, COTDImage* image, NSError *error))finishBlock
{
    
    __block void(^bfinishBlock)(BOOL succeeded, COTDImage* image, NSError *error) = finishBlock;

    __weak typeof(self) wself = self;

    std::string imageUrlString = [imageUrl UTF8String];
    NSString *imageObjectId = nil;
    __block COTDImage *image = nil;
    for (NSValue *imageObject in self.images)
    {
        image = (COTDImage *)[imageObject pointerValue];
        if (image->getFullUrl() == imageUrlString)
        {
            imageObjectId = [NSString stringWithUTF8String:image->getObjectId().c_str()];
            break;
        }
    }
    if (image && imageObjectId)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"COTDImage"];
        [query getObjectInBackgroundWithId:imageObjectId
                                     block:^(PFObject *object, NSError *error) {
                                         if (object)
                                         {
                                             __strong typeof(self) sself = wself;
                                             if (bfinishBlock)
                                             {
                                                 bfinishBlock(YES, image, nil);
                                             }
                                             else
                                             {
                                                 [sself changePropertiesInCurrentUser:searchTerm image:object excludeTerm:title];
                                             }
                                         }
                                         else
                                         {
                                             if (bfinishBlock)
                                             {
                                                 bfinishBlock(NO, nil, error);
                                             }
                                         }
                                     }];

    }
    else
    {
        // Create a new image instance
        PFObject *pfimage = [PFObject objectWithClassName:@"COTDImage"];
        pfimage[@"fullUrl"] = imageUrl;
        pfimage[@"thumbnailUrl"] = thumbnailUrl;
        pfimage[@"likes"] = @(0);
        pfimage[@"imageTitle"] = title;
        pfimage.ACL = [self postACL];
        [pfimage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                // Assign the image instance into user image
                [pfimage fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error)
                    {
                        COTDImage *image = new COTDImage([object.objectId UTF8String],
                                                         [imageUrl UTF8String],
                                                         [thumbnailUrl UTF8String],
                                                         [title UTF8String],
                                                         0);
                        __strong typeof(self) sself = wself;
                        
                        [sself.images addObject:[NSValue valueWithPointer:image]];
                        if (bfinishBlock)
                        {
                            bfinishBlock(YES, image, nil);
                        }
                        else
                        {
                            [sself changePropertiesInCurrentUser:searchTerm image:object excludeTerm:title];
                        }
                    }
                    else
                    {
                        if (bfinishBlock)
                        {
                            bfinishBlock(NO, nil, error);
                        }
                    }
                }];
            }
        }];
    }
}


- (void)changePropertiesInCurrentUser:(NSString *)searchTerm image:(PFObject *)image excludeTerm:(NSString *)excludeTerm
{
    __weak typeof(self) wself = self;

    PFQuery *query = [PFQuery queryWithClassName:@"COTDUserImage"];
    
    __block BOOL isNew = NO;
    [query getObjectInBackgroundWithId:[PFUser currentUser].objectId
                                 block:^(PFObject *object, NSError *error) {
                                     PFObject *userImage = object;
                                     typeof(wself) sself = wself;

                                     if (error)
                                     {
                                         userImage = [PFObject objectWithClassName:@"COTDUserImage"];
                                         userImage[@"user"] = [PFUser currentUser];
                                         userImage[@"savedAt"] = [sself today];
                                         isNew = YES;
                                     }
                                     if (searchTerm)
                                     {
                                         [sself changeCurrentUserSearchTerm:searchTerm];
                                     }
                                     if (image)
                                     {
                                         userImage[@"image"] = image;
                                     }
                                     [userImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded)
                                         {
                                             COTDUserImage *userImage = nil;
                                             if (isNew)
                                             {
                                                 userImage = new COTDUserImage([image.objectId UTF8String], [[[sself today] formattedDate] UTF8String]);
                                                 __strong typeof(self) sself = wself;
                                                 [sself.userImages addObject:[NSValue valueWithPointer:userImage]];
                                             }
                                         }

                                         [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
                                     }];

                                 }];

}

- (NSDate *)today
{
    NSDate *today = [[NSDate date] addDays:0];
    return today;
}

- (void)topTenImages:(void (^)(NSArray *objects, NSError *error))finishBlock
{
    [self queryImagesUsingLimit:10 onlyLikes:YES finishBlock:finishBlock];
}
@end
