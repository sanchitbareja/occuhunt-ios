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
#import <MZFormSheetController/MZFormSheetController.h>
#import "AppDelegate.h"

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
   
    mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"852-map"] style:UIBarButtonItemStylePlain target:self action:@selector(showMap:)];
    listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"729-top-list"] style:UIBarButtonItemStylePlain target:self action:@selector(showList:)];
    locateButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Door"] style:UIBarButtonItemStylePlain target:self action:@selector(locateUser:)];
    checkInButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"722-location-pin"] style:UIBarButtonItemStylePlain target:self action:@selector(checkIn:)];
    
//    [self.navigationItem setRightBarButtonItems:@[checkInButton, locateButton]];

    //    UIView *titleView = [self createNavigationTitleViewWithTitle:@"Startup Fair" andSubtitle:@"Recreational Sports Facility"];
//    self.navigationItem.titleView = titleView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
    self.mainSearchBar.hidden = YES;
    
	// Map View
    CGRect toUseFrame = self.view.frame;
    toUseFrame.origin.y += 109;
    toUseFrame.size.height -= 109;
    
    self.mapScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
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
    self.mapScrollView.minimumZoomScale = 0.6;
    self.mapScrollView.maximumZoomScale = 5.0;
    self.mapScrollView.tag = 123;
    [self.mapView addSubview:self.mapScrollView];
    [self.mapScrollView addSubview:_collectionView];
    
    // List View
    filteredCompanies = [[NSMutableArray alloc] init];
    self.companyTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.companyTableView.delegate = self;
    self.companyTableView.dataSource = self;
    [self.companyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.listView addSubview:self.companyTableView];
}

- (void)parseData:(NSData *)returnedData{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:returnedData //1
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"json: %@", json); //3
    
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
    [filteredCompanies removeAllObjects];
    for (NSDictionary *eachCoy in companies) {
        if ([[eachCoy objectForKey:@"coy_name"] length] > 0) {
            [filteredCompanies addObject:eachCoy];
        }
    }
    [self.companyTableView reloadData];
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

- (void)changeMapOrListView:(int)input {
    switch (input) {
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

#pragma mark - Bar Button Items Methods

- (IBAction)showMap:(id)sender {
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
    [self.navigationItem setRightBarButtonItems:@[checkInButton, locateButton, listButton]];
}

- (IBAction)showList:(id)sender {
    self.mapView.hidden = YES;
    self.listView.hidden = NO;
    [self.navigationItem setRightBarButtonItems:@[checkInButton, locateButton, mapButton]];
}

- (IBAction)locateUser:(id)sender {
    
}

- (IBAction)checkIn:(id)sender {
    
}

# pragma mark - UINavigationBar Title and Subtitle 

- (UIView *)createNavigationTitleViewWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle {
    
    if (subtitle == nil) {
        subtitle = @"";
    }
    
    const NSInteger leftOffset = 15;
    
    // Replace titleView.
    UIView *headerTitleSubtitleView                = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, 0, 200, 44)];
    headerTitleSubtitleView.backgroundColor        = [UIColor clearColor];
    headerTitleSubtitleView.autoresizesSubviews    = YES;
    
    CGRect frame = [subtitle isEqualToString:@""] ? CGRectMake(leftOffset, 0, 160, 44) : CGRectMake(leftOffset, 2, 160, 24);
    UILabel *titleView    = [[UILabel alloc] initWithFrame:frame];
    titleView.backgroundColor            = [UIColor clearColor];
    titleView.font                        = [UIFont boldSystemFontOfSize:19];
    titleView.textAlignment                = NSTextAlignmentCenter;
    titleView.textColor                    = [UIColor blackColor];
    titleView.text                        = title;
    titleView.adjustsFontSizeToFitWidth    = YES;
    titleView.minimumScaleFactor        = 0;
    titleView.lineBreakMode                = NSLineBreakByTruncatingMiddle;
    [headerTitleSubtitleView addSubview:titleView];
    
    // If subtitle is not empty...
    if (![subtitle isEqualToString:@""]) {
        UILabel *subtitleView = [[UILabel alloc] initWithFrame:CGRectMake(leftOffset, 24, 160, 44-24)];
        subtitleView.backgroundColor            = [UIColor clearColor];
        subtitleView.font                        = [UIFont systemFontOfSize:13];
        subtitleView.textAlignment                = NSTextAlignmentCenter;
        subtitleView.textColor                    = [UIColor blackColor];
        subtitleView.text                        = subtitle;
        subtitleView.adjustsFontSizeToFitWidth    = YES;
        subtitleView.minimumScaleFactor            = 4;
        subtitleView.lineBreakMode                = NSLineBreakByTruncatingMiddle;
        [headerTitleSubtitleView addSubview:subtitleView];
    }
    
    return headerTitleSubtitleView;
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
    if ([[[self.collectionView cellForItemAtIndexPath:indexPath] contentView] viewWithTag:100]){
        UILabel *theLabel = (UILabel *)[[[self.collectionView cellForItemAtIndexPath:indexPath] contentView] viewWithTag:100];
        if (theLabel.text.length < 1) {
            return;
        }
    }
    NSLog(@"I tapped");
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CompanyViewController"];
    MZFormSheetController *mzv = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 410) viewController:vc];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:10.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    mzv.transitionStyle = MZFormSheetTransitionStyleFade;
    mzv.shouldDismissOnBackgroundViewTap = YES;
    [mzv presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return filteredCompanies.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [[filteredCompanies objectAtIndex:(indexPath.row)] objectForKey:@"coy_name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.companyTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"I tapped in list");
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CompanyViewController"];
    MZFormSheetController *mzv = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 410) viewController:vc];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:10.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    mzv.transitionStyle = MZFormSheetTransitionStyleFade;
    mzv.shouldDismissOnBackgroundViewTap = YES;
    [mzv presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];

}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */


@end
