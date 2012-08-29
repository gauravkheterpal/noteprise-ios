//
//  ChatterUsersViewController.m
//  Noteprise
//
//  Created by Ritika on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChatterUsersViewController.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "IconDownloader.h"
#import "ChatterRecord.h"
@interface ChatterUsersViewController ()

@end

@implementation ChatterUsersViewController
@synthesize noteContent,noteTitle,chatterUsersArray,inEditMode,selectedImage,unselectedImage,imageDownloadsInProgress;

-(void)initializeSelectedRow {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[chatterUsersArray count]];
    for (int i=0; i < [chatterUsersArray count]; i++)
        [array addObject:[NSNumber numberWithBool:NO]];
    selectedUsersRow = array;
}
-(void)initToolbarButtons {
    UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 125, 45)];
    [toolbar setBarStyle: UIBarStyleBlackTranslucent];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:4];
    UIBarButtonItem *editButton;
    if(!self.inEditMode)
        editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditMode)];
    else 
        editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toggleEditMode)];
    [buttons addObject:editButton];
    [editButton release];
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    UIBarButtonItem *addButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postToSelectedChatterUsers)];
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
-(void)viewDidAppear:(BOOL)animated{
    selectedUserIndex=-999;
    // create a toolbar where we can place some buttons
    [self initToolbarButtons];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Chatter Users";
    //[loadingSpinner startAnimating];
    [Utility showCoverScreen];
    backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self changeBkgrndImgWithOrientation];
    self.chatterUsersArray = [[NSMutableArray alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self fetchListOfFollowingRecords];
    self.inEditMode = NO;
	self.selectedImage = [UIImage imageNamed:@"btnChecked.png"];
	self.unselectedImage = [UIImage imageNamed:@"btnUnchecked.png"];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UILabel *bigLabel = [[UILabel alloc] init];
        bigLabel.text = self.title;
        [bigLabel setBackgroundColor:[UIColor clearColor]];
        [bigLabel setTextColor:[UIColor whiteColor]];
        
        bigLabel.font = [UIFont boldSystemFontOfSize: 16.0];
        [bigLabel sizeToFit];
        self.navigationItem.titleView = bigLabel;
        [bigLabel release];

    }
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
-(IBAction)toggleEditMode{
	DebugLog(@"toggleEditMode");
	self.inEditMode = !self.inEditMode;
    self.navigationItem.rightBarButtonItem = nil;
    [self initToolbarButtons];
    if(!self.inEditMode)
        [self initializeSelectedRow];
    
	[chatterUsersTbl reloadData];
}
-(void)fetchListOfFollowingRecords {
    [Utility showCoverScreen];
    [self showLoadingLblWithText:progress_dialog_chatter_getting_following_data_message];
    NSString * path = LIST_OF_CHATTER_FOLLOWING_URL;
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}
-(void)postToSelectedChatterUsers {
    if([Utility checkNetwork]) {
        int selectedUsers = 0;
        for(NSNumber *userRow in selectedUsersRow){
            selectedUsers += ([userRow boolValue] == YES?1:0); //certain object is @"Apple"
        }
        DebugLog(@"occurrences%d",selectedUsers);
        if([self.noteContent length] > 1000){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Noteprise" message:CHATTER_LIMIT_CROSSED_ALERT_MSG delegate:self cancelButtonTitle:ALERT_NEGATIVE_BUTTON_TEXT otherButtonTitles:ALERT_POSITIVE_BUTTON_TEXT, nil];
            alert.tag = CHATTER_POST_LIMIT_ALERT_TAG;
            [alert show];
            [alert release];
        } else if (selectedUsers > 25) {
            [Utility showAlert:CHATTER_MENTIONS_CROSSED_ERROR_MSG];
        }
        else {
            [self createSFRequestToPostToSelectedChatterUsers:self.noteContent];
        } 
    }else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }

}
-(void)createSFRequestToPostToSelectedChatterUsers:(NSString*)evernoteContent
{
    NSString * path = POST_TO_CHATTER_WALL_URL;
    
    NSMutableArray *paramArr = [[NSMutableArray alloc]init];
    NSDictionary *textParam = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",evernoteContent, @"text",nil];
    if(self.inEditMode){
        for(int i = 0;i < [selectedUsersRow count] ; i++) {
            if ([[selectedUsersRow objectAtIndex:i] boolValue] == YES) {
                ChatterRecord *selectedRecord = (ChatterRecord*)[self.chatterUsersArray objectAtIndex:i];
                NSDictionary *mentionParam = [[NSDictionary alloc]initWithObjectsAndKeys:@"mention",@"type",selectedRecord.chatterId, @"id",nil];
                
                [paramArr addObject:mentionParam];
                [mentionParam release];
            }
        }
        
    } else {
        //----------------------------------------------------------------------------------------------------
        if(selectedUserIndex == -999) {   
            [Utility hideCoverScreen];
            [Utility showAlert:CHATTER_POST_USER_MISSING_MSG];
        } else {
            [self showLoadingLblWithText:POSTING_NOTE_TO_CHATTER_USER_MSG];
            ChatterRecord *selectedRecord = (ChatterRecord*)[self.chatterUsersArray objectAtIndex:selectedUserIndex];
            //DebugLog(@"chatter:%@",[[self.chatterUsersArray objectAtIndex:selectedUserIndex] valueForKey:@"subject"]);
            DebugLog(@"chatter id:%@",selectedRecord.chatterId);
            NSDictionary *mentionParam = [[NSDictionary alloc]initWithObjectsAndKeys:@"mention",@"type",selectedRecord.chatterId, @"id",nil];
            DebugLog(@"mentionParam:%@",mentionParam);
            [paramArr addObject:mentionParam];
            DebugLog(@"paramArr:%@",paramArr);
            [mentionParam release];
        }
    }
    [paramArr addObject:textParam];
    [textParam release];
    
    DebugLog(@"paramArr:%@",paramArr);
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:paramArr,@"messageSegments", nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    [paramArr release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG && alertView.cancelButtonIndex == buttonIndex) {
    } else if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG) {
        [Utility showCoverScreen];
        [self showLoadingLblWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG];
        //truncationg note text to 1000 character for posting to Chatter
        DebugLog(@"old length:%d", [self.noteContent length]);
        NSString *truncateNoteContent = [[self.noteContent substringToIndex:999]mutableCopy];
        DebugLog(@"new length:%d", [truncateNoteContent length]);
        [self createSFRequestToPostToSelectedChatterUsers:truncateNoteContent];
    }
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
    return [chatterUsersArray count];
}
- (UITableViewCell *) configRowFormat:(NSString *)cellIdentifier {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [chatterUsersTbl dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    //if you want to add an image to your cell, here's how
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
	UITableViewCell *customCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"folderCell"] autorelease];
	customCell.accessoryType = UITableViewCellAccessoryNone;
    CGRect nameLabelFrame;
    UIImageView *cellImg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unselected.png"]] autorelease];
    //cellImg.frame = CGRectMake(5.0, 5.0, 23.0, 23.0);
    cellImg.frame = CGRectMake(5, 5, 40, 34);
    [customCell.contentView addSubview:cellImg];
    cellImg.tag =  kCellImageViewTag;
    if(self.inEditMode) {
       if (self.interfaceOrientation == UIInterfaceOrientationPortrait||self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            nameLabelFrame = CGRectMake(84, 5, 236, 35);//portrait iPhone in Edit
        }
        else{
            nameLabelFrame = CGRectMake(84, 5, 390, 35);//landscape iPhone in Edit
        }
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait||self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            nameLabelFrame = CGRectMake(54, 5, 266, 35);//portrait iPhone not Edit
        }
        else{
            nameLabelFrame = CGRectMake(54, 5, 420, 35);//landscape iPhone not Edit
        }
    }
	//Initialize Label with tag 1.
    UILabel *namelabel = [[[UILabel alloc] initWithFrame:nameLabelFrame] autorelease];
    namelabel.font = [UIFont boldSystemFontOfSize:16];
    namelabel.tag = kCellLabelTag;
    namelabel.backgroundColor = [UIColor clearColor];
    [customCell.contentView addSubview:namelabel];
	return customCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   UITableViewCell *cell =  [self configRowFormat:@"Cell"];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
	NSNumber *selectedUser = [selectedUsersRow objectAtIndex:indexPath.row];

	UIImage *image = [UIImage imageNamed:@"Settings.png"];
    UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:kCellLabelTag];
    // Configure the cell to show the data.
    cell.imageView.image = imageView.image = ([selectedUser boolValue]) ? self.selectedImage : self.unselectedImage;
	cell.contentView.alpha = 1.0;
    if(self.inEditMode) {
        NSNumber *selectedForChatterPost = [selectedUsersRow objectAtIndex:indexPath.row];
        if([selectedForChatterPost boolValue]) 
            cell.imageView.image = self.selectedImage;
        else {
            cell.imageView.image = self.unselectedImage;
        }
    }
    else 
        cell.imageView.image = image;

    ChatterRecord *chatterUser = [chatterUsersArray objectAtIndex:indexPath.row];

    DebugLog(@"chatterUserobj:%@",chatterUser);
    DebugLog(@"chatterUserobj name:%@ id=%@",chatterUser.chatterName,chatterUser.chatterId);
    nameLabel.text = chatterUser.chatterName;
    if (self.inEditMode) {
        
		
            imageView.frame=CGRectMake(40, 5, 40, 34);
        
	} else {
        
		
            imageView.frame=CGRectMake(5, 5, 40, 34);
		cell.imageView.image=NULL;
        
	}
    // Only load cached images; defer new downloads until scrolling ends
    if (!chatterUser.chatterIcon)
    {
        if (chatterUsersTbl.dragging == NO && chatterUsersTbl.decelerating == NO)
        {
            [self startIconDownload:chatterUser forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        imageView.image = [UIImage imageNamed:@"profile_tab_icon.png"];                
    }
    else
    {
        imageView.image = chatterUser.chatterIcon;
    }
    return cell;
}
#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(ChatterRecord *)chatterUserRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.chatterRecord = chatterUserRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.chatterUsersArray count] > 0)
    {
        NSArray *visiblePaths = [chatterUsersTbl indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            ChatterRecord *chatterUser = [chatterUsersArray objectAtIndex:indexPath.row];
            if (!chatterUser.chatterIcon) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:chatterUser forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    DebugLog(@"iconDownloader:%@",iconDownloader);
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [chatterUsersTbl cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
        // Display the newly loaded image
        imageView.image = iconDownloader.chatterRecord.chatterIcon;
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
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
    if(self.inEditMode) {
        BOOL selected = [[selectedUsersRow objectAtIndex:[indexPath row]] boolValue];
        [selectedUsersRow replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
        DebugLog(@"selectedUsersRow:%@",selectedUsersRow);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView reloadData];
    } else {
        selectedUserIndex=indexPath.row;
        DebugLog(@"sel obj:%@",[self.chatterUsersArray objectAtIndex:indexPath.row]);
    }
}
-(void)showLoadingLblWithText:(NSString*)Loadingtext{
    //[loadingSpinner startAnimating];
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
    
    if([[request path] rangeOfString:LIST_OF_CHATTER_FOLLOWING_URL].location != NSNotFound){
        //List of following
        if([[jsonResponse objectForKey:@"errors"] count] == 0){
            [Utility hideCoverScreen];
            dialog_imgView.hidden = YES;
            loadingLbl.hidden = YES;
            doneImgView.hidden = YES;
            [loadingSpinner stopAnimating];
            NSArray *records = [jsonResponse objectForKey:@"following"];
            DebugLog(@"count:%d",[records count]);
            for (NSDictionary *chatterUserDict in records) {
                ChatterRecord *chatterUser = [[ChatterRecord alloc]init];
                if([chatterUserDict objectForKey:@"subject"] != nil) {
                    NSDictionary *chatterDescDict = [chatterUserDict objectForKey:@"subject"];
                    if([chatterDescDict objectForKey:@"name"] != nil)
                        chatterUser.chatterName = [chatterDescDict valueForKey:@"name"];
                    if([chatterDescDict objectForKey:@"id"] != nil)
                        chatterUser.chatterId = [chatterDescDict valueForKey:@"id"];
                    if([chatterDescDict objectForKey:@"photo"] != nil)
                    chatterUser.imageURLString = [[chatterDescDict valueForKey:@"photo"] valueForKey:@"smallPhotoUrl"];
                }
                [self.chatterUsersArray addObject:chatterUser];

            }
            // Sort the chatter users by name
            NSSortDescriptor *firstDescriptor =[[[NSSortDescriptor alloc]
                                                 initWithKey:@"chatterName"
                                                 ascending:YES
                                                 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
            
            NSArray * descriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
            NSMutableArray * sortedArray = (NSMutableArray*)[self.chatterUsersArray sortedArrayUsingDescriptors:descriptors];
            self.chatterUsersArray = [sortedArray retain];
            [self initializeSelectedRow];
            chatterUsersTbl.delegate = self;
            chatterUsersTbl.dataSource = self;
            [chatterUsersTbl reloadData];
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            
        }
        else{
            [loadingSpinner stopAnimating];
            dialog_imgView.hidden = YES;
            loadingLbl.hidden = YES;
            doneImgView.hidden = YES;
            [Utility showAlert:ERROR_LISTING_CHATTER_USERS_MSG];
            [Utility hideCoverScreen];
        }
        
    }
    else if([[request path] rangeOfString:POST_TO_CHATTER_WALL_URL].location != NSNotFound){
            if([[jsonResponse objectForKey:@"errors"] count]==0){
                
                    [loadingSpinner stopAnimating];
                    doneImgView.hidden = NO;
                    [self showLoadingLblWithText:salesforce_chatter_post_user_with_mentions_success_message];
                    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];

                [loadingSpinner stopAnimating];
            }
            else{
                [loadingSpinner stopAnimating];
                [self showLoadingLblWithText:POSTING_NOTE_FAILED_TO_CHATTER_USER_MSG];
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideToastMsg:) userInfo:nil repeats:NO];
            }
        [Utility hideCoverScreen];
    }
        
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
    [Utility hideCoverScreen];
    [loadingSpinner stopAnimating];
    [self hideDoneToastMsg:nil];
    NSString *alertMessaage ;
    if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"])
        alertMessaage = CHATTER_LIMIT_CROSSED_ERROR_MSG;
    else if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"API_DISABLED_FOR_ORG"]) {
        alertMessaage = CHATTER_API_DISABLED;
    } else {
        alertMessaage = [error.userInfo valueForKey:@"message"];
    }
    //add your failed error handling here
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:alertMessaage delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
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
- (void)dealloc {
	[imageDownloadsInProgress release];
    [self.chatterUsersArray release];
    [super dealloc];
}
@end
