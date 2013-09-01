//
//  CMDCatalogCell.m
//  CommandoExample
//
//  Created by Jonas Budelmann on 1/09/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "CMDCatalogCell.h"

@implementation CMDCatalogCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.mainView.frame = self.contentView.bounds;
}

- (void)setMainView:(UIView *)mainView {
    if (_mainView != mainView) {
        [_mainView removeFromSuperview];

        _mainView = mainView;
        [self.contentView addSubview:_mainView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.mainView = nil;
}

@end
