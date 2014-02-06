//
//  MyImageView.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/5/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyImageView : UIView {
    UIImageView *_imageView;
}

- (void)setImageWithURL:(NSString *)theURL;

@property (nonatomic, assign) UIImage *image;

@end