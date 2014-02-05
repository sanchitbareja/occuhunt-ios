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
#import "ServerIO.h"

@interface PortfolioViewController : UIViewController <CBPeripheralManagerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, ServerIODelegate> {
    ServerIO *thisServer;
}

@property (nonatomic, strong) IBOutlet UIButton *shareResume;
@property (nonatomic, strong) IBOutlet UIView *loginView;
@property (nonatomic, strong) IBOutlet UIButton *logInButton;
@property (nonatomic, strong) IBOutlet UIScrollView *portfolioScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *portfolioImageView;


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;


@property (strong, nonatomic) CLBeaconRegion *beaconRegionReceiver;
@property (strong, nonatomic) CLLocationManager *locationManagerReceiver;
@property IBOutlet UILabel *distanceLabel;


- (IBAction)initRegion:(id)sender;
- (IBAction)transmitBeacon:(UIButton *)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)connectWithLinkedIn:(id)sender;

@end
