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
#import <SDWebImage-ProgressView/UIImageView+ProgressView.h>
#import <VENVersionTracker/VENVersionTracker.h>
#import <VENVersionTracker/VENVersion.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "FilteredEventListViewController.h"

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
    
    [VENVersionTracker beginTrackingVersionForChannel:@"production"
                                       serviceBaseUrl:@"http://www.occuhunt.com/static/version/appversion.json"
                                         timeInterval:1800
                                          withHandler:^(VENVersionTrackerState state, VENVersion *version) {
                                              
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                    
                                                  self.appStoreLink = version.installUrl;
                                                  switch (state) {
                                                      case VENVersionTrackerStateDeprecated:
                                                          [version install];
                                                          break;
                                                          
                                                      case VENVersionTrackerStateOutdated:
                                                          // Offer the user the option to update
                                                          [self callAlertView];
                                                          break;
                                                      default:
                                                          break;
                                                  }
                                              });
                                          }];

    
    self.shareResume = [[BButton alloc] initWithFrame:CGRectMake(40, 10, 240, 48) type:BButtonTypeSuccess style:BButtonStyleBootstrapV3 icon:FAIconDownload fontSize:12];
    self.shareResume.color = UIColorFromRGB(0x348891);
    self.shareResume.layer.borderColor = [UIColor redColor].CGColor;
    [self.shareResume setTitle:@"Drop Resume" forState:UIControlStateNormal];
    [self.shareResume addTarget:self action:@selector(dropResume:) forControlEvents:UIControlEventTouchUpInside];
    [self.resumeView addSubview:self.shareResume];
    
    self.checkInStatus = [[UILabel alloc] initWithFrame:CGRectMake(11, 33, 295, 28)];
    self.checkInStatus.backgroundColor = [UIColor clearColor];
    self.checkInStatus.textAlignment = NSTextAlignmentCenter;
    self.checkInStatus.font = [UIFont fontWithName:@"Helvetica Neue" size:11];
    self.checkInStatus.textColor = [UIColor whiteColor];
//    [self.resumeView addSubview:self.checkInStatus];
    
    self.logInButton = [[BButton alloc] initWithFrame:CGRectMake(40, 203, 240, 48) type:BButtonTypeSuccess style:BButtonStyleBootstrapV3 icon:FAIconDownload fontSize:12];
    self.logInButton.color = UIColorFromRGB(0x348891);
    self.logInButton.layer.borderColor = [UIColor redColor].CGColor;
    [self.logInButton setTitle:@"Log in with LinkedIn" forState:UIControlStateNormal];
    [self.logInButton addTarget:self action:@selector(connectWithLinkedIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:self.logInButton];

    
    // iBeacon Tech
//    self.locationManagerReceiver = [[CLLocationManager alloc] init];
//    self.locationManagerReceiver.delegate = self;
//    [self initRegion:nil];
    
    LIALinkedInHttpClient *_client;
    _client = [self client];
    
    [self.resumeView addSubview:self.resumeImageView];
    
    self.portfolioScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 381)];
    self.portfolioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 381)];
    [self.resumeImageView addSubview:self.portfolioScrollView];
    
    self.portfolioScrollView.clipsToBounds = YES;
    
    [self.portfolioScrollView addSubview:self.portfolioImageView];
    
    self.portfolioScrollView.minimumZoomScale = 0.2;
    self.portfolioScrollView.maximumZoomScale = 2.0;
    self.portfolioScrollView.delegate = self;
    
    self.portfolioScrollView.contentSize = self.portfolioScrollView.frame.size;
    self.portfolioScrollView.userInteractionEnabled = YES;
    self.portfolioImageView.userInteractionEnabled = YES;
    
    self.portfolioScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.portfolioImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Scroll View + Auto Layout Fix
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_portfolioScrollView,_portfolioImageView);
    [self.resumeImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_portfolioScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.resumeImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_portfolioScrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.portfolioScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_portfolioImageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.portfolioScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_portfolioImageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = self;
    
    [thisServer getFairs];
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
    
//    if (self.resumeLink.length > 0) {
//        [self setUpProfile];
//    }
    self.shareResume.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callAlertView {
    [UIAlertView showWithTitle:@"Update Available"
                       message:@"There is a new version of Occuhunt. Update now?"
             cancelButtonTitle:@"Not Now"
             otherButtonTitles:@[@"Update"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              NSLog(@"Cancelled");
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Update"]) {
                              [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appStoreLink]];
                          }
                      }];
}

- (IBAction)openSettings:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    SettingsViewController *vc = (SettingsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    vc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)dropResume:(id)sender {
    if (self.filteredListOfEvents.count == 0) {
        UIAlertView *noUpcomingFairs = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"No upcoming fairs." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noUpcomingFairs show];
        return;
    }
    
    // Check for favorite fair
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteFair"]) {
        NSDictionary *theFair = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoriteFair"];
        
        // Check if its still upcoming
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        if (![theFair objectForKey:@"time_end"]) {
            return;
        }
        NSDate *endDate = [dateFormatter dateFromString:[theFair objectForKey:@"time_end"]];
        if ([[NSDate date] compare:endDate] == NSOrderedDescending) {
            NSLog(@"now is later than enddate. fair is over. overwrite and continue.");
            [[NSUserDefaults standardUserDefaults] setObject:@{} forKey:@"favoriteFair"];
        } else if ([[NSDate date] compare:endDate] == NSOrderedAscending) {
            NSLog(@"now is earlier than enddate");
            DropResumeViewController *drvc = [[DropResumeViewController alloc] init];
            drvc.title = [theFair objectForKey:@"name"];
            drvc.fairID = [[theFair objectForKey:@"id"] intValue];
            drvc.delegate = self;
            [[NSUserDefaults standardUserDefaults] setObject:theFair forKey:@"favoriteFair"];
            
            NSString *theID = [NSString stringWithFormat:@"%i", [[theFair objectForKey:@"id"] intValue]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://occuhunt.com/static/faircoords/%@.json", theID]]];
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
                                           
                                           drvc.listOfCompanies = [json objectForKey:@"coys"];
                                           drvc.shouldShowClose = 1;
                                           UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:drvc];
                                           [self presentViewController:navc animated:YES completion:nil];
                                        }
                                   }];
            return;
        }
    }
    
    
    FilteredEventListViewController *felvc = [[FilteredEventListViewController alloc] init];
    felvc.listOfFilteredEvents = self.filteredListOfEvents;
    felvc.delegate = self;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:felvc];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)setUpProfile {
    NSString *myID = [SSKeychain passwordForService:@"OH" account:@"self"];
    [thisServer getUser:myID];
}

#pragma mark - ServerIO Methods

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    if (operation.tag == GETUSER) {
        // Catch for no users
        if ([[[response objectForKey:@"response"] objectForKey:@"users"] count] == 0) {
            self.logInLabel.text = @"You do not have an Occuhunt profile. Visit occuhunt.com to set one up.";
            NSLog(@"NO OCCUHUNT PROFILE");
            self.loginView.hidden = NO;
            self.resumeView.hidden = YES;
            return;
        }
        if ([[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"resume"]) {;
            
            NSString *resumeLink = [[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"resume"];
            
            // No resume uploaded
            if ([resumeLink isEqual: [NSNull null]]) {
                self.logInLabel.text = @"You do not have a resume. Visit occuhunt.com to set up your profile.";
                NSLog(@"NO PROFILE");
                
                self.loginView.hidden = NO;
                self.resumeView.hidden = YES;
                return;
            }
            else {
                self.resumeLink = resumeLink;
            }
            
            self.loginView.hidden = YES;
            self.resumeView.hidden = NO;
            
            
            int userIDInt = [[[[[response objectForKey:@"response"] objectForKey:@"users"] objectAtIndex:0] objectForKey:@"id"] intValue];
            NSString *userID = [NSString stringWithFormat:@"%i", userIDInt];
            [SSKeychain setPassword:userID forService:@"OH" account:@"user_id"];
            self.portfolioImageView.contentMode = UIViewContentModeTopLeft;
            NSLog(@"resume link %@", resumeLink);
            
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"Downloaded Resume"];
            
            __weak PortfolioViewController *weakSelf = self;
            NSLog(@"my image view size is %@", NSStringFromCGSize(self.portfolioImageView.frame.size));
            self.portfolioImageView.frame = CGRectMake(0, 0, 320, 381);
            [self.portfolioImageView setImageWithURL:[NSURL URLWithString:resumeLink] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                NSLog(@"image description %@", [image description]);
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width;
                weakSelf.portfolioScrollView.contentSize = CGSizeMake(screenWidth, image.size.height);
                weakSelf.portfolioScrollView.zoomScale = 320/image.size.width;
                weakSelf.portfolioScrollView.minimumZoomScale = 320/image.size.width;
            } usingProgressView:nil];

        }
    }
    else if (operation.tag == GETHUNTS) {
        // disable now
        return;
        // Hunting!
        NSDictionary *fair = [[[[response objectForKey:@"response"] objectForKey:@"hunts"] objectAtIndex:0] objectForKey:@"fair"];
        self.fairID = [[fair objectForKey:@"id"] intValue];
        NSString *fairName = [fair objectForKey:@"name"];
        NSLog(@"fairname is %@", fairName);
        if (fairName.length > 0) {
            self.checkInStatus.text = [NSString stringWithFormat:@"You are checked in at %@", fairName];
            self.fairName = fairName;
            self.shareResume.enabled = YES;
            // Download fair details
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://occuhunt.com/static/faircoords/%i.json", self.fairID]]];
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
    else if (operation.tag == SHARERESUMEMULTIPLE) {
        UIAlertView *dropSuccessAlert;
        dropSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have dropped your resume." delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles: nil];
        [dropSuccessAlert show];
    }
    else if (operation.tag == GETFAIRS) {
        self.listOfEvents = [response objectForKey:@"objects"];
        if (self.listOfEvents.count == 0) {
            return;
        }
        NSMutableArray *filteredEvents = [[NSMutableArray alloc] init];
        for (NSDictionary *eachFair in self.listOfEvents) {
            [eachFair objectForKey:@"end_date"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *endDate = [dateFormatter dateFromString:[eachFair objectForKey:@"time_end"]];
            if ([[NSDate date] compare:endDate] == NSOrderedDescending) {
                NSLog(@"now is later than enddate");
                
            } else if ([[NSDate date] compare:endDate] == NSOrderedAscending) {
                NSLog(@"now is earlier than enddate");
                // Show events
                [filteredEvents addObject:eachFair];
            } else {
                NSLog(@"dates are the same");
                [filteredEvents addObject:eachFair];
            }
        }
        if (filteredEvents.count > 0) {
            self.shareResume.enabled = YES;
            self.filteredListOfEvents = filteredEvents;
        }
    }

}

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    if (operation.tag == SHARERESUMEMULTIPLE) {
        UIAlertView *dropSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We couldn't drop your resumes at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [dropSuccessAlert show];
    }
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
    return self.portfolioImageView;
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
