//
//  MainViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 9/2/13.
//  Copyright (c) 2013 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ServerIO.h"

@interface EventViewController : UIViewController <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, ServerIODelegate, UIAlertViewDelegate> {
    // Event Map Details
    int numberOfRows;
    int numberOfColumns;
    int numberOfBlankRows;
    int numberOfBlankColumns;
    
    NSArray *companies;
    UIBarButtonItem *mapButton;
    UIBarButtonItem *listButton;
    UIBarButtonItem *locateButton;
    UIBarButtonItem *checkInButton;
    IBOutlet UIBarButtonItem *roomsButton;
    NSMutableArray *filteredCompanies; // no blank guys
    
    ServerIO *thisServer;
}
@property (nonatomic, strong) NSString *fairID;
@property (nonatomic, strong) NSString *mapID;
@property (nonatomic, strong) NSArray *listOfRooms;

@property IBOutlet UIView *mapView;
@property IBOutlet UIView *listView;

@property IBOutlet UIScrollView *mapScrollView;
@property UICollectionView *collectionView;
@property IBOutlet UIImageView *mapImageView;

@property IBOutlet UISegmentedControl *mapListSegmentedControl;
@property IBOutlet UISearchBar *mainSearchBar;
@property IBOutlet UIButton *drawLineButton;

@property UICollectionView *listCollectionView;
@property UITableView *companyTableView;
@property (strong,nonatomic) NSMutableArray *filteredCompanyList;

- (IBAction)segmentedValueChanged:(id)sender;
- (IBAction)checkIn:(id)sender;
- (IBAction)showRooms:(id)sender;

@end
