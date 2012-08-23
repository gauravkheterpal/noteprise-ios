//
//  ChatterGroupVCntrlViewController.m
//  Noteprise
//
//  Created by Gaurav on 20/08/12.
//
//

#import "ChatterGroupVCntrlViewController.h"
#import "Utility.h"
@interface ChatterGroupVCntrlViewController ()

@end

@implementation ChatterGroupVCntrlViewController
@synthesize noteContent,noteTitle,chatterGroupArray,selectedImage,unselectedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
    selectedUserIndex=-999;
    // create a toolbar where we can place some buttons
    [self initToolbarButtons];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Chatter Groups";
    self.selectedImage = [UIImage imageNamed:@"btnChecked.png"];
	self.unselectedImage = [UIImage imageNamed:@"btnUnchecked.png"];
    [loadingSpinner startAnimating];
    [Utility showCoverScreen];
    backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self changeBkgrndImgWithOrientation];
    self.chatterGroupArray = [[NSArray alloc]init];
    UIBarButtonItem *postToChatterGroupButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postToSelectedChatterGroups)];
    //[postToChatterGroupButton release];
    self.navigationItem.rightBarButtonItem = postToChatterGroupButton;
    [self fetchListOfChatterGroup];

}
-(void)changeBkgrndImgWithOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-480x287.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-320x480.png"];
        }
    } else {
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-1024x704.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-768x1024.png"];
        }
    }
}
-(void)fetchListOfChatterGroup {
    
    NSString * path = @"v23.0/chatter/groups";
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [chatterGroupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    //if you want to add an image to your cell, here's how
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
	UIImage *image = [UIImage imageNamed:@"Settings.png"];
    cell.imageView.image = image;
    
	// Configure the cell to show the data.
	NSDictionary *chatterGroupObj = [chatterGroupArray objectAtIndex:indexPath.row];
    DebugLog(@"chatterUserobj:%@",chatterGroupObj);
    DebugLog(@"chatterUserobj name:%@",[chatterGroupObj valueForKey:@"name"]);
    cell.textLabel.text = [chatterGroupObj valueForKey:@"name"];
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

        selectedUserIndex=indexPath.row;
        DebugLog(@"sel obj:%@",[self.chatterGroupArray objectAtIndex:indexPath.row]);
}
-(void)showLoadingLblWithText:(NSString*)Loadingtext{
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = Loadingtext;
    loadingLbl.hidden = NO;
}
-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    doneImgView.hidden = YES;
    [loadingSpinner stopAnimating];
    //[delegate evernoteCreatedSuccessfullyListener];
}
#pragma mark - SFRestAPIDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);
    
    if([[request path] rangeOfString:@"v23.0/chatter/groups"].location != NSNotFound){
        //List of following
        if([[jsonResponse objectForKey:@"errors"] count] == 0){
            [Utility hideCoverScreen];
            [loadingSpinner stopAnimating];
            NSArray *records = [jsonResponse objectForKey:@"groups"];
            //NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            self.chatterGroupArray = records; //[records sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            [self initializeSelectedRow];
            chatterGroupTbl.delegate = self;
            chatterGroupTbl.dataSource = self;
            [chatterGroupTbl reloadData];
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            
        }
        else{
            [loadingSpinner stopAnimating];
            [Utility showAlert:@"Problem in Listing to Chatter Users."];
            [Utility hideCoverScreen];
        }
        
    }
    else {
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            
            [loadingSpinner stopAnimating];
            doneImgView.hidden = NO;
            [self showLoadingLblWithText:@"Done!"];
            [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
            //[Utility showAlert:@"Note successfully saved to Salesforce!"];
            
            [loadingSpinner stopAnimating];
        }
        else{
            [loadingSpinner stopAnimating];
            [self showLoadingLblWithText:@"Posting to Chatter Users failed"];
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideToastMsg:) userInfo:nil repeats:NO];
            //[Utility showAlert:@"Problem in mapping Evernote with Salesforce Object."];
        }
        [Utility hideCoverScreen];
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
    [Utility hideCoverScreen];
    [loadingSpinner stopAnimating];
    [self hideDoneToastMsg:nil];
    //add your failed error handling here
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error.userInfo valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [loadingSpinner stopAnimating];
    [self hideDoneToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
}

-(void)initializeSelectedRow {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[chatterGroupArray count]];
    for (int i=0; i < [chatterGroupArray count]; i++)
        [array addObject:[NSNumber numberWithBool:NO]];
    selectedGroupsRow = array;
    NSLog(@"Array = %@",selectedGroupsRow);
}

-(void)initToolbarButtons {
    UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 70, 45)];
    [toolbar setBarStyle: UIBarStyleBlackTranslucent];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:4];

     UIBarButtonItem *addButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postToSelectedChatterGroups)];
    [buttons addObject:addButton];
    [addButton release];
    // create a spacer between the buttons
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                target:nil
                                action:nil];
    [buttons addObject:spacer1];
    [spacer1 release];
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
    [buttons release];
    
    // place the toolbar into the navigation bar
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithCustomView:toolbar] autorelease];
    [toolbar release];
    
}

-(void)postToSelectedChatterGroups {
    if([Utility checkNetwork]) {
        NSMutableArray *paramArr = [[NSMutableArray alloc]init];
        NSDictionary *textParam = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",self.noteContent, @"text",nil];
        NSString * path = [NSString stringWithFormat:@"v23.0/chatter/feeds/record/%@/feed-items",[[self.chatterGroupArray objectAtIndex:selectedUserIndex] valueForKey:@"id"]];
        NSLog(@"test url for group feed: %@",path); 
        
         if(selectedUserIndex == -999) {   
                [Utility hideCoverScreen];
                [Utility showAlert:@"Please select a group to make Chatter Post"];
        } else {
                    [self showLoadingLblWithText:@"Posting Note to Chatter Group..."];
                    [paramArr addObject:textParam];
                    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:paramArr,@"messageSegments", nil];
                    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
                    
                    NSLog(@"Body = %@",body);
                    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
                    [[SFRestAPI sharedInstance] send:request delegate:self];
                    }
                }
        
         else {
                [Utility showAlert:@"Network Unavailable!Network connection is needed for this action."];
         }
}

@end
