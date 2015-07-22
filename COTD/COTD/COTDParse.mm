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
@property (nonatomic) NSMutableSet *excludeTerms;
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
        self.excludeTerms = [NSMutableSet set];
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
            COTDUserImage *userImage = [self userImage];
            if (userImage)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
            }
        }];
        
    }];
}

- (void)queryImages:(void (^)(BOOL succeeded, NSError *error))finishBlock;
{
    __weak typeof(self) wself = self;

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
                __strong typeof(self) sself = wself;
                sself.images = [NSMutableArray new];
                COTDImage *image = new COTDImage();
                for (PFObject *object in objects)
                {
                    image->setObjectId((std::string)[object.objectId UTF8String]);
                    image->setFullUrl((std::string)[object[@"fullUrl"] UTF8String]);
                    image->setLikes([object[@"likes"] intValue]);
                    image->setImageTitle((std::string)[object[@"imageTitle"] UTF8String]);
                    [sself.images addObject:[NSValue valueWithPointer:image]];
                }
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
    __weak typeof(self) wself = self;

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
                __strong typeof(self) sself = wself;

                sself.userImages = [NSMutableArray new];
                COTDUserImage *userImage = new COTDUserImage();
                for (PFObject *object in objects)
                {
                    PFObject *image = object[@"image"];
                    std::string objectId = [image.objectId UTF8String];
                    userImage->setImage(objectId);
                    
                    NSDate *savedAt = object[@"savedAt"];
                    userImage->setSavedAt((std::string)[[savedAt formattedDate] UTF8String]);
                    [sself.userImages addObject:[NSValue valueWithPointer:userImage]];
                    for (NSValue *imageObject in sself.images)
                    {
                        COTDImage *image = (COTDImage *)[imageObject pointerValue];
                        if (image->getObjectId() == objectId)
                        {
                            [sself.excludeTerms addObject:[NSString stringWithFormat:@"%s", image->getImageTitle().c_str()]];
                        }
                    }
                }
                finishBlock(YES, nil);
            }
            else
            {
                finishBlock(NO, [NSError errorWithMessage:@"cannot get COTDImage"]);
            }
        }
    }];
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

- (NSString *)currentUserExcludeTerms
{
    if (self.excludeTerms.count)
    {
        NSString *excludeTerms = [[self.excludeTerms allObjects] componentsJoinedByString:@" "];
        return excludeTerms;
    }
    return nil;
}

- (void)updateImage:(NSString *)imageUrl title:(NSString *)title searchTerm:(NSString *)searchTerm
{
    __weak typeof(self) wself = self;

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
                                         [self changePropertiesInCurrentUser:searchTerm image:object excludeTerm:title];
                                     }];

    }
    else
    {
        // Create a new image instance
        PFObject *pfimage = [PFObject objectWithClassName:@"COTDImage"];
        pfimage[@"fullUrl"] = imageUrl;
        pfimage[@"likes"] = @(0);
        pfimage[@"imageTitle"] = title;
        [pfimage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                // Assign the image instance into user image
                [pfimage fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error)
                    {
                        COTDImage *image = new COTDImage();
                        image->setFullUrl((std::string)[imageUrl UTF8String]);
                        image->setLikes(0);
                        image->setImageTitle((std::string)[title UTF8String]);
                        image->setObjectId((std::string)[object.objectId UTF8String]);

                        __strong typeof(self) sself = wself;
                        
                        [sself.images addObject:[NSValue valueWithPointer:image]];
                        
                        [sself changePropertiesInCurrentUser:searchTerm image:object excludeTerm:title];
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
                                         sself.searchTerm = searchTerm;
                                     }
                                     if (image)
                                     {
                                         userImage[@"image"] = image;
                                     }
                                     if (excludeTerm)
                                     {
                                         [sself.excludeTerms addObject:excludeTerm];
                                     }
                                     [userImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded)
                                         {
                                             COTDUserImage *userImage = nil;
                                             if (isNew)
                                             {
                                                 userImage = new COTDUserImage();
                                                 userImage->setImage((std::string)[image.objectId UTF8String]);
                                                 __strong typeof(self) sself = wself;
                                                 [sself.userImages addObject:[NSValue valueWithPointer:userImage]];
                                                 userImage->setSavedAt((std::string)[[[sself today] formattedDate] UTF8String]);
                                             }
                                             else
                                             {
                                                 for (NSValue *userImageObject in self.userImages)
                                                 {
                                                     userImage = (COTDUserImage *)[userImageObject pointerValue];
                                                     break;
                                                 }
                                             }
                                         }

                                         [[NSNotificationCenter defaultCenter] postNotificationName:COTDParseServiceQueryDidFinishNotification object:nil];
                                     }];

                                 }];

}

- (NSDate *)today
{
    NSDate *today = [[NSDate date] addDays:2];
    return today;
}
@end
