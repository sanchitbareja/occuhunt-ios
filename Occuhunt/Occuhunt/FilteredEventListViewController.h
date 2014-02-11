//
//  FilteredEventListViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/10/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerIO.h"

@interface FilteredEventListViewController : UITableViewController <ServerIODelegate> {
    ServerIO *thisServer;
}

@property (nonatomic, strong) NSArray *listOfFilteredEvents;
@property (nonatomic, weak) UIViewController *delegate;

@end
