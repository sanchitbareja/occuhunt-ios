//
//  MainViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property IBOutlet UIView *mapView;
@property IBOutlet UIView *listView;

@property IBOutlet UIScrollView *mapScrollView;
@property IBOutlet UIImageView *mapImageView;

@property UICollectionView *listCollectionView;


- (IBAction)openRightDrawer:(id)sender;
- (IBAction)segmentedValueChanged:(id)sender;

@end
