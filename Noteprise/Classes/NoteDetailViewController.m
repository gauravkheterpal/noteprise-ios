#import "NoteDetailViewController.h"
#import "NotesListViewController.h"
#import "EvernoteSDK.h"
#import "RootViewController.h"
#import "NSString+HTML.h"
#import "ChatterUsersViewController.h"
#import "ChatterGroupVCntrlViewController.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

@implementation NoteDetailViewController 


@synthesize guid, readProp, noteNavigation, noteContent,textContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
     self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
     if (self)
     {
               // Custom initialization
         
      }
     return self;
}


/************************************************************
 *
 *  Function that loads all the information concerning
 *  the note we are viewing
 *
 ************************************************************/
//int flag=0,flag2 =0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Show popover controller in portrait mode first time
    if (self.navigationItem.leftBarButtonItem != nil && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem.leftBarButtonItem];
    }
    
    
    //Initialize variables
    isEditNoteCancelled = NO;
    updateNotesListAfterNoteEditing = NO;
    
    //Set webview's background color to clear
    noteContent.backgroundColor = [UIColor clearColor];
    noteContent.opaque = NO;
    
    if(!isWebViewInitialized)
    {
        [noteContent loadHTMLString:@"<HTML></HTML>" baseURL:nil];
        isWebViewInitialized = YES;
    }
    
    //Set navigation bar's background image
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
    {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Toolbar_768x44.png"] forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
	}
	
    //Add bottom bar buttons in non edit mode
    [self addBottomBarButtonsInNonEditMode];
    
    
	
    //noteContent.userInteractionEnabled = NO;
    //[[noteContent layer] setCornerRadius:10];
	//[noteContent setClipsToBounds:YES];
	//[[noteContent layer] setBorderWidth: 0.0f];
    
    
	noteContent.frame = CGRectMake(noteContent.frame.origin.x,noteContent.frame.origin.y+2,self.view.frame.size.width-35,self.view.frame.size.height-50);
	
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
     
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
     
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
          self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self addEditBarButtonItem];
    }
    
    //If device is iPhone then show the selected note content on viewDidLoad
    //But if device is iPad, don't show note content on viewDidLoad
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self showSelectedNoteContent];
    }
    else
    {
        //Disable bar buttons on view did load if device is ipad
        [self enableBarButtons:NO];
        
//        //Add logoImageView to view
//        UIImageView * logoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NotepriseLogo.png"]];
//        logoImageView.center = self.view.center;
//        logoImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//        [self.view addSubview:logoImageView];
//        
//        [logoImageView release];
    }
    
    
//     self.navigationItem.rightBarButtonItem.title = @"Edit";
//     
//     self.navigationItem.rightBarButtonItem.tag = kEditButtonTag;
//     DebugLog(@"tag = %d",self.navigationItem.rightBarButtonItem.tag);
	
    
    
//    [loadingSpinner startAnimating];
    
//    dialog_imgView.hidden = NO;
    
//    loadingLbl.text = GETTING_NOTE_DETAILS_MSG;
    
//    loadingLbl.hidden = NO;
    
    
     
}


-(void)addEditBarButtonItem
{
    UIImage *editButtonImage = [UIImage imageNamed:@"Edit.png"];
    UIImage *editButtonSelectedImage = [UIImage imageNamed:@"Edit_down.png"];
    
    CGRect frameimg = BAR_BUTTON_FRAME;
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:frameimg];
    [editButton setBackgroundImage:editButtonImage forState:UIControlStateNormal];
    [editButton setBackgroundImage:editButtonSelectedImage forState:UIControlStateHighlighted];
    [editButton addTarget:self action:@selector(editPage:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *editBarbutton =[[UIBarButtonItem alloc] initWithCustomView:editButton];
    [editButton release];
    
    self.navigationItem.rightBarButtonItem = editBarbutton;
    [editBarbutton release];
    
    self.navigationItem.rightBarButtonItem.title = @"Edit";
    self.navigationItem.rightBarButtonItem.tag = kEditButtonTag;
    DebugLog(@"tag = %d",self.navigationItem.rightBarButtonItem.tag);
}


-(void)addBottomBarButtonsInNonEditMode
{
    //Create a barButtonItem
    flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
    //Add three bar buttons to bottom bar
    NSArray *items = [NSArray arrayWithObjects:flexible,saveToSFBarBtn,postToChatterBarBtn, nil];
    [flexible release];
    
	[bottomBar setItems:items];
    
    //Enable saveToSF and postToChatter bar buttons
	saveToSFBarBtn.enabled=YES;
	postToChatterBarBtn.enabled=YES;
}


-(void)enableBarButtons:(BOOL)flag
{
    self.navigationItem.rightBarButtonItem.enabled = flag;
    saveToSFBarBtn.enabled = flag;
    postToChatterBarBtn.enabled = flag;
}


//-(UIViewController *)
//{
//    UIViewController * viewController = nil;
//    if(self.splitViewController != nil && [self.splitViewController.viewControllers count] > 0)
//    {
//        viewController = (UIViewController *)[self.splitViewController.viewControllers lastObject];
//        
//        if([viewController respondsToSelector:@selector(fetchDataFromEverNote)])
//        {
//            [viewController fetchDataFromEverNote];
//        }
//        else
//        {
//            viewController = (UIViewController *)[self.splitViewController.viewControllers objectAtIndex:0];
//            
//            if([viewController respondsToSelector:@selector(fetchDataFromEverNote)])
//            {
//                [viewController fetchDataFromEverNote];
//            }
//        }
//    }
//}



-(void)showSelectedNoteContent
{
    //If previous note was in edit mode, then quit from edit mode
    if(self.navigationItem.rightBarButtonItem == nil)
    {
        //////////////////////////////
        //Set screen to non edit mode
        /////////////////////////////
        
        //Hide border around webView
        [self hideBorderViewAroundWebView];
        
        editTitleField.hidden = TRUE;
        noteContent.frame = CGRectMake(noteContent.frame.origin.x,2,self.view.frame.size.width-35,self.view.frame.size.height-50);
        
        
        //Set border view's frame
        [self setBorderViewFrame];
        
        [self setWebViewKeyPressDetectionEnabled:NO];
        [self setWebViewTapDetectionEnabled:NO];
        [self addEditBarButtonItem];
        
        //Add bottom bar buttons in non edit mode
        [self addBottomBarButtonsInNonEditMode];
    }
    
    //If there is no selected note in NOtesListViewController
    if(guid == nil)
    {
        //Make noteContent webview empty
        [noteContent loadHTMLString:@"<HTML></HTML>" baseURL:nil];
        
        //Disable bar buttons
        [self enableBarButtons:NO];
    }
    else
    {
        //Keep track of title
        orgNoteTitle = self.title;
        tempTitle=orgNoteTitle;
        
        //Show progress indicator
        [Utility showCoverScreenWithText:GETTING_NOTE_DETAILS_MSG andType:kInProcessCoverScreen];
        
        DebugLog(@"guid:%@",guid);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
            // Load the EDAMNote object that has guid we have stored in the object
            @try {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
                    // As an example, we are going to show the first element if it is an image
                    [noteStore getNoteContentWithGuid:guid success:^(NSString *content)
                     {
                         DebugLog(@"content%@ :::: ",content);
                         
                         //Hide progress indicator
                         [Utility hideCoverScreen];
                         
                         if(updateNotesListAfterNoteEditing)
                         {
                             updateNotesListAfterNoteEditing = NO;
                             
                             if(self.notesViewController == nil)
                             {
                                 [self.masterViewController fetchDataFromEverNote];
                             }
                             else
                             {
                                 [self.notesViewController fetchDataFromEvernote];
                             }
                         }
                         
                         
                         //                      [loadingSpinner stopAnimating];
                         //                      dialog_imgView.hidden = YES;
                         //                      loadingLbl.hidden = YES;
                         
                         NSString *stringToReplace = [NSString stringWithFormat:@"<en-note%@>",[self getDataBetweenFromString:content leftString:@"<en-note" rightString:@">" leftOffset:8]];
                         
                         NSString * updatedString = [NSString stringWithFormat:@"<en-note%@ xmlns=\"http://www.w3.org/1999/xhtml\">",[self getDataBetweenFromString:content leftString:@"<en-note" rightString:@">" leftOffset:8]];
                         
                         //NSString *updatedString = [NSString stringWithFormat:@"<en-note xmlns=\"http://www.w3.org/1999/xhtml\">",[self getDataBetweenFromString:content leftString:@"<en-note" rightString:@">" leftOffset:8]];
                         
                         DebugLog(@"updatedString = %@", updatedString);
                         
                         
                         content = [content stringByReplacingOccurrencesOfString:stringToReplace withString:updatedString];
                         content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"&#160;"];
                         content = [content stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"&#151;"];
                         DebugLog(@"updatedContent = %@", content);
                         
                         NSData *d= [content dataUsingEncoding:NSUTF8StringEncoding];
                         [noteContent loadData:d MIMEType:@"application/xhtml+xml" textEncodingName:@"UTF-8" baseURL:nil];// application/xhtml
                         
                         //[noteContent loadHTMLString:content baseURL:nil];
                         textContent = (NSMutableString *)[[[Utility flattenNoteBody:content]stringByDecodingHTMLEntities] retain];
                         
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             //Enable bar buttons
                             [self enableBarButtons:YES];
                         }
                         
                     }failure:^(NSError *error)
                     {
                         DebugLog(@"note::::::::error %@", error);
                         
                         //Hide progress indicator
                         [Utility hideCoverScreen];
                         
                         if(updateNotesListAfterNoteEditing)
                         {
                             updateNotesListAfterNoteEditing = NO;
                             
                             if(self.notesViewController == nil)
                             {
                                 [self.masterViewController fetchDataFromEverNote];
                             }
                             else
                             {
                                 [self.notesViewController fetchDataFromEvernote];
                             }
                         }
                         
                         id alertDelegate = self;
                         
                         //If iPad
                         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                         {
                             //Disable bar buttons
                             [self enableBarButtons:NO];
                             
                             //Make noteContent webview empty
                             [noteContent loadHTMLString:@"<HTML></HTML>" baseURL:nil];
                             
                             //set alertDelegate to nil
                             alertDelegate = nil;
                         }
                         
                         //Show error message
                         UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Noteprise"
                                                                             message:@""
                                                                            delegate:alertDelegate
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                         
                         alertView.tag = ERROR_LOADING_CONTENT_ALERT_TAG;
                         
                         if(error.code == -3000)
                         {
                             alertView.message = NETWORK_UNAVAILABLE_MSG;
                         }
                         else
                         {
                             alertView.message = @"An error occured.";
                             
                         }
                         
                         [alertView show];
                         [alertView release];
                         
                     }];
                    
                });
            }
            @catch (EDAMUserException *exception) {
                
                DebugLog(@"EDAMUserException reason:%@ name:%@",exception.reason,exception.name);
            }
            @catch (EDAMSystemException *exception) {
                DebugLog(@"EDAMSystemException:%@",exception.reason);
            }
            @catch (EDAMNotFoundException *exception) {
                DebugLog(@"EDAMNotFoundException:%@",exception.reason);
            }
        });
        //if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        //[[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1]];
    }
}



- (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos
{
     NSInteger left, right;
     NSString *foundData;
     NSScanner *scanner=[NSScanner scannerWithString:data];
     [scanner scanUpToString:leftData intoString: nil];
     left = [scanner scanLocation];
     [scanner setScanLocation:left + leftPos];
     [scanner scanUpToString:rightData intoString: nil];
     right = [scanner scanLocation] + 1;
     left += leftPos;
     foundData = [data substringWithRange: NSMakeRange(left, (right - left) - 1)];         return foundData;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	orgBounds=self.view.frame;
}



-(void)changeBkgrndImgWithOrientation
{
     if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
     {
          if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
          {
               backgroundImgView.image = [UIImage imageNamed:@"bgE-480x287.png"];
          }
          else
          {
               backgroundImgView.image = [UIImage imageNamed:@"bgE-320x480.png"];
          }
     }
     else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     {
          if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
          {
               backgroundImgView.image = [UIImage imageNamed:@"bgE-1024x704.png"];
          }
          else
          {
               backgroundImgView.image = [UIImage imageNamed:@"bgE-768x1024.png"];
          }
     }
	
}

#pragma mark -
#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG && alertView.cancelButtonIndex == buttonIndex)
     {
     }
     else if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG)
     {
         //Show progress indicator
         [Utility showCoverScreenWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG andType:kInProcessCoverScreen];
         
//         [self showLoadingLblWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG];
         
         //truncationg note text to 1000 character for posting to Chatter
         NSString *truncatedTextContent = [[textContent substringToIndex:999]mutableCopy];
         NSString * path = POST_TO_CHATTER_WALL_URL;
         NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",truncatedTextContent, @"text",nil];
         NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:param],@"messageSegments", nil];
         NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
         SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
         [[SFRestAPI sharedInstance] send:request delegate:self];
     }
    else if(alertView.tag == ERROR_LOADING_CONTENT_ALERT_TAG)
    {
        //Go to previos page
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//0 Post to Wall
//1 Post to chatter users
//2 Post to chatter groups
//3 Cancel



#pragma mark -
#pragma mark UIActionSheet Delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DebugLog(@"clickedButtonAtIndex:%d",buttonIndex);

    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
    }
    else if(buttonIndex == 0)
    {
        [self postToChatterWall];
    }
    else if (buttonIndex == 1)
    {
        //post to chatter users
        [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
        
        ChatterUsersViewController * chatterUsersVC = [[ChatterUsersViewController alloc] init];
        chatterUsersVC.noteTitle = self.title;
        chatterUsersVC.noteContent = textContent;
        [self.navigationController pushViewController:chatterUsersVC animated:YES];
        [chatterUsersVC release];
//        [Utility hideCoverScreen];
    }
    else if (buttonIndex == 2)
    {
        //post to chatter users
        [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
        
        ChatterGroupVCntrlViewController * chatterGroupVC = [[ChatterGroupVCntrlViewController alloc] init];
        chatterGroupVC.noteTitle = self.title;
        chatterGroupVC.noteContent = textContent;
        [self.navigationController pushViewController:chatterGroupVC animated:YES];
        [chatterGroupVC release];
//        [Utility hideCoverScreen];
    }    
}

-(void)postToChatterWall {
     
     if([textContent length] >1000) {
          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Noteprise" message:CHATTER_LIMIT_CROSSED_ALERT_MSG delegate:self cancelButtonTitle:ALERT_NEGATIVE_BUTTON_TEXT otherButtonTitles:ALERT_POSITIVE_BUTTON_TEXT, nil];
          alert.tag = CHATTER_POST_LIMIT_ALERT_TAG;
          [alert show];
          [alert release];
     }
     else
     {
         [Utility showCoverScreenWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG andType:kInProcessCoverScreen];
         
//         [self showLoadingLblWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG];
         
         NSString * path = POST_TO_CHATTER_WALL_URL;
         NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",textContent, @"text",nil];
         NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:param],@"messageSegments", nil];
         NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
         SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
         [[SFRestAPI sharedInstance] send:request delegate:self];
     }
}


-(IBAction)linkEvernoteToSF:(id)sender
{
    if([Utility checkNetwork])
    {
         [self dismissPreviousPopover];
        
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
    
        //[Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
        
        [self moveToSF];
    }
    else
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}


-(IBAction)postToChatter:(id)sender
{
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     {
          [self dismissPreviousPopover];
          postToChatterOptionActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Post to Wall",@"Post to Chatter Users",@"Post to Chatter Group", nil];
     }
     else
     {
          [self dismissPreviousPopover];
          postToChatterOptionActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post to Wall",@"Post to Chatter Users",@"Post to Chatter Group", nil];
     }
     
     postToChatterOptionActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
     [postToChatterOptionActionSheet showFromBarButtonItem:postToChatterBarBtn animated:YES];
}


-(void)dismissPreviousPopover{
     if([postToChatterOptionActionSheet isVisible])
          [postToChatterOptionActionSheet dismissWithClickedButtonIndex:[postToChatterOptionActionSheet cancelButtonIndex] animated:YES];
     
}


-(IBAction)editPage:(id)sender
{
    CGRect frameimg = CGRectMake(0, 0, 27,27);
    if([readProp isEqualToString:@"No"])
    {
        if (self.navigationItem.rightBarButtonItem.tag == kEditButtonTag)
        {
            UIImage* saveImg = [UIImage imageNamed:@"Save.png"];
            UIImage* saveDoneImg = [UIImage imageNamed:@"Save_down.png"];
               
            UIButton *saveButton = [[UIButton alloc] initWithFrame:frameimg];
            [saveButton setBackgroundImage:saveImg forState:UIControlStateNormal];
            [saveButton setBackgroundImage:saveDoneImg forState:UIControlStateHighlighted];
            [saveButton addTarget:self action:@selector(editPage2:) forControlEvents:UIControlEventTouchUpInside];
            [saveButton setShowsTouchWhenHighlighted:YES];
            
            UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
            [saveButton release];
			
			
            UIImage* cancelImg = [UIImage imageNamed:@"Cancel.png"];
			
            //UIImage* editDownImg = [UIImage imageNamed:@"Edit_down.png"];
			
            CGRect frameimg = CGRectMake(0, 0, 27,27);
			UIButton *cancelButton = [[UIButton alloc] initWithFrame:frameimg];
			[cancelButton setBackgroundImage:cancelImg forState:UIControlStateNormal];
			[cancelButton addTarget:self action:@selector(cancelUpdate:) forControlEvents:UIControlEventTouchUpInside];
			[cancelButton setShowsTouchWhenHighlighted:YES];

			UIBarButtonItem *cancelBarButton =[[UIBarButtonItem alloc] initWithCustomView:cancelButton];
            [cancelButton release];
			
            flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
			NSArray *items = [NSArray arrayWithObjects:flexible,saveBarButton,cancelBarButton, nil];
            [saveBarButton release];
            [cancelBarButton release];
            [flexible release];
            
			[bottomBar setItems:items];
            
            
			//UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
               
			self.navigationItem.rightBarButtonItem = nil;
            
            
			
            // self.navigationItem.rightBarButtonItem.tag = saveBtnTag;
				//			UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithTitle:unblockContact style:UIBarButtonItemStyleBordered   target:self     action:@selector(onToolbarTapped:)];
				//			customItem.tintColor = [UIColor blackColor];
			
			[Utility showCoverScreenWithText:@"Edit mode activating..." andType:kInProcessCoverScreen];
			
//            [loadingSpinner startAnimating];
//			doneImgView.hidden = YES;
//			dialog_imgView.hidden = NO;
//			loadingLbl.text = @"Edit mode activating...";
//				//[loadingLbl sizeToFit];
//			loadingLbl.hidden = NO;
              
			[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
               [self setContentEditable:YES];
               [self setWebViewKeyPressDetectionEnabled:YES];
               [self setWebViewTapDetectionEnabled:YES];
               [self increaseZoomFactorRange];
		    
             
              //Show border around webView
              [self showBorderViewAroundWebView];
              
              //Keep track of old contents of WebView
              if(oldContent != nil)
              {
                  [oldContent release];
              }
             
              if(oldTitle != nil)
              {
                  [oldTitle release];
              }
             
              oldTitle = [[NSString alloc] initWithFormat:@"%@", editTitleField.text];
             
              oldContent = [[NSString alloc]initWithFormat:@"%@", [noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]];
         }
             
		/* else if (self.navigationItem.rightBarButtonItem.tag == saveBtnTag) {
		 [self.view endEditing:YES];
		 saveToSFBarBtn.enabled = YES;
		 postToChatterBarBtn.enabled = YES;
		 self.navigationItem.rightBarButtonItem.title = @"Edit";
		 
		 
		 UIImage* editImg = [UIImage imageNamed:@"Edit.png"];
		 UIImage* editDownImg = [UIImage imageNamed:@"Edit_down.png"];
		 UIButton *editButton = [[UIButton alloc] initWithFrame:frameimg];
		 [editButton setBackgroundImage:editImg forState:UIControlStateNormal];
		 [editButton setBackgroundImage:editDownImg forState:UIControlStateHighlighted];
		 [editButton addTarget:self action:@selector(editPage:) forControlEvents:UIControlEventTouchUpInside];
		 [editButton setShowsTouchWhenHighlighted:YES];
		 UIBarButtonItem *editBarButton =[[UIBarButtonItem alloc] initWithCustomView:editButton];
		 
		 self.navigationItem.rightBarButtonItem = editBarButton;
		 [editButton release];
		 self.navigationItem.rightBarButtonItem.tag = editBtnTag;
		 NSString *rawString = [editTitleField text];
		 NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		 NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
		 
		 if(trimmed.length == 0)
		 {
		 UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Text Error" message:@"Please enter valid text" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
		 [alert show];
		 saveToSFBarBtn.enabled = NO;
		 postToChatterBarBtn.enabled = NO;
		 
		 self.navigationItem.rightBarButtonItem.title = @"Save to Evernote";
		 
		 UIImage* saveImg = [UIImage imageNamed:@"Save.png"];
		 UIImage* saveDoneImg = [UIImage imageNamed:@"Save_down.png"];
		 
		 UIButton *saveButton = [[UIButton alloc] initWithFrame:frameimg];
		 [saveButton setBackgroundImage:saveImg forState:UIControlStateNormal];
		 [saveButton setBackgroundImage:saveDoneImg forState:UIControlStateHighlighted];
		 [saveButton addTarget:self action:@selector(editPage2:) forControlEvents:UIControlEventTouchUpInside];
		 [saveButton setShowsTouchWhenHighlighted:YES];
		 UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
		 
		 self.navigationItem.rightBarButtonItem = saveBarButton;
		 [saveButton release];
		 self.navigationItem.rightBarButtonItem.tag = saveBtnTag;
		 editTitleField.text = @"";
		 [self setWebViewKeyPressDetectionEnabled:YES];
		 [self setWebViewTapDetectionEnabled:YES];
		 [self increaseZoomFactorRange];
		 
		 }}*/
		 else
		 {
			 [self setContentEditable:NO];
			 [self setWebViewKeyPressDetectionEnabled:NO];
			 [self setWebViewTapDetectionEnabled:NO];
			 [self resignFirstResponder];
			 [noteContent resignFirstResponder];
			 [self updateNoteEvernote];
         }
     }
     else
     {
         [Utility hideCoverScreen];
         
         [Utility showCoverScreenWithText:@"Note is ReadOnly" andType:kWarningCoverScreen];
             
//         dialog_imgView.hidden = NO;
//         doneImgView.image = [UIImage imageNamed:@"2.png"];
//         doneImgView.hidden = NO;
//         [loadingSpinner stopAnimating];
//         loadingLbl.text = @"Note is ReadOnly";
//         loadingLbl.hidden = NO;
         

         [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
     }
}


-(void)setBorderViewFrame
{
    //Set frame of BorderView
    if(borderView != nil)
    {
        borderView.frame = CGRectMake(noteContent.frame.origin.x - 5, noteContent.frame.origin.y - 3, noteContent.frame.size.width + 10, noteContent.frame.size.height + 6);
    }
}


-(void)showBorderViewAroundWebView
{
    if(borderView == nil)
    {
        borderView = [[UIView alloc] init];
        borderView.frame = CGRectMake(noteContent.frame.origin.x - 5, noteContent.frame.origin.y - 3, noteContent.frame.size.width + 10, noteContent.frame.size.height + 6);
        [[borderView layer] setCornerRadius:10.0f];
        [[borderView layer] setBorderWidth:1.0f];
        [[borderView layer] setBorderColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor]];
    }
    
    
    [self.view addSubview:borderView];
    [self.view sendSubviewToBack:borderView];
}


-(void)hideBorderViewAroundWebView
{
    if(borderView != nil)
    {
        [borderView removeFromSuperview];
    }
}


-(void)editPage2:(id)sender
{
    if([Utility checkNetwork])
    {
        if([oldContent isEqualToString:[noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]]
           && [oldTitle isEqualToString:editTitleField.text])
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:@"No changes were made to note."
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        else
        {
//            //Remove the tapGestureRecognizers
//            if([noteContent gestureRecognizers] != nil && [[noteContent gestureRecognizers] count] > 0)
//            {
//                [noteContent removeGestureRecognizer:[[noteContent gestureRecognizers] objectAtIndex:0]];
//            }
            
            
            NSString *rawString = [editTitleField text];
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        
            if(trimmed.length == 0)
            {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Text Error" message:@"Please enter valid text." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
                [alert show];
                editTitleField.text = @"";
                [self setWebViewKeyPressDetectionEnabled:YES];
                [self setWebViewTapDetectionEnabled:YES];
                [self increaseZoomFactorRange];
            }
            else
            {                
                [self resignFirstResponder];
                [editTitleField resignFirstResponder];
                [noteContent resignFirstResponder];
                [self updateNoteEvernote];
            }
        }
    }
    else
    {
        //Show network unavailable message
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}


-(void)cancelUpdate:(id)sender
{
    isEditNoteCancelled = YES;
    
//    //Remove the tapGestureRecognizers
//    if([noteContent gestureRecognizers] != nil && [[noteContent gestureRecognizers] count] > 0)
//    {
//        [noteContent removeGestureRecognizer:[[noteContent gestureRecognizers] objectAtIndex:0]];
//    }
    
    //Hide border around webView
    [self hideBorderViewAroundWebView];
    
	[self setContentEditable:NO];
	[self setWebViewKeyPressDetectionEnabled:NO];
	[self setWebViewTapDetectionEnabled:NO];
	[self resignFirstResponder];
	NSArray *items = [NSArray arrayWithObjects: nil];
	[bottomBar setItems:items];
    
    [self viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self showSelectedNoteContent];
    }
	
    //noteContent.userInteractionEnabled = NO;
}

-(void)moveToSF
{
    RootViewController * rootVC = [[RootViewController alloc] init];
    rootVC.fileName = self.title;
    rootVC.noteContent = textContent;
          //rootVC.noteContent = noteContent.text;
    [self.navigationController pushViewController:rootVC animated:YES];
    [rootVC release];
     
//    [Utility hideCoverScreen];
     
}

/************************************************************
 *
 *  Function that closes the view
 *  On the back click
 *
 ************************************************************/

-(void)goBack:(id)sender
{
     [self.parentViewController dismissModalViewControllerAnimated:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{    
    [self changeBkgrndImgWithOrientation];
    
    //Set border view's frame
    [self setBorderViewFrame];
    
    
		//self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	orgBounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
//	flag2=1;
//	flag=0;
}


#pragma mark - View lifecycle
- (void)viewDidUnload
{
     [super viewDidUnload];
          // Release any retained subviews of the main view.
          // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    //[noteImage release];
    [noteNavigation release];
    [noteContent release];
    [_masterViewController release];
    [_notesViewController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
          // Releases the view if it doesn't have a superview.
     [super didReceiveMemoryWarning];
     
          // Release any cached data, images, etc that aren't in use.
}




- (void)setWebViewTapDetectionEnabled:(BOOL)isEnabled {
     static NSString *const event = @"touchend";
     
     NSString *addKeyPressEventJS = [NSString stringWithFormat:
                                     @"function redirect() { window.location = '%@'; }"
                                     "document.addEventListener('%@',redirect,false);",
                                     kWebViewDidTapURL,
                                     event];
     
     NSString *removeKeyPressEventJS = [NSString stringWithFormat:
                                        @"document.removeEventListener('%@',redirect,false);",event];
     
     NSString *js = nil;
     
     if (isEnabled)
          js = addKeyPressEventJS;
     else
          js = removeKeyPressEventJS;
     
     NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:js];
     
     DebugLog(@"result=%@",result);
}

- (void)setWebViewKeyPressDetectionEnabled:(BOOL)isEnabled {
     static NSString *const event = @"keydown";
     
     NSString *addKeyPressEventJS = [NSString stringWithFormat:
                                     @"function redirect() { window.location = '%@'; }"
                                     "document.body.addEventListener('%@',redirect,false);",
                                     kWebViewDidPressKeyURL,
                                     event];
     
     NSString *removeKeyPressEventJS = [NSString stringWithFormat:
                                        @"document.body.removeEventListener('%@',redirect,false);",event];
     
     NSString *js = nil;
     
     if (isEnabled)
          js = addKeyPressEventJS;
     else
          js = removeKeyPressEventJS;
     
     NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:js];
     DebugLog(@"%@",result);
}


- (void)setContentEditable:(BOOL)isEditable
{
	if(isEditable)
    {
//	    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shiftwebview)];
//		tap.numberOfTapsRequired = 1;
//		tap.delegate = self;
//		
//		[noteContent addGestureRecognizer:tap];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];    // Do any additional setup after loading the view from its nib.
		
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                editTitleField = [[[UITextField alloc]initWithFrame:CGRectMake(15,31,674,30)] autorelease];
            }
            else if(self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || self.interfaceOrientation == UIInterfaceOrientationPortrait)
            {
                editTitleField = [[[UITextField alloc]initWithFrame:CGRectMake(15,31,738,30)] autorelease];
            }
        }
        else
        {
            if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                editTitleField = [[[UITextField alloc]initWithFrame:CGRectMake(15,31,445,30)] autorelease];
            }
            else if(self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown || self.interfaceOrientation == UIInterfaceOrientationPortrait)
            {
                editTitleField = [[[UITextField alloc]initWithFrame:CGRectMake(15,31,295,30)] autorelease];
            }
        }
		
		
		editTitleField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		noteContent.frame = CGRectMake(noteContent.frame.origin.x,100,self.view.frame.size.width-35,self.view.frame.size.height-150);
        
        //Set border view's frame
        [self setBorderViewFrame];
             
        editTitleField.text = tempTitle;
        NSLog(@"%@", tempTitle);
        editTitleField.borderStyle = UITextBorderStyleRoundedRect;
        editTitleField.delegate=self;
        [self.view addSubview:editTitleField];
        
    }
    else
    {
        editTitleField.hidden = TRUE;
        noteContent.frame = CGRectMake(noteContent.frame.origin.x,2,self.view.frame.size.width-35,self.view.frame.size.height-50);

        //Set border view's frame
        [self setBorderViewFrame];
        
        if(isEditNoteCancelled)
        {
            self.title = tempTitle;
            
            isEditNoteCancelled = NO;
        }
        else
        {
            NSString *rawString = [editTitleField text];
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
            if ([trimmed length] != 0)
            {
                self.title = trimmed;
                tempTitle = self.title;
            }
        }
        
        
    }
	
	
	NSString *jsEnableEditing =	[NSString stringWithFormat:@"document.documentElement.contentEditable=%@;", isEditable ? @"true" : @"false"];
	NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:jsEnableEditing];
	
	DebugLog(@"editable %@",result);
	
}


CGRect activeField,orgBounds;

-(void)keyboardDidShow:(NSNotification*)aNotification
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    
    if(editTitleField.isFirstResponder)
	{
		activeField=editTitleField.frame;
		self.view.frame=CGRectMake(self.view.frame.origin.x, -31, self.view.frame.size.width, self.view.frame.size.height);
	}
	else //if(flag2 ==1)
	{
		activeField=noteContent.frame;
		self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	//flag=1;
	
	[UIView commitAnimations];
}

//-(void)shiftwebview
//{
//	if(flag ==0)
//    {
//        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//        [UIView setAnimationDuration:kAnimationDuration];
//        
//		self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
//        [UIView commitAnimations];
//        
//		flag=1;
//	}
//}


-(void)keyboardDidHide:(NSNotification*)aNotification
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:kAnimationDuration];
    
	self.view.frame=orgBounds;
	
    [UIView commitAnimations];
	
    
//    if(flag2 !=1)
//    {
//		flag = 0;
//    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)increaseZoomFactorRange {
     NSString *js = @"function increaseZoomFactorRange() {"
     "   var element = document.createElement('meta');"
     "   element.name = 'viewport';"
     "   element.content = 'maximum-scale=5,minimum-scale=0.5';"
     "   var head = document.getElementsByTagName('head')[0];"
     "   head.appendChild(element);"
     "}"
     "increaseZoomFactorRange();";
     
     [noteContent stringByEvaluatingJavaScriptFromString:js];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
     DebugLog(@"Url to load = %@",request.URL.absoluteString);
    
     if ([request.URL.absoluteString isEqualToString:kWebViewDidPressKeyURL])
     {
          [self setWebViewKeyPressDetectionEnabled:NO];
          return NO;
     }
     else if ([request.URL.absoluteString isEqualToString:kWebViewDidTapURL])
     {
          [self setWebViewKeyPressDetectionEnabled:NO];
          return NO;
     }
     else if ([request.URL.absoluteString isEqualToString:@"about:blank"])
     {
          return YES;
     }
     
     return NO;
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//     [Utility showAlert:@"Failed to load note contents."];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
          //[self setContentEditable:YES];
          //[self setWebViewKeyPressDetectionEnabled:YES];
          //[self setWebViewTapDetectionEnabled:YES];
          //[self increaseZoomFactorRange];
}




-(void)updateNoteEvernote
{
      // Closing controls
     [noteContent resignFirstResponder];
     
     // Creating the Note Object
     EDAMNote * note = [[[EDAMNote alloc] init]autorelease];
     note.title = editTitleField.text;
     
     NSMutableString *bodyTxt =(NSMutableString *) [noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
     DebugLog(@"htmlString : %@",bodyTxt);
     
     
     NSString *stringToRemove = [NSString stringWithFormat:@"%@>",[self getDataBetweenFromString:bodyTxt leftString:@" xmlns=\"http://www.w3.org/1999/xhtml\"" rightString:@">" leftOffset:0]];
     
     DebugLog(@"stringToRemove = %@", stringToRemove);
     
     bodyTxt = [[bodyTxt stringByReplacingOccurrencesOfString:stringToRemove withString:@">"] mutableCopy] ;
     
     
     NSString * ENML = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n%@",bodyTxt];
     DebugLog(@"ENML:%@", ENML);
     
     
     // Adding the content to the note
     [Utility showCoverScreenWithText:@"Updating Note..." andType:kInProcessCoverScreen];
    
     [note setContent:ENML];
     note.guid = self.guid;
//     [loadingSpinner startAnimating];

//    dialog_imgView.hidden = NO;
//     loadingLbl.text = @"Updating Note...";
//          //[loadingLbl sizeToFit];
//     loadingLbl.hidden = NO;
    
     __block BOOL isErrorCreatingnote = NO;
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
               // Saving the note on the Evernote servers
               // Simple error management
          @try {
               EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
               [noteStore updateNote:note success:^(EDAMNote *note)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                      DebugLog(@"update note success%@ :::: ",note);
                      if(isErrorCreatingnote == NO)
                      {
                          //Hide border around webView
                          [self hideBorderViewAroundWebView];
                          
                          //Set screen to non edit mode
                          [self setContentEditable:NO];
                          [self setWebViewKeyPressDetectionEnabled:NO];
                          [self setWebViewTapDetectionEnabled:NO];
                          [self addEditBarButtonItem];
                          
                          //Add bottom bar buttons in non edit mode
                          [self addBottomBarButtonsInNonEditMode];
                          
                          
                           NSString *stringToReplace = [NSString stringWithFormat:@"<en-note%@>",[self getDataBetweenFromString:ENML leftString:@"<en-note" rightString:@">" leftOffset:8]];
                           
                           NSString *updatedString = [NSString stringWithFormat:@"<en-note%@ xmlns=\"http://www.w3.org/1999/xhtml\">",[self getDataBetweenFromString:ENML leftString:@"<en-note" rightString:@">" leftOffset:8]];
                           
                           NSString *updatedContent = [ENML stringByReplacingOccurrencesOfString:stringToReplace withString:updatedString];
                           updatedContent = [updatedContent stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"&#160;"];
                           updatedContent = [updatedContent stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"&#151;"];
                           
                           textContent = (NSMutableString *)[[[Utility flattenNoteBody:updatedContent]stringByDecodingHTMLEntities] retain];
                           DebugLog(@"update textcontent:%@", textContent);
                                // Alerting the user that the note was created
                          
                          //Show progress indicator
                          //[Utility showCoverScreenWithText:@"Saving Note..." andType:kInProcessCoverScreen];
                          
                          //Hide progress indicator
                          [Utility hideCoverScreen];
                          
                          //If device is iPad then update the notes list as well
                          if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                          {
                              if(self.notesViewController == nil)
                              {
                                 [self.masterViewController fetchDataFromEverNote];
                              }
                              else
                              {
                                  [self.notesViewController fetchDataFromEvernote];
                              }
                          }
                          
                          //Reload note details after updating note
//                          [self reloadNoteDetailsAfterUpdatingNote];
                              
                          //[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
                      }
//                    [loadingSpinner stopAnimating];
                 });
              }
                
              failure:^(NSError *error)
              {
                  dispatch_async(dispatch_get_main_queue(), ^(void)
                  {
                      DebugLog(@"update note::::::::error %@", error);
                      
                      //Hide progress indicator
                      [Utility hideCoverScreen];
                      
                      NSString * errorMessage = [NSString stringWithFormat:@"Error updating note."];
                      [Utility showAlert:errorMessage];
                      
                      isErrorCreatingnote = YES;
                      
                      //Add edit bar button item
//                      [self addEditBarButtonItem];
//                      
//                       [self setContentEditable:NO];
//                       [self setWebViewKeyPressDetectionEnabled:NO];
//                       [self setWebViewTapDetectionEnabled:NO];
                            //[delegate evernoteCreationFailedListener];
                      
    
                      //Reload note details 
                      //[self reloadNoteDetailsAfterUpdatingNote];
                      
                      return;
                  });
                                  
              }];
         }
         @catch (id  exception)
         {
              dispatch_async(dispatch_get_main_queue(), ^(void)
              {
                    NSString * errorMessage = [NSString stringWithFormat:@"Error updating note"];
                    [Utility showAlert:errorMessage];
                   
                    //Hide progress indicator
                    [Utility hideCoverScreen];
                   
                    isErrorCreatingnote = YES;

                    return;
               });
         }
          
     });
    
    
    
//	NSArray *items = [NSArray arrayWithObjects: nil];
//
//		//[items removeObjectAtIndex:0];
//	[bottomBar setItems:items];
//	[self viewDidLoad];
//
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self showSelectedNoteContent];
//        [self.masterViewController fetchDataFromEverNote];
//    }
    
	//noteContent.userInteractionEnabled = NO;
}


-(void)reloadNoteDetailsAfterUpdatingNote
{
    NSArray *items = [NSArray arrayWithObjects: nil];
    
    //[items removeObjectAtIndex:0];
    [bottomBar setItems:items];
    [self viewDidLoad];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        updateNotesListAfterNoteEditing = YES;
        
        [self showSelectedNoteContent];
    }
}


//-(void)showLoadingLblWithText:(NSString*)Loadingtext
//{
//    //Show progress indicator
//    [Utility showCoverScreenWithText:Loadingtext andType:kInProcessCoverScreen];
//    
////  [loadingSpinner startAnimating];
////  dialog_imgView.hidden = NO;
////  loadingLbl.text = Loadingtext;
////  loadingLbl.hidden = NO;
//}

-(void)hideDoneToastMsg:(id)sender
{
    //Hide progress indicator
    [Utility hideCoverScreen];
    
//	dialog_imgView.hidden = YES;
//    loadingLbl.hidden = YES;
//    doneImgView.hidden = YES;
//    [loadingSpinner stopAnimating];


	
//[delegate evernoteCreatedSuccessfullyListener];
}



#pragma mark - SFRestAPIDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
     DebugLog(@"request:%@",[request description]);
     DebugLog(@"jsonResponse:%@",jsonResponse);
     
     if([[request path] rangeOfString:POST_TO_CHATTER_WALL_URL].location != NSNotFound)
     {
          //post to wall
          if([[jsonResponse objectForKey:@"errors"] count]==0)
          {
              [Utility hideCoverScreen];
              
              //Show progress indicator
              [Utility showCoverScreenWithText:salesforce_chatter_post_self_success_message andType:kProcessDoneCoverScreen];
              
//              [self showLoadingLblWithText:salesforce_chatter_post_self_success_message];
              
              [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
              
//              [loadingSpinner stopAnimating];
              
              NSArray *records = [jsonResponse objectForKey:@"records"];
              
              DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
               
          }
          else{
//               [loadingSpinner stopAnimating];
               [Utility showAlert:POSTING_NOTE_FAILED_TO_CHATTER_WALL_MSG];
               [Utility hideCoverScreen];
          }
          
          
     }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
     DebugLog(@"request:didFailLoadWithError: %@ code:%d path:%@", error,error.code,request.path);
     DebugLog(@"request:didFailLoadWithError:error.userInfo :%@",error.userInfo);
     [Utility hideCoverScreen];
     [self hideDoneToastMsg:nil];
          //add your failed error handling here
     NSString *alertMessaage ;
     if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"]) {
          alertMessaage = CHATTER_LIMIT_CROSSED_ERROR_MSG;
     } else if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"API_DISABLED_FOR_ORG"]) {
          alertMessaage = CHATTER_API_DISABLED;
     }
     else {
          alertMessaage = [error.userInfo valueForKey:@"message"];
     }
     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:alertMessaage delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
     [alert show];
     [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
     DebugLog(@"requestDidCancelLoad: %@", request);
          //add your failed error handling here
     [Utility hideCoverScreen];
     [self hideDoneToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
     DebugLog(@"requestDidTimeout: %@", request);
          //add your failed error handling here
     [Utility hideCoverScreen];
     [self hideDoneToastMsg:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
     
     return [textField resignFirstResponder];
}



#pragma mark - Split View Controller Delegate Methods

//-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
//{
//    return NO;
//}


- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Notes", @"Notes");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
}

@end