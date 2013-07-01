/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "NSData+Base64.h"
#import "Utility.h"
#import "CustomBlueToolbar.h"

NSString * parrentTaskID ;
NSString * accountID ;
NSIndexPath *selectedAccIdx;
NSString* selectedObj,*selectedObjID;
NSMutableArray *keyArray;
NSMutableDictionary *dict;

@implementation RootViewController
@synthesize attachmentData;
@synthesize dataRows,fieldsRows;
@synthesize fileName;
@synthesize noteContent,inEditMode,selectedImage,unselectedImage,sections;
#pragma mark Misc


- (void)dealloc
{
    [attachmentData release];
    [cellIndexData release];
    [dict release];
    [selectedRow release];
    [selectedAccIdx release];
    [currentQuery release];

    self.dataRows = nil;    
    
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
    self.sections = [[[NSMutableArray alloc ]initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J",@"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil] autorelease];
    
    //backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    //[self changeBkgrndImgWithOrientation];
    
    self.fieldsRows = [[NSMutableArray alloc]init];
    cellIndexData = [[NSMutableArray alloc]init];
    dict = [[NSMutableDictionary alloc]init];
    
    //[self fetchSelectedObjList];
    [self getRecordsCount];
    
    selectedRow = [[NSMutableArray alloc]init];
    self.inEditMode = NO;
    isLoadingMoreRecordsInProcess = NO;
    self.selectedImage = [UIImage imageNamed:@"Checkbox_checked.png"];
	self.unselectedImage = [UIImage imageNamed:@"Checkbox.png"];
    selectedAccIdx = [[NSIndexPath alloc]init];
    DebugLog(@"subview:%@",[self.view subviews]);
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    selectedAccIdx = nil;
    
    //Show tool bar button only if records has been shown in table
    if([cellIndexData count] > 0)
    {
        // create a toolbar where we can place some buttons
        [self initToolbarButtons];
    }
    
}

-(void)initToolbarButtons
{
    CustomBlueToolbar* toolbar = [[CustomBlueToolbar alloc]
                                  initWithFrame:CGRectMake(0, 0, 125, 44)];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        toolbar.frame = CGRectMake(0, 0, 125, 32);
    }
    //[toolbar setBarStyle: UIBarStyleBlackOpaque];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    if(!self.inEditMode)
    {
        UIImage* editBtnImg = [UIImage imageNamed:@"Edit.png"];
        UIImage* editBtnDownImg = [UIImage imageNamed:@"Edit_down.png"];
        UIButton *editButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
        [editButton setBackgroundImage:editBtnImg forState:UIControlStateNormal];
        [editButton setBackgroundImage:editBtnDownImg forState:UIControlStateHighlighted];
        [editButton addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
        [editButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *editBarButton =[[UIBarButtonItem alloc] initWithCustomView:editButton];
        [buttons addObject:editBarButton];
        [editButton release];
    }
    else {
        UIImage* cancelBtnImg = [UIImage imageNamed:@"Cancel.png"];
        UIImage* cancelBtnDownImg = [UIImage imageNamed:@"Cancel_down.png"];
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
        [cancelButton setBackgroundImage:cancelBtnImg forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:cancelBtnDownImg forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *cancelBarButton =[[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [buttons addObject:cancelBarButton];
        [cancelButton release];
    }
    
    
    UIImage* saveBtnImage = [UIImage imageNamed:@"Save.png"];
    UIImage* saveBtnDoneImage = [UIImage imageNamed:@"Save_down.png"];
    UIButton *saveButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
    [saveButton setBackgroundImage:saveBtnImage forState:UIControlStateNormal];
    [saveButton setBackgroundImage:saveBtnDoneImage forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(addSelectedEvernoteToSF) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    [buttons addObject:saveBarButton];
    [saveButton release];
    
    [toolbar setItems:buttons];
    // place the toolbar into the navigation bar
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithCustomView:toolbar] autorelease];
    [toolbar release];
    
}



-(IBAction)toggleEditMode
{
	DebugLog(@"toggleEditMode");
	self.inEditMode = !self.inEditMode;
    self.navigationItem.rightBarButtonItem = nil;
    
    //Show tool bar button only if records has been shown in table
    if([cellIndexData count] > 0)
    {
        // create a toolbar where we can place some buttons
        [self initToolbarButtons];
    }
    
    if(!self.inEditMode)
    {
        [selectedRow removeAllObjects];
    }
    else
    {
        selectedAccIdx = nil;
    }
    
	[tableView reloadData];
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


//-(void)showLoadingLblWithText:(NSString*)Loadingtext
//{
//    [Utility showCoverScreenWithText:Loadingtext andType:kInProcessCoverScreen];
//    
////    [loadingSpinner startAnimating];
////    dialog_imgView.hidden = NO;
////    loadingLbl.text = Loadingtext;
////    loadingLbl.hidden = NO;
//}


-(void)getRecordsCount
{
    if([Utility checkNetwork])
    {
        //[Utility showCoverScreen];
        
        DebugLog(@"old obj:%@ \n old field:%@ \nfield value:%@ sf obje:%@",[Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY],[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY]);
        
        if(([Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY] == nil )&& ([Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] == nil))
        {
            //set previous selected mapping
            [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
            return;
        }
        else if(([Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] !=nil && [Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] != nil)
        {
            //set previous selected mapping
            [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] forKey:SFOBJ_TO_MAP_KEY];
            [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
        }
        
        NSString *selectedSFObj;
        NSUserDefaults* stdDefaults = [NSUserDefaults standardUserDefaults];
        
        
        NSDictionary *sfObj = [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];
        if(sfObj)
        {
            selectedSFObj = [sfObj valueForKey:OBJ_NAME];
            NSMutableString *queryString = [NSMutableString stringWithFormat:@"SELECT Count() from %@",selectedSFObj];
            
            //Show progress indicator
            [Utility showCoverScreenWithText:progress_dialog_salesforce_getting_record_list_message andType:kInProcessCoverScreen];
            
//            [self showLoadingLblWithText:progress_dialog_salesforce_getting_record_list_message];
            
            getRecordCountRequest = [[SFRestAPI sharedInstance] requestForQuery:queryString];
            [[SFRestAPI sharedInstance] send:getRecordCountRequest delegate:self];
            self.title = [NSString stringWithFormat:@"%@",selectedSFObj];
        }
    }
    else
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }

}


-(void)fetchSelectedObjList
{
    if([Utility checkNetwork])
    {
//        [Utility showCoverScreen];
//    
//        DebugLog(@"old obj:%@ \n old field:%@ \nfield value:%@ sf obje:%@",[Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY],[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY]);
//        
//        if(([Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY] == nil )&& ([Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] == nil))
//        {
//            //set previous selected mapping
//            [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
//            return;
//        }
//        else if(([Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] !=nil && [Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] != nil)
//        {
//            //set previous selected mapping
//            [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] forKey:SFOBJ_TO_MAP_KEY];
//            [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
//        }
        
        NSString *selectedSFObj;
        NSUserDefaults* stdDefaults = [NSUserDefaults standardUserDefaults];
        
        
        NSDictionary *sfObj = [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];
        if(sfObj)
        {
            selectedSFObj = [sfObj valueForKey:OBJ_NAME];
            NSMutableString *queryString;
            
            if ([selectedSFObj isEqualToString:@"Task"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@ Order by Subject",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Case"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,CaseNumber from %@ Order by CaseNumber",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"CaseComment"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ParentId from %@ Order by ParentId",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"ContentVersion"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContentDocumentId from %@ Order by ContentDocumentId",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Contract"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContractNumber from %@ Order by ContractNumber",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Event"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@ Order by Subject",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Idea"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@ Order by Title",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Note"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@ Order by Title",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Solution"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,SolutionName from %@ Order by SolutionName",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"FeedItem"]||[selectedSFObj isEqualToString:@"FeedComment"])
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id from %@ Order by Id",selectedSFObj];//CreatedById
            }
            else
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Name,Id from %@ Order by Name",selectedSFObj];
            }
            
            //Append Limit to quesry string
            [queryString appendString:[NSString stringWithFormat:@" Limit %d", kRecordLimit]];
            
            currentQuery = [[NSString alloc] initWithString:queryString];
            currentOffset = 0;
            
            //Append Offset to quesry string
            [queryString appendString:[NSString stringWithFormat:@" Offset %d", currentOffset]];
            
            //Show progress indicator
            [Utility showCoverScreenWithText:progress_dialog_salesforce_getting_record_list_message andType:kInProcessCoverScreen];
            
//            [self showLoadingLblWithText:progress_dialog_salesforce_getting_record_list_message];
            
            SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:queryString];
            [[SFRestAPI sharedInstance] send:request delegate:self];
            self.title = [NSString stringWithFormat:@"%@",selectedSFObj];
        }
    }
    else
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}


-(void)addSelectedEvernoteToSF
{
    //[Utility showCoverScreen];
    if([Utility checkNetwork])
    {
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
        int noteLength = [self.noteContent length];
        int sfFieldLength = [[sfobjField objectForKey:FIELD_LIMIT]intValue];
        
        if(noteLength <= sfFieldLength)
        {
            [self createSFRequestToSaveSelectedNoteWithContent:self.noteContent];
        }
        else
        {
            int difference = noteLength - sfFieldLength;
            NSString *alertMsg = [NSString stringWithFormat:@"Content length is %d char more than allowed limit. Content will be truncated. Do you want to continue?",difference];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Truncate Note?" message:alertMsg delegate:self cancelButtonTitle:ALERT_NEGATIVE_BUTTON_TEXT otherButtonTitles:ALERT_POSITIVE_BUTTON_TEXT, nil];
            alert.tag = SAVE_TO_SFOBJ_LIMIT_ALERT_TAG;
            [alert show];
            [alert release];
        }
    }
    else
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}


-(void)createSFRequestToSaveSelectedNoteWithContent:(NSString*)evernoteContent
{
    if(([Utility valueInPrefForKey:SFOBJ_TO_MAP_KEY] == nil || [Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] !=nil && [Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] != nil)
    {
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_TO_MAP_KEY] forKey:SFOBJ_TO_MAP_KEY];
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
    }
    
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sfobj =  [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];
    NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
    DebugLog(@"sfobj:%@ sfobjField:%@",sfobj,sfobjField);
    
    if(sfobjField && sfobj)
    {
        NSMutableDictionary * fields =[[NSMutableDictionary alloc] init];
        [fields setValue:evernoteContent forKey:[sfobjField valueForKey:FIELD_NAME]];
        selectedCount = 0;
        
        if(self.inEditMode)
        {
            if([selectedRow count] == 0)
            {
                [Utility hideCoverScreen];
                [Utility showAlert:[NSString stringWithFormat:@"Please select %@ to map with",[sfobj valueForKey:OBJ_NAME]]];
            }
            else
            {
                for(int i = 0;i < [selectedRow count] ; i++)
                {
                    NSIndexPath *tempIndexPath = (NSIndexPath*)[selectedRow objectAtIndex:i];
                    //NSMutableArray *tempDict = [dict valueForKey:(NSString *)[keyArray objectAtIndex:tempIndexPath.section]];
                    
                    //Show progress indicator
                    [Utility showCoverScreenWithText:progress_dialog_salesforce_record_updating_message andType:kInProcessCoverScreen];
                    
//                    [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                    
                    NSDictionary * dict = [cellIndexData objectAtIndex:[tempIndexPath row]];
                    
                    SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:[sfobj valueForKey:OBJ_NAME] objectId:[dict valueForKey:@"Id" ]fields:fields];
                    
                    [[SFRestAPI sharedInstance] send:request delegate:self];
                    
                    selectedCount ++;
                }
            }
        }
        else
        {            
            //----------------------------------------------------------------------------------------------------
            selectedCount = 0;
            if(selectedAccIdx == nil)
            {
                [Utility hideCoverScreen];
                [Utility showAlert:[NSString stringWithFormat:@"Please select %@ to map with",[sfobj valueForKey:OBJ_NAME]]];
            }
            else
            {
                //Show progress indicator
                [Utility showCoverScreenWithText:progress_dialog_salesforce_record_updating_message andType:kInProcessCoverScreen];
                
//                [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                
                //NSMutableArray *tempDict = [dict valueForKey:(NSString *)[keyArray objectAtIndex:selectedAccIdx.section]];
                
                NSDictionary * dict = [cellIndexData objectAtIndex:[selectedAccIdx row]];
                                
                SFRestRequest * request =    [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:[sfobj valueForKey:OBJ_NAME] objectId:[dict valueForKey:@"Id" ]fields:fields];
                
                [[SFRestAPI sharedInstance] send:request delegate:self];
                
                selectedCount ++;
            }
            
        }
    }
    else
    {
        [Utility hideCoverScreen];
        [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
    }
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SAVE_TO_SFOBJ_LIMIT_ALERT_TAG && alertView.cancelButtonIndex == buttonIndex)
    {
    }
    else if (alertView.tag == SAVE_TO_SFOBJ_LIMIT_ALERT_TAG)
    {
        //Show progress indicator
        [Utility showCoverScreenWithText:progress_dialog_salesforce_record_updating_message andType:kInProcessCoverScreen];
        
        //[Utility showCoverScreen];
//        [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
        
        //truncationg note text to 1000 character for posting to Chatter
        
        DebugLog(@"old length:%d", [self.noteContent length]);
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
        int field_limit = [[sfobjField objectForKey:FIELD_LIMIT]intValue];
        NSString *truncateNoteContent = [[self.noteContent substringToIndex:field_limit-1]mutableCopy];
        DebugLog(@"new length:%d", [truncateNoteContent length]);
        
        [self createSFRequestToSaveSelectedNoteWithContent:truncateNoteContent];
    }
    else if(alertView.tag == ERROR_LOADING_CONTENT_ALERT_TAG)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if(no_record_view == nil)
    {
        //[self changeBkgrndImgWithOrientation];
        
        //Show tool bar button only if records has been shown in table
        if([cellIndexData count] > 0)
        {
            // create a toolbar where we can place some buttons
            [self initToolbarButtons];
        }
    }
    else
    {
        //Set no_record_label in the view's center
        no_record_view.frame = self.view.frame;
        no_record_lbl.center = self.view.center;
    }
}


-(void)hideToastMsg:(id)sender
{
    //Hide progress indicator
    [Utility hideCoverScreen];
    
//	dialog_imgView.hidden = YES;
//    loadingLbl.hidden = YES;
//    [loadingSpinner stopAnimating];
}


-(void)hideDoneToastMsg:(id)sender
{
    //Hide progress indicator
    [Utility hideCoverScreen];
    
//	dialog_imgView.hidden = YES;
//    loadingLbl.hidden = YES;
//    doneImgView.hidden = YES;
//    [loadingSpinner stopAnimating];

    [self.navigationController popToRootViewControllerAnimated:YES];
}




#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);
    
    if([[request description] rangeOfString:@"SELECT"].location != NSNotFound)
    {
        if([[jsonResponse objectForKey:@"errors"] count]==0)
        {
            //If this is a record count request, execute the following bunch of code
            if(request == getRecordCountRequest)
            {
                totalRecords = [[jsonResponse objectForKey:@"totalSize"] intValue];
                
                NSLog(@"TotalRecords = %d", totalRecords);
                
                if(totalRecords > 0)
                {
                    //Fetch records
                    [self fetchSelectedObjList];
                }
                else
                {
                    //Hide progress indicator
                    [Utility hideCoverScreen];
                    
//                    dialog_imgView.hidden = YES;
//                    loadingLbl.hidden = YES;
//                    doneImgView.hidden = YES;
//                    [loadingSpinner stopAnimating];

                    
                    [Utility showAlert:[NSString stringWithFormat:@"%@%@",NO_RECORD_IN_SF_OBJ_MSG,self.title]];
                    
                    no_record_view =[[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                    no_record_view.backgroundColor=[UIColor whiteColor];
                    [self.view addSubview:no_record_view];
                    //UILabel *no_record_lbl =  [[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x-100,self.view.center.y,200,50)];
                    
                    no_record_lbl =  [[UILabel alloc]initWithFrame:CGRectMake(0, 0, no_record_view.frame.size.width, no_record_view.frame.size.height)];
                    no_record_lbl.text=@"No record for this object.";
                    no_record_lbl.textAlignment = NSTextAlignmentCenter;
                    no_record_lbl.center = no_record_view.center;
                    [no_record_view addSubview:no_record_lbl];
                    
                    self.navigationItem.rightBarButtonItem = nil;
                }
                
                return;
            }
            
            //If this is a record fetch request, execute the following bunch of code
            
            //Hide progress indicator
            [Utility hideCoverScreen];
            
//            dialog_imgView.hidden = YES;
//            loadingLbl.hidden = YES;
//            doneImgView.hidden = YES;
//            [loadingSpinner stopAnimating];
            
            NSArray *records = [jsonResponse objectForKey:@"records"];
            
            
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            NSLog(@"records count...%d",records.count);
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name"  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            
            
            self.dataRows = [records sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            
            //[selectedRow removeAllObjects];
            
            if([self.dataRows count] != 0)
            {
                //Update currentOffset
                currentOffset += kRecordLimit;
                
                //Loading more records ends here
                isLoadingMoreRecordsInProcess = NO;
                
                if([cellIndexData count] == 0)
                {
                    //Show toolbar buttons
                    [self initToolbarButtons];
                }
                
                //Populate cellIndexdata which is a source of data for tableview
                [self reloadTable];
                
                //Show back button
                [self.navigationItem setHidesBackButton:NO animated:YES];
                
                if(currentOffset < totalRecords)
                {
                    //Add a null entry at the end of CellIndexData. This entry will return a row containing an activity indicator
                    [cellIndexData addObject:[NSNull null]];
                }
                
                //dict = [self fillingDictionary:cellIndexData];
            }
        }
        else
        {
            [Utility showAlert:ERROR_LISTING_SF_OBJECT_MSG];
            [Utility hideCoverScreen];
        }
        
        
    }
    else
    {
        selectedCount --;
        
        if([[jsonResponse objectForKey:@"errors"] count]==0)
        {
            if(selectedCount == 0 )
            {
//                [loadingSpinner stopAnimating];
//                doneImgView.hidden = NO;

                //Show progress indicator
                [Utility showCoverScreenWithText:progress_dialog_salesforce_record_updated_success_message andType:kProcessDoneCoverScreen];

                
//                [self showLoadingLblWithText:progress_dialog_salesforce_record_updated_success_message];
                
                [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
            }
            
//            [loadingSpinner stopAnimating];
        }
        else
        {
//            [loadingSpinner stopAnimating];
            
            //Show progress indicator
            [Utility showCoverScreenWithText:salesforce_record_saving_failed_message andType:kWarningCoverScreen];
            
//            [self showLoadingLblWithText:salesforce_record_saving_failed_message];
            
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideToastMsg:) userInfo:nil repeats:NO];
        }
        
//        [Utility hideCoverScreen];
    }
    
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error
{
    //Show back button
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    DebugLog(@"request:didFailLoadWithError: %@ code:%d", error,error.code);
    
    //Hide loading indicator
//    [Utility hideCoverScreen];
    
    [self hideToastMsg:nil];
    
    //add your failed error handling here
    NSString *alertMessaage ;
    
    if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"])
    {
        alertMessaage = SF_FIELDS_LIMIT_CROSSED_ERROR_MSG;
    }
    else
    {
        alertMessaage = @"An error occured.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:alertMessaage delegate:self cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    alert.tag = ERROR_LOADING_CONTENT_ALERT_TAG;
    [alert show];
    [alert release];
}



- (void)requestDidCancelLoad:(SFRestRequest *)request
{
    //Show back button
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    
//    [Utility hideCoverScreen];
    
    [self hideToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request
{
    //Show back button
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    //add your failed error handling here
//    [Utility hideCoverScreen];

    [self hideToastMsg:nil];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return [keyArray count];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellIndexData count];
    
//    NSMutableArray *dataArray = [[[NSMutableArray alloc]init] autorelease];
//    dataArray = (NSMutableArray*)[dict valueForKey:(NSString*)[keyArray objectAtIndex:section]];
//    return [dataArray count];
}

- (void)reloadTable
{
    // Configure the cell to show the data.
    
    //If cellIndexData already contains data, then remove its last object as its last object is a null object
    if([cellIndexData count] > 0)
    {
        //Remove the last object
        [cellIndexData removeLastObject];
    }
    
    for (int cnt =0; cnt < self.dataRows.count; cnt++)
    {
        NSDictionary *obj = [self.dataRows objectAtIndex:cnt];
        NSString *selectedSFObj;
        NSUserDefaults* stdDefaults = [NSUserDefaults standardUserDefaults];
        
        
        NSDictionary *sfObj = [stdDefaults valueForKey:SFOBJ_TO_MAP_KEY];
        
        
        if(sfObj)
        {
            selectedSFObj = [sfObj valueForKey:OBJ_NAME];
            
            if ([selectedSFObj isEqualToString:@"Task"]) {
                
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"Subject"])
                {
                    [tempObj setValue:[obj objectForKey:@"Subject"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                else {
                    
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
                
            }
            else if ([selectedSFObj isEqualToString:@"Case"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,CaseNumber from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"CaseNumber"])
                {
                    
                    [tempObj setValue:[obj objectForKey:@"CaseNumber"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"CaseComment"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ParentId from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"ParentId"])
                {
                    [tempObj setValue:[obj objectForKey:@"ParentId"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"ContentVersion"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContentDocumentId from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"ContentDocumentId"])
                {
                    [tempObj setValue:[obj objectForKey:@"ContentDocumentId"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"Contract"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContractNumber from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"ContractNumber"])
                {
                    [tempObj setValue:[obj objectForKey:@"ContractNumber"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"Event"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"Subject"])
                {
                    [tempObj setValue:[obj objectForKey:@"Subject"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
                
            }
            else if ([selectedSFObj isEqualToString:@"Idea"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"Title"])
                {
                    [tempObj setValue:[obj objectForKey:@"Title"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"Note"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"Title"])
                {
                    [tempObj setValue:[obj objectForKey:@"Title"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else if ([selectedSFObj isEqualToString:@"Solution"]) {
                //queryString = [NSMutableString stringWithFormat:@"SELECT Id,SolutionName from %@",selectedSFObj];
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"SolutionName"])
                {
                    [tempObj setValue:[obj objectForKey:@"SolutionName"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    
                }
                else {
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
            else
            {
                NSMutableDictionary *tempObj = [[NSMutableDictionary alloc] init];
                if([obj objectForKey:@"label"])
                {
                    [tempObj setValue:[obj objectForKey:@"label"]forKey:@"name"];
                    [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                }
                else {
                    if([obj valueForKey:@"Name"] != nil) {
                        [tempObj setValue:[obj objectForKey:@"Name"]forKey:@"name"];
                        [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                        
                    }
                    else {
                        [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"name"];
                        [tempObj setValue:[obj objectForKey:@"Id"]forKey:@"Id"];
                    }
                    
                }
                [cellIndexData addObject:tempObj];
                [tempObj release];
            }
        }
    }
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        UIView * view = [cell.contentView viewWithTag:10];
        if(view != nil)
        {
            [view removeFromSuperview];
        }
    }
    
	//if you want to add an image to your cell, here's how
    int flag=0;
    BOOL selected;
	UIImage *image = [UIImage imageNamed:@"Record.png"];
    
    for (int cnt = 0; cnt < selectedRow.count; cnt++)
    {
        if([[selectedRow objectAtIndex:cnt] isEqual:indexPath])
        {
            selected = true;
            flag=1;
            break;
        }
    }
    
    if (flag != 1)
    {
        NSLog(@"...in unselected..");
        selected = false;
        flag = 0;
    }
    
    if(self.inEditMode)
    {
        if (selected)
        {
            cell.imageView.image = self.selectedImage;
        }
        else
        {
            cell.imageView.image = self.unselectedImage;
        }
        NSLog(@"....in if case....");
        NSLog(@"selected Row.......%d",selectedRow.count);
        //cell.imageView.image = ([selectedForDelete boolValue]) ? self.selectedImage : self.unselectedImage;
    }
    else
    {
        cell.imageView.image = image;
    }
    
//    NSMutableArray *cellData = [dict objectForKey:[keyArray objectAtIndex:indexPath.section]];
//	//this adds the arrow to the right hand side.
//    NSDictionary *dictionary= [cellData objectAtIndex:[indexPath row]];
//    cell.textLabel.text = [dictionary valueForKey:@"name"];
//    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
//    //cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:16];
//	cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.textLabel.textColor = [UIColor blackColor];

    
    if([indexPath row] == ([cellIndexData count] - 1))
    {
        NSLog(@"CurrentOffset = %d", currentOffset);
        NSLog(@"TotalRecords = %d", totalRecords);
        
        if((currentOffset < totalRecords) && !isLoadingMoreRecordsInProcess)
        {
            //Set the flag
            isLoadingMoreRecordsInProcess = YES;
            
            NSMutableString * queryString = [NSMutableString stringWithString:currentQuery];
            
            //Form the query string for next set of records
            [queryString appendString:[NSString stringWithFormat:@" Offset %d", currentOffset]];
            
            //Send the request
            SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:queryString];
            [[SFRestAPI sharedInstance] send:request delegate:self];
            
            //Hide back button
            [self.navigationItem setHidesBackButton:YES animated:YES];
            
            //Reload table data
            //[tableView_ reloadData];
        }
    }    
    

    id object = [cellIndexData objectAtIndex:[indexPath row]];
    
    if(object == [NSNull null])
    {
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
        
        UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = cell.contentView.center;
        [activityIndicator startAnimating];
        activityIndicator.tag = 10;
        [cell.contentView addSubview:activityIndicator];
        [activityIndicator release];
    }
    else
    {
        NSDictionary * dictionary = (NSDictionary *)object;
        
        cell.textLabel.text = [dictionary valueForKey:@"name"];
        cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
        
        //cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:16];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if([selectedAccIdx isEqual:indexPath])
    {
        [tableView_ selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

    
	return cell;
}





//- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
//    
//    return [keyArray objectAtIndex:section];
//    
//}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return self.sections;
//}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [keyArray indexOfObject:[self.sections objectAtIndex:index]];
//}


#pragma mark - Table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isLoadingMoreRecordsInProcess && [indexPath row] == ([cellIndexData count] - 1))
    {
        return nil;
    }
    return indexPath;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.inEditMode)
    {        
        if([selectedRow containsObject:indexPath])
        {
            int cnt;
            cnt = [selectedRow indexOfObject:indexPath];
            [selectedRow removeObjectAtIndex:cnt];
        }
        else
        {
            [selectedRow addObject:indexPath];
        }
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView reloadData];
    }
    else
    {
        selectedAccIdx = [indexPath retain];
    }
}

-(NSMutableDictionary *)fillingDictionary:(NSMutableArray *)ary
{
    
    // This method has the real magic of this sample
    // ary is the unsorted array
    // keyArray should be global as you need to access it outside of this function
    keyArray=[[NSMutableArray alloc]init];
    [keyArray removeAllObjects];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                 ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSMutableArray arrayWithObject:sortByName];
    NSArray *sortedArray = [ary sortedArrayUsingDescriptors:sortDescriptors];
    
    // Get the first character of your string which will be your key
    
    for(NSDictionary *str in sortedArray)
    {
        NSString *tempStr = [str valueForKey:@"name"];
        char charval=[tempStr characterAtIndex:0];
        NSString *charStr=[NSString stringWithFormat:@"%c",charval];
        NSString *capitalCharStr = [charStr capitalizedString];
        if(![keyArray containsObject:capitalCharStr])
        {
            NSMutableArray *charArray=[[NSMutableArray alloc]init];
            [charArray addObject:str];
            [keyArray addObject:capitalCharStr];
            [dic setValue:charArray forKey:capitalCharStr];
        }
        else
        {
            NSMutableArray *prevArray=(NSMutableArray *)[dic valueForKey:capitalCharStr];
            [prevArray addObject:str];
            [dic setValue:prevArray forKey:capitalCharStr];
            
        }
        
    }
    return dic;
    
}
@end
