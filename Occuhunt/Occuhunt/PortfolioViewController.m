//
//  PortfolioViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/2/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "PortfolioViewController.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "SettingsViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DropResumeViewController.h"

@interface PortfolioViewController ()

@end

@implementation PortfolioViewController

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
	// Do any additional setup after loading the view.
    
//    UIImage *faceImage = [UIImage imageNamed:@"OHSmall"];
//    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
//    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
//    [face setImage:faceImage forState:UIControlStateNormal];
//    [face addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:face];
//    self.navigationItem.leftBarButtonItem = bbi;
    
//    _shareResume.layer.borderWidth = 1;
//    _shareResume.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
//    _shareResume.layer.cornerRadius = 8;
//    _shareResume.layer.masksToBounds = YES;
    
    self.shareResume = [[BButton alloc] initWithFrame:CGRectMake(40, 10, 240, 48) type:BButtonTypeSuccess style:BButtonStyleBootstrapV3 icon:FAIconDownload fontSize:12];
    [self.shareResume setTitle:@"Drop Resume" forState:UIControlStateNormal];
    [self.shareResume addTarget:self action:@selector(dropResume:) forControlEvents:UIControlEventTouchUpInside];
    [self.resumeView addSubview:self.shareResume];
    
    self.checkInStatus = [[UILabel alloc] initWithFrame:CGRectMake(11, 54, 295, 28)];
    self.checkInStatus.backgroundColor = [UIColor clearColor];
    self.checkInStatus.textAlignment = NSTextAlignmentCenter;
    self.checkInStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:11];
    self.checkInStatus.textColor = [UIColor blackColor];
    [self.resumeView addSubview:self.checkInStatus];
    
    _logInButton.layer.borderWidth = 1;
    _logInButton.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
    _logInButton.layer.cornerRadius = 8;
    _logInButton.layer.masksToBounds = YES;
    
    // iBeacon Tech
    self.locationManagerReceiver = [[CLLocationManager alloc] init];
    self.locationManagerReceiver.delegate = self;
    [self initRegion:nil];
    
    LIALinkedInHttpClient *_client;
    _client = [self client];
    
    self.portfolioScrollView.minimumZoomScale = 0.2;
    self.portfolioScrollView.maximumZoomScale = 2.0;
    self.portfolioScrollView.delegate = self;
//    self.portfolioScrollView.clipsToBounds = YES;
//    self.portfolioScrollView.contentSize = self.portfolioImageView.frame.size;
    
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[SSKeychain passwordForService:@"OH" account:@"self"] length] > 0) {
        NSLog(@"yeah in portfolio and %@", [SSKeychain passwordForService:@"OH" account:@"self"]);
        [thisServer getUser:[SSKeychain passwordForService:@"OH" account:@"self"]];
        self.resumeView.hidden = NO;
        self.loginView.hidden = YES;
    }
    else {
        self.loginView.hidden = NO;
        self.resumeView.hidden = YES;
    }
    
    void (^animationLabel) (void) = ^{
        self.checkInStatus.alpha = 1;
    };
    void (^completionLabel) (BOOL) = ^(BOOL f) {
        self.checkInStatus.alpha = 0;
    };
    
    NSUInteger opts =  UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.0f delay:0 options:opts
                     animations:animationLabel completion:completionLabel];
    
    void (^animationLabel2) (void) = ^{
        self.checkInStatus.alpha = 0;
    };
    void (^completionLabel2) (BOOL) = ^(BOOL f) {
        self.checkInStatus.alpha = 1;
    };
    NSUInteger opts2 =  UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat;
    [UIView animateWithDuration:1.0f delay:1.0f options:opts2
                     animations:animationLabel2 completion:completionLabel2];
    
    [thisServer getHunts:[SSKeychain passwordForService:@"OH" account:@"user_id"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openSettings:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SettingsViewController *vc = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    vc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)dropResume:(id)sender {
    
    DropResumeViewController *drvc = [[DropResumeViewController alloc] init];
    drvc.delegate = self;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:drvc];
    drvc.listOfCompanies = self.listOfCompaniesAtUpcomingEvent;
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)setUpProfile {
    NSString *myID = [SSKeychain passwordForService:@"OH" account:@"self"];
    [thisServer getUser:myID];
}

#pragma mark - ServerIO Methods

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    if ([[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"resume"]) {;
        self.loginView.hidden = YES;
        self.resumeView.hidden = NO;
        NSString *resumeLink = [[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"resume"];
        int userIDInt = [[[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"id"] intValue];
        NSString *userID = [NSString stringWithFormat:@"%i", userIDInt];
        [SSKeychain setPassword:userID forService:@"OH" account:@"user_id"];
        self.portfolioImageView.contentMode = UIViewContentModeTopLeft;
        NSLog(@"resume link %@", resumeLink);
        __block CGSize tempsize;
        __weak PortfolioViewController *weakSelf = self;
        [self.portfolioImageView setImageWithURL:[NSURL URLWithString:resumeLink] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
            NSLog(@"image description %@", [image description]);
//            CGRect screenRect = [[UIScreen mainScreen] bounds];
//            CGFloat screenWidth = screenRect.size.width;
//            float proportion = image.size.width/screenWidth;
//            float newHeight = image.size.height/proportion;
//            weakSelf.portfolioScrollView.contentSize = CGSizeMake(screenWidth, newHeight);
            weakSelf.portfolioScrollView.contentSize = image.size;
//            weakSelf.portfolioScrollView.zoomScale = 320/image.size.width;
        }];
    }
    else if ([[response objectForKey:@"response"] objectForKey:@"hunts"]) {
        // Hunting!
        NSDictionary *fair = [[[[response objectForKey:@"response"] objectForKey:@"hunts"] objectAtIndex:0] objectForKey:@"fair"];
        NSString *fairName = [fair objectForKey:@"name"];
        NSLog(@"fairname is %@", fairName);
        if (fairName.length > 0) {
            self.checkInStatus.text = [NSString stringWithFormat:@"You are checked in at %@", fairName];
            // Download fair details
#warning to change before submission
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://occuhunt.com/static/faircoords/8.json"]]];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if (error || data == (id)[NSNull null] || [data length] == 0) {
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, we were unable to retrieve the list of companies. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                           [alert show];
                                       }
                                       else {
                                           NSError* error;
                                           NSDictionary* json = [NSJSONSerialization
                                                                 JSONObjectWithData:data //1
                                                                 options:kNilOptions
                                                                 error:&error];
                                           
                                           NSLog(@"json: %@", json); //3
                                           
                                           NSArray *companies = [json objectForKey:@"coys"];
                                           
                                           self.listOfCompaniesAtUpcomingEvent = companies;
                                       }
                                   }];

       }
    }
}

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    
}

#pragma mark - LinkedIn Methods

- (IBAction)connectWithLinkedIn:(id)sender {
    NSLog(@"Did tap connect with linkedin");
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [self requestMeWithToken:accessToken];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}


- (void)requestMeWithToken:(NSString *)accessToken {
    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,industry)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
        [SSKeychain setPassword:[result objectForKey:@"id"] forService:@"OH" account:@"self"];
        NSMutableDictionary *toSaveInfoDictionary = [result mutableCopy];
        [toSaveInfoDictionary setValue:nil forKey:@"id"]; // Delete ID
        result = nil;
        [[NSUserDefaults standardUserDefaults] setObject:toSaveInfoDictionary forKey:@"userInfo"]; // Save the rest in userInfo dict
        [self setUpProfile];
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}



- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com/liaexample"
                                                                                    clientId:@"xu79xm7p77of"
                                                                                clientSecret:@"UnJhJkwNuUru2m4Y"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_emailaddress", @"r_fullprofile", @"r_contactinfo", @"r_network", @"w_messages"]];
    
    
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

#pragma mark - UIScrollView Delegate Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"Scrolled");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //    NSLog(@"Zoomed");
    NSLog(@"my frame is %f %f", self.portfolioScrollView.frame.size.height, self.portfolioScrollView.frame.size.width);
    NSLog(@"my size is %f %f", self.portfolioScrollView.contentSize.height, self.portfolioScrollView.contentSize.width);
    NSLog(@"my zoomscale is %f", self.portfolioScrollView.zoomScale);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.portfolioScrollView) {
        return self.portfolioImageView;
    }
    return nil;
}

#pragma mark - Bluetooth-specific Methods

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


@end
