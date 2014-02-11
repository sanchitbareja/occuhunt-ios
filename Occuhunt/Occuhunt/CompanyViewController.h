//
//  CompanyViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/5/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerIO.h"
#import <BButton/BButton.h>

@interface CompanyViewController : UIViewController <ServerIODelegate> {
    IBOutlet UITextView *companyDetailTextView;
    ServerIO *thisServer;
}

@property (nonatomic, strong) IBOutlet UIButton *viewJobsWebsiteButton;
@property (nonatomic, strong) IBOutlet UIButton *dropResumeButton;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) IBOutlet UIButton *favoriteButton;

@property (nonatomic, strong) NSString *companyID;
@property (nonatomic, strong) NSString *fairID;
@property (nonatomic, strong) NSString *jobsWebsiteLink;
@property (nonatomic, strong) NSDictionary *theCurrentFair;

@property (nonatomic, strong) IBOutlet UILabel *companyNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *companyBannerImageView;
@property (nonatomic, strong) IBOutlet UIImageView *companyLogo;

- (IBAction)closeView:(id)sender;
- (IBAction)dropResume:(id)sender;
- (IBAction)viewJobs:(id)sender;

@end
