//
//  CompanyViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/5/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "CompanyViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SSKeychain/SSKeychain.h>
#import "UIImage+ImageEffects.h"

@interface CompanyViewController ()

@end

@implementation CompanyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)closeView:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        // do sth
    }];
}

- (IBAction)favoriteCompany:(id)sender {
    if([[SSKeychain passwordForService:@"OH" account:@"self"] length] == 0) {
        UIAlertView *notLoggedIn = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notLoggedIn show];
    }
    else {
        NSString *userID = [SSKeychain passwordForService:@"OH" account:@"user_id"];
        NSLog(@"your user id is %@", userID);
        [self.favoriteButton setSelected:YES];
        [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateSelected | UIControlStateNormal];
//        self.favoriteButton.userInteractionEnabled = NO;
        [thisServer favoriteWithUserID:userID andCompanyID:self.companyID];
    }
}

- (IBAction)unFavoriteCompany:(id)sender {
    if([[SSKeychain passwordForService:@"OH" account:@"self"] length] == 0) {
        UIAlertView *notLoggedIn = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notLoggedIn show];
    }
    else {
        NSString *userID = [SSKeychain passwordForService:@"OH" account:@"user_id"];
        NSLog(@"your user id is %@", userID);
        //        self.favoriteButton.userInteractionEnabled = NO;
        [self.favoriteButton setSelected:NO];
        [self.favoriteButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateSelected | UIControlStateNormal];
        [thisServer unfavoriteWithUserID:userID andCompanyID:self.companyID];
    }
}


- (IBAction)viewJobs:(id)sender {
    if (self.jobsWebsiteLink.length <= 0) {
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.jobsWebsiteLink]];
}

- (IBAction)dropResume:(id)sender {
    if([[SSKeychain passwordForService:@"OH" account:@"self"] length] == 0) {
        UIAlertView *notLoggedIn = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You are not logged in." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notLoggedIn show];
    }
    else {
        NSString *userID = [SSKeychain passwordForService:@"OH" account:@"user_id"];
        NSLog(@"your user id is %@", userID);
        
        [thisServer shareResumeWithRecruitersWithUserID:userID andFairID:[self.fairID intValue] andCompanyID:self.companyID andStatus:@"1"];
     }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.dropResumeButton = [[BButton alloc] initWithFrame:CGRectMake(60, 402, 160, 48) type:BButtonTypeSuccess style:BButtonStyleBootstrapV3 icon:FAIconDownload fontSize:12];
//    self.dropResumeButton.color = UIColorFromRGB(0x348891);
//    [self.dropResumeButton setTitle:@"Drop Resume" forState:UIControlStateNormal];
//    [self.dropResumeButton addTarget:self action:@selector(dropResume:) forControlEvents:UIControlEventTouchUpInside];
    self.dropResumeButton.enabled = NO;
    self.viewJobsWebsiteButton.enabled = NO;
//    [self.view addSubview:self.dropResumeButton];
    
    [self.favoriteButton setImage:nil forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated {
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = self;
    [thisServer getCompany:self.companyID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server IO Methods

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    NSLog(@"Success!");
    if (operation.tag == GETCOMPANY) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 20.0f;
        paragraphStyle.minimumLineHeight = 20.0f;
        paragraphStyle.maximumLineHeight = 20.0f;
        
        NSDictionary *theCompany = [[[response objectForKey:@"response"] objectForKey:@"companies"] objectAtIndex:0];
        
        NSString *string = [theCompany objectForKey:@"company_description"];
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
//        UIColor *color = UIColorFromRGB(0x005f69);
        UIColor *color = [UIColor blackColor];
        NSDictionary *attribute = @{
                                    NSParagraphStyleAttributeName : paragraphStyle,
                                    NSFontAttributeName : font,
                                    NSForegroundColorAttributeName : color
                                    };
        companyDetailTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attribute];
        
        self.viewJobsWebsiteButton.enabled = YES;
        self.jobsWebsiteLink = [theCompany objectForKey:@"careers_website"];
        
        self.dropResumeButton.enabled = YES;
        self.companyNameLabel.text = [theCompany objectForKey:@"name"];
        __weak CompanyViewController *weakSelf = self;
        [self.companyBannerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [theCompany objectForKey:@"banner_image"]]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
            weakSelf.companyBannerImageView.image = [image applyBlurWithRadius:20 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
        }];
        [self.companyLogo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [theCompany objectForKey:@"logo"]]] placeholderImage:nil completed:nil];
        
        NSArray *listOfPeopleWhoFavoritedThisCompany = [theCompany objectForKey:@"favorites"];
        NSString *userID = [SSKeychain passwordForService:@"OH" account:@"user_id"];
        if (userID.length > 0) {
            
            [self.favoriteButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
            self.favoriteButton.userInteractionEnabled = YES;
            [self.favoriteButton removeTarget:nil
                                       action:NULL
                             forControlEvents:UIControlEventAllEvents];
            [self.favoriteButton addTarget:self action:@selector(favoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
            
            for (NSNumber *eachPerson in listOfPeopleWhoFavoritedThisCompany) {
                if ([eachPerson intValue] == [userID intValue]) {
                    NSLog(@"Initial set up is filled");
                    [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
                    self.favoriteButton.userInteractionEnabled = YES;
                    [self.favoriteButton removeTarget:nil
                                       action:NULL
                             forControlEvents:UIControlEventAllEvents];
                    [self.favoriteButton addTarget:self action:@selector(unFavoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        NSLog(@"Finished setting up!");
    }
    else if (operation.tag == SHARERESUME){
        if ([operation.response statusCode] == 200 || [operation.response statusCode] == 201) {
            NSLog(@"Success!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resume dropped!" message:[NSString stringWithFormat:@"Expect to hear back from %@ soon!", self.companyNameLabel.text] delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles: nil];
            [alert show];

        }
    }
    else if (operation.tag == FAVORITECOMPANY) {
        NSLog(@"Succeed and favorite");
//        [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
        self.favoriteButton.highlighted = NO;
        self.favoriteButton.userInteractionEnabled = YES;
        [self.favoriteButton removeTarget:nil
                                   action:NULL
                         forControlEvents:UIControlEventAllEvents];
        [self.favoriteButton addTarget:self action:@selector(unFavoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (operation.tag == UNFAVORITECOMPANY) {
        NSLog(@"Succeed and unfavorite");
        [self.favoriteButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
        self.favoriteButton.highlighted = NO;
        self.favoriteButton.userInteractionEnabled = YES;
        [self.favoriteButton removeTarget:nil
                                   action:NULL
                         forControlEvents:UIControlEventAllEvents];
        [self.favoriteButton addTarget:self action:@selector(favoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    NSLog(@"Failure!");
//    if (operation.tag == FAVORITECOMPANY) {
//        [self.favoriteButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
//        self.favoriteButton.userInteractionEnabled = YES;
//        [self.favoriteButton removeTarget:nil
//                                   action:NULL
//                         forControlEvents:UIControlEventAllEvents];
//        [self.favoriteButton addTarget:self action:@selector(favoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else if (operation.tag == UNFAVORITECOMPANY) {
//        [self.favoriteButton setImage:[UIImage imageNamed:@"HeartFilled"] forState:UIControlStateNormal];
//        self.favoriteButton.userInteractionEnabled = YES;
//        [self.favoriteButton removeTarget:nil
//                                   action:NULL
//                         forControlEvents:UIControlEventAllEvents];
//        [self.favoriteButton addTarget:self action:@selector(unFavoriteCompany:) forControlEvents:UIControlEventTouchUpInside];
//    }
    if (operation.tag == SHARERESUME) {
        UIAlertView *dropSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We couldn't drop your resumes at this time. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [dropSuccessAlert show];
    }
}
@end
