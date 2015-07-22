//
//  COTDMostLikedCollectionViewCell.m
//  COTD
//
//  Created by Javier Fuchs on 7/22/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "COTDMostLikedCollectionViewCell.h"
#import "COTDImage.h"
#import <UIImageView+AFNetworking.h>

@interface COTDMostLikedCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *imageGridView;
@property (nonatomic) NSString *urlImage;
@end

@implementation COTDMostLikedCollectionViewCell

- (void)configureWithImage:(NSString *)urlImage;
{
    self.urlImage = urlImage;
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    NSURL *url = [NSURL URLWithString:self.urlImage];
    [self.imageGridView setImageWithURL:url placeholderImage:nil];
}

+ (NSString *)identifier;
{
    return NSStringFromClass([self class]);
}



@end
