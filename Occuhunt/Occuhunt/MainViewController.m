//
//  MainViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "MainViewController.h"
#import "VTPG_Common.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
    
	// Map View
    self.mapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];
    self.mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dccexhibitionhall"]];
    
    [self.mapView addSubview:self.mapScrollView];
    [self.mapScrollView addSubview:self.mapImageView];
    
    self.mapScrollView.contentSize = self.mapImageView.image.size;
	self.mapScrollView.maximumZoomScale = 4.0;
	self.mapScrollView.minimumZoomScale = 1;
    LOG_EXPR(self.mapScrollView.contentSize);
    
    // Grid View
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    
    self.listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) collectionViewLayout:layout];
    [self.listView addSubview:self.listCollectionView];
    self.listCollectionView.backgroundColor = [UIColor clearColor];
    
    [self.listCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    [self.listCollectionView setDataSource:self];
    [self.listCollectionView setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openRightDrawer:(id)sender {
    [self.sidePanelController showRightPanelAnimated:YES];
}


- (IBAction)segmentedValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            // Map View
            self.mapView.hidden = NO;
            self.listView.hidden = YES;
            break;
        case 1:
            // List View
            self.listView.hidden = NO;
            self.mapView.hidden = YES;
            break;
    }
}

#pragma mark - Scroll View

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"lol");
    return self.mapImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"im scrolling");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"im zooming");
}

#pragma mark - List View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.backgroundColor = UIColorFromRGB(0x95a5a5);
    
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 70)];
    mainImage.image = [UIImage imageNamed:@"accenture-advert.jpg"];
    mainImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:mainImage];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(40, 15, 40, 15);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140, 110);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 40;
}
@end
