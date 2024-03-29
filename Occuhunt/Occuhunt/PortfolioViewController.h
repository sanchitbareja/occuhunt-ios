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
#import "MyImageView.h"
#import <BButton/BButton.h>

@interface PortfolioViewController : UIViewController <CBPeripheralManagerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, ServerIODelegate> {
    ServerIO *thisServer;
    
    float myHeight;
    float myWidth;
    
}

@property (nonatomic, strong) NSString *appStoreLink;
@property (nonatomic, strong) NSString *resumeLink;

@property (nonatomic, strong) IBOutlet BButton *shareResume;
@property (nonatomic, strong) UILabel *checkInStatus;
@property (nonatomic, strong) NSString *fairName;
@property (nonatomic, assign) int fairID;

@property (nonatomic, strong) IBOutlet UIView *loginView;
@property (nonatomic, strong) IBOutlet UIView *resumeView;
@property (nonatomic, strong) IBOutlet UIView *resumeImageView;
@property (nonatomic, strong) IBOutlet UILabel *logInLabel;
@property (nonatomic, strong) IBOutlet BButton *logInButton;
@property (nonatomic, strong) IBOutlet UIScrollView *portfolioScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *portfolioImageView;


@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;


@property (strong, nonatomic) CLBeaconRegion *beaconRegionReceiver;
@property (strong, nonatomic) CLLocationManager *locationManagerReceiver;
@property IBOutlet UILabel *distanceLabel;

@property (nonatomic, strong) NSArray *listOfCompaniesAtUpcomingEvent;

@property (nonatomic, strong) NSArray *listOfEvents;
@property (nonatomic, strong) NSArray *filteredListOfEvents;


- (IBAction)initRegion:(id)sender;
- (IBAction)transmitBeacon:(UIButton *)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)connectWithLinkedIn:(id)sender;

@end
