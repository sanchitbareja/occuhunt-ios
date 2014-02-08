//
//  DropResumeViewController.h
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/6/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropResumeViewController : UITableViewController {
    NSMutableArray *checkedCompanies;
    
}

@property (nonatomic, strong) NSArray *listOfCompanies;
@property (nonatomic, strong) NSMutableArray *alphabetsArray;
@property (nonatomic, weak) UIViewController *delegate;

@end
