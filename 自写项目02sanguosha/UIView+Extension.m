//
//  UIView+Extension.m
//  ZS微博weibo
//
//  Created by Apple on 15/8/16.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)setFrameX:(CGFloat)frameX {
    CGRect rect = self.frame;
    rect.origin.x = frameX;
    self.frame = rect;
}

- (CGFloat)frameX {
    return self.frame.origin.x;
}

- (void)setFrameY:(CGFloat)frameY {
    CGRect rect = self.frame;
    rect.origin.y = frameY;
    self.frame = rect;
}

- (CGFloat)frameY {
    return self.frame.origin.y;
}

- (void)setFrameW:(CGFloat)frameW {
    CGRect rect = self.frame;
    rect.size.width = frameW;
    self.frame = rect;
}

- (CGFloat)frameW {
    return self.frame.size.width;
}

- (void)setFrameH:(CGFloat)frameH {
    CGRect rect = self.frame;
    rect.size.height = frameH;
    self.frame = rect;
}

- (CGFloat)frameH {
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint point = self.center;
    point.x = centerX;
    self.center = point;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint point = self.center;
    point.y = centerY;
    self.center = point;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setSize:(CGSize)size {
    CGRect rect = self.frame;
    
    rect.size = size;
    self.frame = rect;
}

- (CGSize)size {
    return self.frame.size;
}



@end
