//
//  COTDMostLikedCollectionViewCell.h
//  COTD
//
//  Created by Javier Fuchs on 7/22/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COTDMostLikedCollectionViewCell : UICollectionViewCell

- (void)configureWithImage:(NSString *)urlImage;

+ (NSString *)identifier;

@end
