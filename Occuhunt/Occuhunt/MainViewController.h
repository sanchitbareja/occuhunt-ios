//
//  MainViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MainViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property IBOutlet UIView *mapView;
@property IBOutlet UIView *listView;

@property IBOutlet UIScrollView *mapScrollView;
@property IBOutlet UIImageView *mapImageView;

@property IBOutlet UISearchBar *mainSearchBar;
@property IBOutlet UIButton *drawLineButton;

@property UICollectionView *listCollectionView;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;


@property (strong, nonatomic) CLBeaconRegion *beaconRegionReceiver;
@property (strong, nonatomic) CLLocationManager *locationManagerReceiver;
@property IBOutlet UILabel *distanceLabel;

- (IBAction)openRightDrawer:(id)sender;
- (IBAction)segmentedValueChanged:(id)sender;

- (IBAction)initRegion:(id)sender;
- (IBAction)transmitBeacon:(UIButton *)sender;

@end
