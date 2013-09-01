//
//  CMDSimpleGridViewController.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 1/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDSimpleGridViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kGridCellReuseIdentifier = @"kGridCellReuseIdentifier";

@interface CMDSimpleGridViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionView *collectionView;

@end

@implementation CMDSimpleGridViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.title = @"Simple Grid";

    return self;
}

- (void)loadView {
    UICollectionViewFlowLayout *flowLayout = UICollectionViewFlowLayout.new;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = UIColor.whiteColor;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:UICollectionViewCell.class
            forCellWithReuseIdentifier:kGridCellReuseIdentifier];

    self.view = self.collectionView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Selected" message:[NSString stringWithFormat:@"item :%d", indexPath.item] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 200;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kGridCellReuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = UIColor.redColor.CGColor;
    cell.layer.borderWidth = 1;
    return cell;
}

#pragma mark -  UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = floor((CGRectGetWidth(collectionView.frame) - 60) / 9);
    return CGSizeMake(size, size);
}


@end
