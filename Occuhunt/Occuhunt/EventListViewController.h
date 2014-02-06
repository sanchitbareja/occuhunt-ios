//
//  EventListViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/2/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerIO.h"

@interface EventListViewController : UITableViewController <ServerIODelegate>{
    ServerIO *thisServer;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, strong) NSArray *listOfEvents;

@end
