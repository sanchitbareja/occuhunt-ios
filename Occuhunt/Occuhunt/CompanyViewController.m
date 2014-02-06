//
//  CompanyViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/5/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "CompanyViewController.h"
#import <MZFormSheetController/MZFormSheetController.h>

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
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 20.0f;
    paragraphStyle.minimumLineHeight = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;
    
    NSString *string = @"Yelp (NYSE: YELP) connects people with great local businesses. Yelp was founded in San Francisco in July 2004. Since then, Yelp communities have taken root in major metros across the US, Canada, UK, Ireland, France, Germany, Austria, The Netherlands, Spain, Italy, Switzerland, Belgium, Australia, Sweden, Denmark, Norway, Finland, Singapore, Poland and Turkey. Yelp had a monthly average of 86 million unique visitors in Q4 2012*. By the end of Q4 2012, Yelpers had written more than 36 million rich, local reviews, making Yelp the leading local guide for real word-of-mouth on everything from boutiques and mechanics to restaurants and dentists. Yelp's mobile application was used on 9.2 million unique mobile devices on a monthly average basis during Q4 2012.";
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    UIColor *color = UIColorFromRGB(0x005f69);
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSFontAttributeName : font,
                                NSForegroundColorAttributeName : color
                                };
    companyDetailTextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:attribute];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
