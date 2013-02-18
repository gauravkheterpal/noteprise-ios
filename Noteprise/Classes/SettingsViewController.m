//
//  SettingsViewController.m
//  Noteprise
//
//  Created by Ritika on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "SFObjsViewController.h"
#import "Utility.h"
#import "FieldsViewController.h"
@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize dataRows,popover_delegate;
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
    self.title = @"Salesforce Mapping";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
    
    //if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    //    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1]];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Select_note_bcg.png"]];
    [tempImageView setFrame:self.tableView.frame]; 
    
    self.tableView.backgroundView = tempImageView;
    [tempImageView release];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
    }
    // Configure the cell...
    int row = [indexPath section];
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    
    /*if(sfObj == nil){
        [Utility setSFDefaultMappingValues];
    }
    sfObj = [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];*/

    if(row == 0) {
        cell.textLabel.text = @"Object";
        NSDictionary *sfObj = [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];
        if(sfObj != nil)
            cell.detailTextLabel.text = [sfObj valueForKey:OBJ_LABEL];
        else {
            cell.detailTextLabel.text = @"";
        }
            
    }
    else {
        cell.textLabel.text = @"Field";
        NSDictionary *sfObjField = [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
        if(sfObjField != nil)
            cell.detailTextLabel.text = [sfObjField valueForKey:FIELD_LABEL];
        else {
            cell.detailTextLabel.text = @"";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    int row = [indexPath section];
    if(row == 0){
        [self fetchSFObjects];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self listMetadataForObj];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
-(void)fetchSFObjects{
    if([Utility checkNetwork]) {
        self.tableView.userInteractionEnabled = NO;
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForDescribeGlobal]; 
        [[SFRestAPI sharedInstance] send:request delegate:self];
    } else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
    
}
-(void)listMetadataForObj{
    if([Utility checkNetwork]) {
        NSString *sfObjtoMap;
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        sfObjtoMap = [[stdDefaults valueForKey:SFOBJ_TO_MAP_KEY]valueForKey:OBJ_NAME];
        if (sfObjtoMap == nil) {
            [Utility showAlert:SF_OBJECT_MISSING_MSG];
        }
        if(sfObjtoMap) {
            self.tableView.userInteractionEnabled = NO;
            SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:sfObjtoMap];
            [[SFRestAPI sharedInstance] send:request delegate:self];
        }
    } else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}
#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    DebugLog(@"request:%@ path:%@",[request description],request.path);
    DebugLog(@"jsonResponse:%@",jsonResponse);
    self.tableView.userInteractionEnabled = YES;
    if([[request path] isEqualToString:@"/v23.0/sobjects"]){
        //returned all sobjects
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            NSArray *records = [jsonResponse objectForKey:@"sobjects"];
            //DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
          
            NSMutableArray *updateableObjArray = [[NSMutableArray alloc]init];
            for (NSDictionary *record in records) {
                if([[record valueForKey:@"triggerable"] boolValue] == true &&
                   [[record valueForKey:@"searchable"] boolValue] == true &&
                   [[record valueForKey:@"queryable"] boolValue] == true 
                   )
                
                //if([[record valueForKey:@"layoutable"] boolValue] == true )
                 {
                    [updateableObjArray addObject:record];
                }
            }
             DebugLog(@"ARRAY count %d",[records count]);
            //DebugLog(@"UPDATABLE ARRAY count %d",[updateableObjArray count]);
            
            SFObjsViewController *sfObjs = [[SFObjsViewController alloc]init];
            sfObjs.delegate = popover_delegate;
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:OBJ_NAME  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            updateableObjArray = [updateableObjArray sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor,nil]];
            sfObjs.sfObjsList = updateableObjArray ;
            //DebugLog(@"records:%@", sfObjs.sfObjsList);
            sfObjs.title = @"Choose Object";
            [self.navigationController pushViewController:sfObjs animated:YES];
        }
        else{
            [Utility showAlert:ERROR_LISTING_SFOBJECTS_MSG];
            [Utility hideCoverScreen];
        }
        
        
    }
    else if ([[request path] rangeOfString:@"describe"].location != NSNotFound) {
        //retrive all fields
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            NSArray *fields = [jsonResponse objectForKey:@"fields"];
            DebugLog(@"request:didLoadResponse: #fields: %d records %@ req %@ rsp %@", fields.count,fields,request,jsonResponse);
            NSMutableArray *fieldsRows = [[NSMutableArray alloc]init];
            for (NSDictionary *field in fields) {
                if([[field valueForKey:@"type"]isEqualToString:@"string"]||[[field valueForKey:@"type"]isEqualToString:@"textarea"]){
                    if ([[field valueForKey:@"updateable"] boolValue] == true) {
                         [fieldsRows addObject:field];
                    }
                   
                }
            }
            
            FieldsViewController *fieldsVCntrl = [[FieldsViewController alloc]init];
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:FIELD_LABEL  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            fieldsRows = [[fieldsRows sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
            fieldsVCntrl.objFields = fieldsRows;
            fieldsVCntrl.delegate = popover_delegate;
            [self.navigationController pushViewController:fieldsVCntrl animated:YES];
        }
        else{
            [Utility showAlert:ERROR_LISTING_SFOBJECT_METADATA_MSG];
            [Utility hideCoverScreen];
        }
    }

    else{
        [Utility hideCoverScreen];
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
        self.tableView.userInteractionEnabled = YES;
    //add your failed error handling here
    //add your failed error handling here
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo valueForKey:@"message"] delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
        self.tableView.userInteractionEnabled = YES;
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
        self.tableView.userInteractionEnabled = YES;
    //add your failed error handling here
}
-(void)dismissPopover {
    [popover_delegate dissmissPopover];
}
@end
