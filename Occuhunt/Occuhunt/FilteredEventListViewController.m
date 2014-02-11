//
//  FilteredEventListViewController.m
//  Occuhunt
//
//  Created by Sidwyn Koh on 2/10/14.
//  Copyright (c) 2014 Sidwyn Koh. All rights reserved.
//

#import "FilteredEventListViewController.h"
#import "DropResumeViewController.h"

@interface FilteredEventListViewController ()

@end

@implementation FilteredEventListViewController

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

    UIBarButtonItem *leftbbi = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = leftbbi;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.allowsMultipleSelection = NO;
    
    self.title = @"Upcoming Fairs";
    thisServer = [[ServerIO alloc] init];
    thisServer.delegate = self;
    
}

- (void)close:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Server IO Delegate

- (void)returnData:(AFHTTPRequestOperation *)operation response:(NSDictionary *)response {
    
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
    return self.listOfFilteredEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.listOfFilteredEvents objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DropResumeViewController *drvc = [[DropResumeViewController alloc] init];
    NSDictionary *theFair = [self.listOfFilteredEvents objectAtIndex:indexPath.row];
    
    drvc.title = [theFair objectForKey:@"name"];
    drvc.fairID = [[theFair objectForKey:@"id"] intValue];
    drvc.delegate = self.delegate;
    
    [[NSUserDefaults standardUserDefaults] setObject:theFair forKey:@"favoriteFair"];
    
    NSString *theID = [NSString stringWithFormat:@"%i", [[theFair objectForKey:@"id"] intValue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://occuhunt.com/static/faircoords/%@.json", theID]]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error || data == (id)[NSNull null] || [data length] == 0) {
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, we were unable to retrieve the list of companies. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                   [alert show];
                               }
                               else {
                                   NSError* error;
                                   NSDictionary* json = [NSJSONSerialization
                                                         JSONObjectWithData:data //1
                                                         options:kNilOptions
                                                         error:&error];
                                   
                                   NSLog(@"json: %@", json); //3
                                   
                                   drvc.listOfCompanies = [json objectForKey:@"coys"];
                                   
                                   [self.navigationController pushViewController:drvc animated:YES];
                               }
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
