//
//  CustomBlueToolbar.m
//  Noteprise
//
//  Created by Ritika on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomBlueToolbar.h"

@implementation CustomBlueToolbar

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //UIColor *color = [UIColor colorWithRed:0.547 green:0.344 blue:0.118 alpha:1.000]; //wood tan color
    UIImage *img  = [UIImage imageNamed: @"Toolbar_768x44.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [img release];
    self.tintColor = [UIColor clearColor];
    
}

@end

@implementation CustomWhiteToolbar

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //UIColor *color = [UIColor colorWithRed:0.547 green:0.344 blue:0.118 alpha:1.000]; //wood tan color
    UIImage *img  = [UIImage imageNamed: @"White_bordered_background.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [img release];
    self.tintColor = [UIColor clearColor];
    
}

@end
