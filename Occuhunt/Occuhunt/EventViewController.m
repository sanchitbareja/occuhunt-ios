//
//  MainViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import "EventViewController.h"
#import "DrawView.h"
#import "PulsingHaloLayer.h"
#import <MZFormSheetController/MZFormSheetController.h>
#import "AppDelegate.h"
#import "CompanyViewController.h"
#import <SSKeychain/SSKeychain.h>
#import <QuartzCore/QuartzCore.h>
#import "SharpLabel.h"

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
//    checkInButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"722-location-pin"] style:UIBarButtonItemStylePlain target:self action:@selector(checkIn:)];
    
//    [self.navigationItem setRightBarButtonItems:@[checkInButton, locateButton]];

    //    UIView *titleView = [self createNavigationTitleViewWithTitle:@"Startup Fair" andSubtitle:@"Recreational Sports Facility"];
//    self.navigationItem.titleView = titleView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Selected Fair" properties:@{
                                                  @"fair": [self.theCurrentFair objectForKey:@"name"]
                                                      }];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"my map is %@", self.mapID);
    
    if (self.mapID.length == 0) {
        return;
    }
    
    [self mapNewRoom];
    
    if (self.listOfRooms.count < 2) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    CGRect myView = self.view.frame;
    myView.size.height -= 94;
    myView.origin.y += 30;
    
    self.filteredCompanyList = [NSMutableArray arrayWithCapacity:50];
    [self.searchDisplayController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
	// Map View
    
    self.mapScrollView = [[UIScrollView alloc] initWithFrame:myView];
    
    self.mapScrollView.delegate = self;
    self.mapScrollView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    _collectionView.scrollEnabled = NO;
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.userInteractionEnabled = YES;
    self.mapScrollView.contentSize = CGSizeMake(600, 1200);
    self.mapScrollView.minimumZoomScale = 0.6;
    self.mapScrollView.maximumZoomScale = 5.0;
    self.mapScrollView.tag = 123;
    [self.mapView addSubview:self.mapScrollView];
    [self.mapView sendSubviewToBack:self.mapScrollView];
    [self.mapScrollView addSubview:_collectionView];
    
    // List View
    filteredCompanies = [[NSMutableArray alloc] init];
    self.companyTableView = [[UITableView alloc] initWithFrame:myView];
    self.companyTableView.delegate = self;
    self.companyTableView.dataSource = self;
    [self.companyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.listView addSubview:self.companyTableView];
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:10.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
}

- (void)mapNewRoom {
    // Empty all arrays
//    [filteredCompanies removeAllObjects];
//    companies = [[NSArray alloc] init];
//    [self.filteredCompanyList removeAllObjects];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://occuhunt.com/static/faircoords/%@.json", self.mapID]]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error || data == (id)[NSNull null] || [data length] == 0) {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, we were unable to retrieve the map. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                   [alert show];
                               }
                               else {
                                   [self performSelectorOnMainThread:@selector(parseData:)
                                                          withObject:data waitUntilDone:YES];
                               }
                           }];
    
    
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
    self.mainSearchBar.hidden = YES;
    
    
    // Reload all tables
    [self.collectionView reloadData];
    [self.companyTableView reloadData];
    
    [self performSelector:@selector(logAllFrames) withObject:nil afterDelay:3.0];
}

- (void)logAllFrames {
    NSLog(@"Collection View Frame %@", NSStringFromCGRect(self.collectionView.frame));
    NSLog(@"Scroll View Frame %@", NSStringFromCGRect(self.mapScrollView.frame));
    NSLog(@"Scroll View Content Size %@", NSStringFromCGSize(self.mapScrollView.contentSize));
//    self.mapScrollView.contentSize = CGSizeMake(1000, 1000);
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
        NSLog(@"Setting up map");
        numberOfRows = [[json objectForKey:@"rows"] intValue];
        numberOfColumns = [[json objectForKey:@"cols"] intValue];
        companies = [json objectForKey:@"coys"];
        
        numberOfBlankRows = [[json objectForKey:@"blank_rows"] intValue];
        numberOfBlankColumns = [[json objectForKey:@"blank_columns"] intValue];
        self.roomLabel.text = [json objectForKey:@"room_name"];
        
        int numberOfNotBlankRows = numberOfRows-numberOfBlankRows;
        int numberOfNotBlankColumns = numberOfColumns-numberOfBlankColumns;
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, 50*numberOfNotBlankColumns+30*numberOfBlankColumns, 50*numberOfNotBlankRows+30*numberOfBlankRows);
//        self.mapScrollView.zoomScale = 1.5;
//        self.mapScrollView.contentOffset = CGPointMake(0, 0);
        self.mapScrollView.contentSize = self.collectionView.frame.size;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, we were unable to retrieve the map. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    [self.collectionView reloadData];
    [filteredCompanies removeAllObjects];
    NSMutableArray *listOfNames = [[NSMutableArray alloc] init];
    for (NSDictionary *eachCoy in companies) {
        if ([[eachCoy objectForKey:@"coy_name"] length] > 0 && ![listOfNames containsObject:[eachCoy objectForKey:@"coy_name"]]) {
            [filteredCompanies addObject:eachCoy];
            [listOfNames addObject:[eachCoy objectForKey:@"coy_name"]];
        }
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"coy_name" ascending:YES];
    filteredCompanies = [[filteredCompanies sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] mutableCopy];

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

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // fair id_ room_id
    NSLog(@"button index %i", buttonIndex);
    if (buttonIndex == -1 || buttonIndex == 0) {
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        return;
    }
    if (buttonIndex > self.listOfRooms.count) {
        return;
    }
    self.mapScrollView.zoomScale = 1.0;
    int roomID = [[[self.listOfRooms objectAtIndex:buttonIndex-1] objectForKey:@"id"] intValue];
    self.mapID = [NSString stringWithFormat:@"%@_%i", self.fairID, roomID];
    NSLog(@"self.map id is %@", self.mapID);
    [self mapNewRoom];
}

#pragma mark - Navigation Bar / Toolbar Methods

- (IBAction)segmentedValueChanged:(id)sender {
    switch (self.mapListSegmentedControl.selectedSegmentIndex) {
        case 0:
            [self showMap:nil];
            break;
        case 1:
            [self showList:nil];
            break;
            
        default:
            break;
    }
}

- (IBAction)showMap:(id)sender {
    self.mapView.hidden = NO;
    self.listView.hidden = YES;
}

- (IBAction)showList:(id)sender {
    self.mapView.hidden = YES;
    self.listView.hidden = NO;
}

- (IBAction)showRooms:(id)sender {
    if (self.listOfRooms.count > 1) {
        UIAlertView *roomListAlert = [[UIAlertView alloc] initWithTitle:@"Venues" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        for (NSDictionary *eachRoom in self.listOfRooms) {
            [roomListAlert addButtonWithTitle:[eachRoom objectForKey:@"name"]];
        }
        roomListAlert.tag = 100;
        [roomListAlert show];
    }
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
    [self.collectionView.collectionViewLayout invalidateLayout];
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

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell viewWithTag:100]) {
        UILabel *companyName = (UILabel *)[cell viewWithTag:100];
        if ([companyName.text isEqualToString:@""]) {
            return;
        }
    }
    cell.backgroundColor = UIColorFromRGB(0xa4c8cb); // highlight selection
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell viewWithTag:100]) {
        UILabel *companyName = (UILabel *)[cell viewWithTag:100];
        if ([companyName.text isEqualToString:@""]) {
            return;
        }
    }
    cell.backgroundColor = UIColorFromRGB(0xeef7f7); // highlight selection
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    SharpLabel *companyName;
    if ([cell.contentView viewWithTag:100]) {
        companyName = (SharpLabel *) [cell.contentView viewWithTag:100];
    }
    else {
        companyName = [[SharpLabel alloc] initWithFrame:CGRectMake(2, 2, 46, 46)];
        companyName.tag = 100;
        companyName.textAlignment = NSTextAlignmentCenter;
        companyName.backgroundColor = [UIColor clearColor];
        companyName.font = [UIFont fontWithName:@"Proxima Nova" size:8];
        companyName.textColor = [UIColor blackColor];
        companyName.lineBreakMode = NSLineBreakByWordWrapping;
        companyName.numberOfLines = 0;
        
        CATiledLayer *tiledLayer = (CATiledLayer*)companyName.layer;
        tiledLayer.levelsOfDetail = 10;
        tiledLayer.levelsOfDetailBias = 10;
    }
    if (indexPath.row < companies.count) {
        companyName.text = [[companies objectAtIndex:(indexPath.row)] objectForKey:@"coy_name"];
    }
    else {
        companyName.text = @"";
    }
//    NSLog(@"company name %@", companyName.text);
    if ([companyName.text isEqualToString:@""]) {
        companyName.text = @"";
        cell.backgroundColor = [UIColor clearColor];
        cell.layer.borderColor = [[UIColor clearColor] CGColor];
        [cell.contentView addSubview:companyName];
    }
    else {
        cell.backgroundColor = UIColorFromRGB(0xeef7f7);
        cell.layer.borderColor = [UIColorFromRGB(0xadadad) CGColor];
        cell.layer.borderWidth = 0.5f;
        [cell.contentView addSubview:companyName];
    }
    if ([[[companies objectAtIndex:(indexPath.row)] objectForKey:@"blank_column"] intValue] == 1 || [[[companies objectAtIndex:(indexPath.row)] objectForKey:@"blank"] intValue] == 1){
        cell.backgroundColor = [UIColor clearColor];
        cell.layer.borderColor = [[UIColor clearColor] CGColor];
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
    
    // Highlight
    
    
    CompanyViewController *vc = (CompanyViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CompanyViewController"];
    if ([[companies objectAtIndex:indexPath.row] objectForKey:@"coy_id"]) {
        NSString *companyID = [NSString stringWithFormat:@"%@", [[companies objectAtIndex:indexPath.row] objectForKey:@"coy_id"]];
        vc.companyID = companyID;
        vc.fairID = self.fairID;
        vc.theCurrentFair = self.theCurrentFair;
    }
    MZFormSheetController *mzv = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 442) viewController:vc];
    mzv.transitionStyle = MZFormSheetTransitionStyleFade;
    mzv.shouldDismissOnBackgroundViewTap = YES;
    mzv.shouldCenterVertically = YES;
    mzv.shadowRadius = 2.0;
    mzv.shadowOpacity = 0.3;

    [self mz_presentFormSheetController:mzv animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        //do sth
    }];
//    [mzv presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
    
//    }];
    
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

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredCompanyList removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coy_id contains[c] %@",searchText];
    filteredCompanies = [NSMutableArray arrayWithArray:[filteredCompanies filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredCompanyList count];
    } else {
        return [filteredCompanies count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[filteredCompanies objectAtIndex:(indexPath.row)] objectForKey:@"coy_name"];
    }
    else {
        cell.textLabel.text = [[filteredCompanies objectAtIndex:(indexPath.row)] objectForKey:@"coy_name"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.companyTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"I tapped in list");
    CompanyViewController *vc = (CompanyViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CompanyViewController"];
    if ([[filteredCompanies objectAtIndex:indexPath.row] objectForKey:@"coy_id"]) {
        NSString *companyID = [NSString stringWithFormat:@"%@", [[filteredCompanies objectAtIndex:indexPath.row] objectForKey:@"coy_id"]];
        vc.companyID = companyID;
    }
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
