//
//  DrawView.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 1/20/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//


#import "DrawView.h"

@implementation DrawView
@synthesize drawBlock;

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if(self.drawBlock)
        self.drawBlock(self,context);
}

@end