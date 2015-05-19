//
//  CircleButton.m
//  Image Processing
//
//  Created by Karen Karapetyan on 5/8/15.
//  Copyright (c) 2015 Connectto. All rights reserved.
//

#import "CircleButton.h"

@implementation CircleButton

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0;
}

@end
