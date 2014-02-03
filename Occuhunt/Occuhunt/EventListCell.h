//
//  EventListCell.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/2/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *eventImage;
@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (nonatomic, strong) IBOutlet UILabel *eventTime;
@property (nonatomic, strong) IBOutlet UILabel *eventVenue;

@end
