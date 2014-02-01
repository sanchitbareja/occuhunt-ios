//
//  DrawView.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 1/20/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DrawView_DrawBlock)(UIView* v,CGContextRef context);

@interface DrawView : UIView
@property (nonatomic,copy) DrawView_DrawBlock drawBlock;
@end