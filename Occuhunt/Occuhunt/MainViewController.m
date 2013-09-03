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
    self.mapScrollView.contentSize = self.mapImageView.image.size;
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
    return self.mapImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"im scrolling");
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"im zooming");
}

@end
