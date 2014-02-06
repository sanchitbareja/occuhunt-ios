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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 20.0f;
    paragraphStyle.minimumLineHeight = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    
    NSDictionary *theCompany = [[[response objectForKey:@"response"] objectForKey:@"companies"] objectAtIndex:0];
    
    NSString *string = [theCompany objectForKey:@"company_description"];
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    UIColor *color = UIColorFromRGB(0x005f69);
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSFontAttributeName : font,
                                NSForegroundColorAttributeName : color
                                };
    companyDetailTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attribute];
    
    self.companyNameLabel.text = [theCompany objectForKey:@"name"];
    [self.companyBannerImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [theCompany objectForKey:@"banner_image"]]]];
    NSLog(@"Finished setting up!");
}

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    
}
@end
