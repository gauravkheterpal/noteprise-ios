//
//  FieldsViewController.m
//  Noteprise
//
//  Created by Ritika on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FieldsViewController.h"

@interface FieldsViewController ()

@end

@implementation FieldsViewController
@synthesize objFields,noteContent,objectID,selectedObj,noteTitle,delegate;
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
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.PNG"]];
    [tempImageView setFrame:self.tableView.frame]; 
    
    self.tableView.backgroundView = tempImageView;
    [tempImageView release];
    self.title = @"Choose Field";
    DebugLog(@"objFields%@",objFields);

    selectedRowIndex =0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    DebugLog(@"field viewDidUnload:%@",[Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY]);
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [objFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
    //}
    // Configure the cell...
    cell.textLabel.text = [[objFields objectAtIndex:indexPath.row]valueForKey:@"label"];
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sfobjFieldToMapWith = [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
    DebugLog(@"sfobjFieldToMapWith:%@\n objFields:%@",sfobjFieldToMapWith,[objFields objectAtIndex:indexPath.row]);
    cell.textLabel.textColor = [UIColor whiteColor];
    if(sfobjFieldToMapWith != nil) {
        if([[[objFields objectAtIndex:indexPath.row]valueForKey:@"name"] isEqualToString:[sfobjFieldToMapWith valueForKey:@"name"]])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRowIndex = indexPath.row;
    //[tableView reloadData];
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentsfObj = [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
    
    if (currentsfObj != nil) {
		NSInteger index = [objFields indexOfObject:currentsfObj];
		NSIndexPath *selectionIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
        checkedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    DebugLog(@"obj%@",[objFields objectAtIndex:indexPath.row]);
    // Set the checkmark accessory for the selected row.
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    NSDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[objFields objectAtIndex:indexPath.row]valueForKey:@"name"],@"name",[[objFields objectAtIndex:indexPath.row]valueForKey:@"label"],@"label", nil];
    [stdDefaults setObject:dict forKey:SFOBJ_FIELD_TO_MAP_KEY];
    [stdDefaults synchronize];
    [dict release];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self.navigationController dismissModalViewControllerAnimated:YES];
    else {
        [delegate dissmissPopover];
    }
}
#pragma mark - SFRestAPIDelegate
#import "Utility.h"
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);
    [Utility hideCoverScreen];
}
- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
    [Utility hideCoverScreen];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}
-(void)dealloc {
        DebugLog(@"field viewDidUnload:%@",[Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY]);
    [super dealloc];
}
@end
