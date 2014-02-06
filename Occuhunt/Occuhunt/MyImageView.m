// MyImageView.m

#import "MyImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AsyncImageView/AsyncImageView.h>

@implementation MyImageView

@dynamic image;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (id)initWithImage:(UIImage *)anImage
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _imageView.image = anImage;
        [_imageView sizeToFit];
        
        // initialize frame to be same size as imageView
        self.frame = _imageView.bounds;
    }
    return self;
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)anImage
{
    _imageView.image = anImage;
    [self setNeedsLayout];
}

- (void)setImageWithURL:(NSString *)theURL
{
    _imageView.imageURL = [NSURL URLWithString:theURL];
    [self layoutSubviews];
//    __weak MyImageView *weakSelf = self;
//    NSLog(@"called setImageWithURL");
//    NSLog(@"the url is  %@", theURL);
//    [_imageView setImage:[UIImage imageNamed:@"1.jpg"]];
//    [self setNeedsLayout];
//    [_imageView setImageWithURL:[NSURL URLWithString:theURL]
//               placeholderImage:[UIImage imageNamed:@"1.jpg"]
//                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                              NSLog(@"Success downloaded");
//                              [weakSelf setNeedsLayout];
//                          }];

    
}

- (void)layoutSubviews
{
    if (!self.image) return;
    // compute scale factor for imageView
    CGFloat widthScaleFactor = CGRectGetWidth(self.bounds) / self.image.size.width;
    CGFloat heightScaleFactor = CGRectGetHeight(self.bounds) / self.image.size.height;
    
    CGFloat imageViewXOrigin = 0;
    CGFloat imageViewYOrigin = 0;
    CGFloat imageViewWidth;
    CGFloat imageViewHeight;
    
    
    // if image is narrow and tall, scale to width and align vertically to the top
    if (widthScaleFactor > heightScaleFactor) {
        imageViewWidth = self.image.size.width * widthScaleFactor;
        imageViewHeight = self.image.size.height * widthScaleFactor;
    }
    
    // else if image is wide and short, scale to height and align horizontally centered
    else {
        imageViewWidth = self.image.size.width * heightScaleFactor;
        imageViewHeight = self.image.size.height * heightScaleFactor;
        imageViewXOrigin = - (imageViewWidth - CGRectGetWidth(self.bounds))/2;
    }
    
    _imageView.frame = CGRectMake(imageViewXOrigin,
                                  imageViewYOrigin,
                                  imageViewWidth,
                                  imageViewHeight);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

@end