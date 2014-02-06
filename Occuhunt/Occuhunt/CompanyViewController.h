//
//  CompanyViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/5/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerIO.h"

@interface CompanyViewController : UIViewController <ServerIODelegate> {
    IBOutlet UITextView *companyDetailTextView;
    ServerIO *thisServer;
}

@property (nonatomic, strong) NSString *companyID;
@property (nonatomic, strong) IBOutlet UILabel *companyNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *companyBannerImageView;

- (IBAction)closeView:(id)sender;
- (IBAction)dropResume:(id)sender;

@end
