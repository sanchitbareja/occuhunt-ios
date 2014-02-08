//
//  SharpLabel.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/7/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "SharpLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation SharpLabel

- (id)init
{
    self = [super init];
    if (self) {
        CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
        tiledLayer.levelsOfDetailBias = 4;
        tiledLayer.levelsOfDetail = 4;
        self.opaque = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class)layerClass {
    return [CATiledLayer class];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
