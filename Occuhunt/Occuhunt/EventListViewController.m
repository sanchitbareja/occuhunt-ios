//
//  EventListViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/2/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "EventListViewController.h"
#import "EventViewController.h"
#import "EventListCell.h"
#import "PortfolioViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EventListViewController ()

@end

@implementation EventListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventListCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"EventListCell"];
    
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = self;
    
    dateFormatter = [[NSDateFormatter alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [thisServer getFairs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server IO Delegate

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    if (operation.tag == GETFAIRS) {
        self.listOfEvents = [response objectForKey:@"objects"];
        [self.tableView reloadData];
    }
}

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    
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
    return self.listOfEvents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventListCell";
    EventListCell *cell = (EventListCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *currentEvent = [self.listOfEvents objectAtIndex:indexPath.row];
    
    [cell.eventImage setImageWithURL:[NSURL URLWithString:[currentEvent objectForKey:@"logo"]] placeholderImage:[UIImage imageNamed:@"Favicon4.png"]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *startDate = [dateFormatter dateFromString:[currentEvent objectForKey:@"time_start"]];
    NSDate *endDate = [dateFormatter dateFromString:[currentEvent objectForKey:@"time_end"]];
    [dateFormatter setDateFormat:@"MMMM d yyyy', 'HHa"];
    NSMutableString *dateString = [NSMutableString stringWithString:[dateFormatter stringFromDate:startDate]];
    [dateFormatter setDateFormat:@"' - 'ha"];
    [dateString appendString:[dateFormatter stringFromDate:endDate]];
    cell.eventTime.text = dateString;
    cell.eventVenue.text = [[[currentEvent objectForKey:@"rooms"] objectAtIndex:0] objectForKey:@"name"];
    cell.eventTitle.text = [currentEvent objectForKey:@"name"];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    EventViewController *vc = (EventViewController *) [storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    
    NSDictionary *currentEvent = [self.listOfEvents objectAtIndex:indexPath.row];
    int eventID = [[currentEvent objectForKey:@"id"] intValue];
    int roomID = [[[[currentEvent objectForKey:@"rooms"] objectAtIndex:0] objectForKey:@"id"] intValue];
    vc.fairID = [NSString stringWithFormat:@"%i", eventID];
    vc.mapID = [NSString stringWithFormat:@"%i_%i", eventID, roomID];
    vc.listOfRooms = [[currentEvent objectForKey:@"rooms"] copy];
    
    self.hidesBottomBarWhenPushed = YES;
    
    
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
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
