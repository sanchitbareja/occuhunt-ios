//
//  MainViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "EventViewController.h"
//#import "JASidePanelController.h"
//#import "UIViewController+JASidePanel.h"
//#import <AFNetworking/AFJSONRequestOperation.h>
#import "DrawView.h"
#import "PulsingHaloLayer.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface EventViewController ()

@end

@implementation EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Map";
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
    self.mainSearchBar.hidden = YES;
    
	// Map View
    CGRect toUseFrame = self.view.frame;
    toUseFrame.origin.y += 65;
    toUseFrame.size.height -= 65;
    
    self.mapScrollView = [[UIScrollView alloc] initWithFrame:toUseFrame];
    
    self.mapScrollView.delegate = self;
    self.mapScrollView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.userInteractionEnabled = YES;
    self.mapScrollView.contentSize = CGSizeMake(600, 800);
    self.mapScrollView.minimumZoomScale = 0.3;
    self.mapScrollView.maximumZoomScale = 5.0;
    self.mapScrollView.tag = 123;
    [self.view addSubview:self.mapScrollView];
    [self.mapScrollView addSubview:_collectionView];
    
    // Grid View
    
    UICollectionViewFlowLayout *layout2=[[UICollectionViewFlowLayout alloc] init];
    
    self.listCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 504) collectionViewLayout:layout2];
    [self.listView addSubview:self.listCollectionView];
    self.listCollectionView.backgroundColor = [UIColor clearColor];
    
    [self.listCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    [self.listCollectionView setDataSource:self];
    [self.listCollectionView setDelegate:self];
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = CGPointMake(380, 1060);
    [self.mapImageView.layer addSublayer:halo];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString:@"http://occuhunt.com/static/faircoords/2.json"]];
        if (data == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, we were unable to retrieve the map. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        [self performSelectorOnMainThread:@selector(parseData:)
                               withObject:data waitUntilDone:YES];
    });
    
}

- (void)parseData:(NSData *)returnedData{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:returnedData //1
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"loans: %@", json); //3
    
    if (json) {
        // Setup of Map
        numberOfRows = [[json objectForKey:@"rows"] intValue];
        numberOfColumns = [[json objectForKey:@"cols"] intValue];
        companies = [json objectForKey:@"coys"];
        
        numberOfBlankRows = [[json objectForKey:@"blank_rows"] intValue];
        numberOfBlankColumns = [[json objectForKey:@"blank_columns"] intValue];
        
        int numberOfNotBlankRows = numberOfRows-numberOfBlankRows;
        int numberOfNotBlankColumns = numberOfColumns-numberOfBlankColumns;
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, 50*numberOfNotBlankColumns+30*numberOfBlankColumns, 50*numberOfNotBlankRows+30*numberOfBlankRows);
        self.mapScrollView.zoomScale = 1.5;
        self.mapScrollView.contentOffset = CGPointMake(0, 0);
    }
    
    [self.collectionView reloadData];
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

//- (IBAction)openRightDrawer:(id)sender {
//    [self.sidePanelController showRightPanelAnimated:YES];
//}

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

# pragma mark - Scroll View Delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"Scrolled");
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    NSLog(@"Zoomed");
    NSLog(@"current zoom is %f", scrollView.zoomScale);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"my id is %i", scrollView.tag);
    if (scrollView.tag != 123) {
        return nil;
    }
    return self.collectionView;
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return numberOfColumns*numberOfRows;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    UILabel *companyName;
    if ([cell.contentView viewWithTag:100]) {
        companyName = (UILabel *) [cell.contentView viewWithTag:100];
    }
    else {
        companyName = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 46, 46)];
        companyName.tag = 100;
        companyName.textAlignment = NSTextAlignmentCenter;
        companyName.backgroundColor = [UIColor clearColor];
        companyName.font = [UIFont fontWithName:@"Open Sans" size:8];
        companyName.textColor = [UIColor whiteColor];
        companyName.lineBreakMode = NSLineBreakByWordWrapping;
        companyName.numberOfLines = 0;
    }
    int theNumber = (indexPath.row)*(indexPath.section);
    NSLog(@"the row is %i", indexPath.row);
    NSLog(@"the section is %i", indexPath.section);
    NSLog(@"the number is %i", theNumber);
    NSLog(@"companies count is %i", companies.count);
    if (indexPath.row < companies.count) {
        companyName.text = [[companies objectAtIndex:(indexPath.row)] objectForKey:@"coy_name"];
        
    }
    else {
        companyName.text = @"";
    }
    NSLog(@"company name %@", companyName.text);
    if ([companyName.text isEqualToString:@""]) {
        companyName.text = @"";
        cell.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:companyName];
    }
    else {
        cell.backgroundColor = [UIColor colorWithRed:122/255.0 green:167/255.0 blue:174/255.0 alpha:1.0];
        [cell.contentView addSubview:companyName];
    }
    if ([[[companies objectAtIndex:(indexPath.row)] objectForKey:@"blank_column"] intValue] == 1){
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[companies objectAtIndex:(indexPath.row)] objectForKey:@"blank_column"] intValue] == 1){
        return CGSizeMake(30, 50);
    }
    else if ([[[companies objectAtIndex:(indexPath.row)] objectForKey:@"blank_row"] intValue] == 1){
        return CGSizeMake(50, 30);
    }
    else {
        return CGSizeMake(50, 50);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"I tapped");
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;

}
# pragma mark - UISearchBar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self openSearchBar:nil];
    [self drawLine:nil];
    [searchBar resignFirstResponder];
}

@end
