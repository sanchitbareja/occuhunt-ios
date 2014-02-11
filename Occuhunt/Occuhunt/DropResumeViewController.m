//
//  DropResumeViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/6/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "DropResumeViewController.h"
#import <SSKeychain/SSKeychain.h>

@interface DropResumeViewController ()

@end

@implementation DropResumeViewController

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
    
//    self.title = @"Pick Companies";
    if ((int)self.shouldShowClose == 1) {
        UIBarButtonItem *leftbbi = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        self.navigationItem.leftBarButtonItem = leftbbi;
    }
    
    UIBarButtonItem *rightbbi = [[UIBarButtonItem alloc] initWithTitle:@"Drop" style:UIBarButtonItemStylePlain target:self action:@selector(dropResume:)];
    self.navigationItem.rightBarButtonItem = rightbbi;
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.allowsMultipleSelection = NO;
    
    checkedCompanies = [[NSMutableArray alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"coy_name" ascending:YES];
    self.listOfCompanies = [self.listOfCompanies sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

    self.alphabetsArray = [[NSMutableArray alloc] init];
    [self createAlphabetArray];
    
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = (id)self.delegate;
}

- (void)close:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)dropResume:(id)sender {
    // Use checkedCompanies array to send up
    if (checkedCompanies.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have no companies selected." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSMutableArray *companyIDArray = [[NSMutableArray alloc] init];
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *eachIndexPath in checkedCompanies) {
        NSDictionary *eachCompany = [self.listOfCompanies objectAtIndex:eachIndexPath.row];
        NSLog(@"%@", eachCompany);
        [companyIDArray addObject:[eachCompany objectForKey:@"coy_id"]];
        [statusArray addObject:[NSNumber numberWithInteger:1]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Dropped Resume" properties:@{
                                                       @"company":[eachCompany objectForKey:@"coy_name"]
                                                       }];
    }

    NSString *userID = [SSKeychain passwordForService:@"OH" account:@"user_id"];
    [thisServer shareResumeWithMultipleRecruitersWithUserID:userID andFairID:self.fairID andCompanyIDs:companyIDArray andStatuses:statusArray];
    
    if (self.delegate) {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server IO Delegate Methods

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    }

- (void)returnFailure:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    
}

#pragma mark - Create Alphabet Array
- (void)createAlphabetArray {
    NSMutableArray *tempFirstLetterArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.listOfCompanies count]; i++) {
        NSString *letterString = [[[self.listOfCompanies objectAtIndex:i] objectForKey:@"coy_name"] substringToIndex:1];
        if (![tempFirstLetterArray containsObject:letterString]) {
            [tempFirstLetterArray addObject:letterString];
        }
    }
    self.alphabetsArray = tempFirstLetterArray;
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
    return self.listOfCompanies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([checkedCompanies indexOfObject:indexPath] != NSNotFound) {
        NSLog(@"Yeah this company's index is %i", indexPath.row);
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[self.listOfCompanies objectAtIndex:indexPath.row] objectForKey:@"coy_name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    if (theCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        theCell.accessoryType = UITableViewCellAccessoryNone;
        [checkedCompanies removeObject:indexPath];
    }
    else if (theCell.accessoryType == UITableViewCellAccessoryNone) {
        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [checkedCompanies addObject:indexPath];
    }
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    for (int i = 0; i< [self.listOfCompanies count]; i++) {
//        NSString *letterString = [[[self.listOfCompanies objectAtIndex:i] objectForKey:@"coy_name"] substringToIndex:1];
//        NSLog(@"letter string %@", letterString);
//        NSLog(@"letter title %@", title);
//        if ([letterString isEqualToString:title]) {
//            NSLog(@"indexpath row %i", [[NSIndexPath indexPathForRow:i inSection:0] row]);
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            break;
//        }
//    }
//    return 0;
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return self.alphabetsArray;
//}
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
