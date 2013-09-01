//
//  CMDCatalogViewController.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 1/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDCatalogViewController.h"
#import "CMDCatalogCell.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const kCatalogCellReuseIdentifier = @"kCatalogCellReuseIdentifier";

@interface CMDCatalogViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation CMDCatalogViewController

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.title = @"Catalog";
    self.items = @[
        @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13
    ];

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
    [self.collectionView registerClass:CMDCatalogCell.class
            forCellWithReuseIdentifier:kCatalogCellReuseIdentifier];

    self.view = self.collectionView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CMDCatalogCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:kCatalogCellReuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = UIColor.redColor.CGColor;
    cell.layer.borderWidth = 1;
    return cell;
}

#pragma mark -  UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(140, 80);
}


@end
