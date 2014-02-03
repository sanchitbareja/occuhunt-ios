//
//  PortfolioViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/2/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PortfolioViewController : UIViewController <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *shareResume;
@property (nonatomic, strong) IBOutlet UIButton *logInButton;


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;


@property (strong, nonatomic) CLBeaconRegion *beaconRegionReceiver;
@property (strong, nonatomic) CLLocationManager *locationManagerReceiver;
@property IBOutlet UILabel *distanceLabel;


- (IBAction)initRegion:(id)sender;
- (IBAction)transmitBeacon:(UIButton *)sender;
- (IBAction)connectWithLinkedIn:(id)sender;

@end
