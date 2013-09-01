//
//  CMDCatalogCell.h
//  CommandoExample
//
//  Created by Jonas Budelmann on 1/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMDCatalogCell : UICollectionViewCell

@property (nonatomic, strong) UIView *mainView;

+ (NSString *)reuseIdentifier;

@end
