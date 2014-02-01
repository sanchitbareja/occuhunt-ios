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
#import <AFNetworking/AFJSONRequestOperation.h>
#import "DrawView.h"
#import "PulsingHaloLayer.h"

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
    self.mapScrollView.delegate = self;
    self.mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CEEFairMap.jpg"]];
    
    [self.mapView addSubview:self.mapScrollView];
    [self.mapScrollView addSubview:self.mapImageView];
    
    self.mapScrollView.contentSize = self.mapImageView.image.size;
	self.mapScrollView.maximumZoomScale = 2.0;
	self.mapScrollView.minimumZoomScale = 0.2;
    self.mapScrollView.zoomScale = 0.255;
    
    self.mainSearchBar.hidden = YES;
    LOG_EXPR(self.mapScrollView.contentSize);
    
    // Grid View
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    
    self.listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) collectionViewLayout:layout];
    [self.listView addSubview:self.listCollectionView];
    self.listCollectionView.backgroundColor = [UIColor clearColor];
    
    [self.listCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    [self.listCollectionView setDataSource:self];
    [self.listCollectionView setDelegate:self];
    
    NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
    } failure:nil];
    
    [operation start];
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = CGPointMake(380, 1060);
    [self.mapImageView.layer addSublayer:halo];
    
    // iBeacon Tech
    self.locationManagerReceiver = [[CLLocationManager alloc] init];
    self.locationManagerReceiver.delegate = self;
    [self initRegion:nil];
    
}

// Receiver

- (IBAction)initRegion:(id)sender {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.devfright.myRegion"];
    
    [self.locationManagerReceiver startMonitoringForRegion:self.beaconRegion];
    NSLog(@"Monitoring Region");

}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManagerReceiver startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManagerReceiver stopRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    NSLog(@"Received!");
//    self.beaconFoundLabel.text = @"Yes";
//    self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
//    self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
//    self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    NSLog(@"%f", beacon.accuracy);
    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.distanceLabel.text = @"Beacon Received! Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Beacon Received! Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Beacon Received! Far";
    }
//    self.rssiLabel.text = [NSString stringWithFormat:@"%i", beacon.rssi];
}

// Broadcaster

- (void)initBeacon {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"23542266-18D1-4FE4-B4A1-23F8195B9D39"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:1
                                                                minor:1
                                                           identifier:@"com.devfright.myRegion"];
}

- (IBAction)transmitBeacon:(UIButton *)sender {
    self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [self.peripheralManager stopAdvertising];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openSearchBar:(id)sender {
    if (self.mainSearchBar.hidden == YES) {
        self.mainSearchBar.hidden = NO;
        self.drawLineButton.hidden = YES;
        [self.mainSearchBar becomeFirstResponder];
    }
    else {
        self.mainSearchBar.hidden = YES;
        self.drawLineButton.hidden = NO;
    }
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

- (IBAction)drawLine:(id)sender {
    NSLog(@"Drawing");
    DrawView* drawableView = [[DrawView alloc] initWithFrame:CGRectMake(330,375,2000,2000)];
    drawableView.backgroundColor = [UIColor clearColor];
    drawableView.alpha = 0.5;
    drawableView.drawBlock = ^(UIView* v,CGContextRef context)
    {
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 100, 0);
        CGContextAddLineToPoint(context, 100, 50);
        CGContextAddLineToPoint(context, 0, 50);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        CGContextFillPath(context);
        
        
        CGContextMoveToPoint(context, 40, 50);
        CGContextAddLineToPoint(context, 50, 50);
        CGContextAddLineToPoint(context, 50, 660);
        CGContextAddLineToPoint(context, 40, 660);
        CGContextAddLineToPoint(context, 40, 50);
        CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
        CGContextFillPath(context);
    };
    [self.mapImageView addSubview:drawableView];
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
    NSLog(@"Zoom scale, %f", scrollView.zoomScale);
}

#pragma mark - List View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.backgroundColor = UIColorFromRGB(0xecf0f1);
    
    UIImageView *mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 70)];
    mainImage.image = [UIImage imageNamed:@"accenture-advert.jpg"];
    mainImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell addSubview:mainImage];
    
    UILabel *companyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, 140, 20)];
    companyNameLabel.textAlignment = NSTextAlignmentCenter;
    companyNameLabel.textColor = UIColorFromRGB(0x2c3e50);
    companyNameLabel.font = [UIFont fontWithName:@"Open Sans" size:12];
    companyNameLabel.text = @"Accenture";
    [cell addSubview:companyNameLabel];
    
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

# pragma mark - UISearchBar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self openSearchBar:nil];
    [self drawLine:nil];
    [searchBar resignFirstResponder];
}

@end
