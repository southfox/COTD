//
//  COTDMostLikedViewController.m
//  COTD
//
//  Created by Javier Fuchs on 7/22/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "COTDMostLikedViewController.h"
#import "COTDMostLikedCollectionViewCell.h"
#import "COTDParse.h"
#import <Parse/Parse.h>
#import "UIView+COTD.h"

@interface COTDMostLikedViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *topTenArray;

@end

@implementation COTDMostLikedViewController

- (void)awakeFromNib
{
    [self configureCells];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view startSpinnerWithString:@"Loading top 10 results" tag:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) wself = self;
    
    [[COTDParse sharedInstance] topTenImages:^(NSArray *objects, NSError *error) {
        typeof(wself) sself = wself;
        sself.topTenArray = objects;
        [sself reloadData];
        [sself.view stopSpinner:1];
    }];

}
- (void)configureCells
{
    UINib *cellNib = [UINib nibWithNibName:[COTDMostLikedCollectionViewCell identifier] bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:[COTDMostLikedCollectionViewCell identifier]];
    [self.collectionView registerClass:[COTDMostLikedCollectionViewCell class] forCellWithReuseIdentifier:[COTDMostLikedCollectionViewCell identifier]];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.topTenArray.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    COTDMostLikedCollectionViewCell *cell = (COTDMostLikedCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([COTDMostLikedCollectionViewCell class]) forIndexPath:indexPath];
    
    PFObject *image = self.topTenArray[indexPath.row];
    [cell configureWithImage:image[@"thumbnailUrl"]];
    
    return cell;
}


- (void)reloadData
{
    [self.collectionView reloadData];
    
    [self.collectionView flashScrollIndicators];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
