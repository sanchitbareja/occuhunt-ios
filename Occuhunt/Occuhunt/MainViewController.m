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
	// Do any additional setup after loading the view.
    self.mapScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 504)];
    self.mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dccexhibitionhall"]];
    
    [self.mapView addSubview:self.mapScrollView];
    [self.mapScrollView addSubview:self.mapImageView];
    
    self.mapScrollView.contentSize = self.mapImageView.image.size;
	self.mapScrollView.maximumZoomScale = 4.0;
	self.mapScrollView.minimumZoomScale = 1;
    LOG_EXPR(self.mapScrollView.contentSize);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openRightDrawer:(id)sender {
    [self.sidePanelController showRightPanelAnimated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"lol");
    return self.mapImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"im scrolling");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"im zooming");
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

@end
