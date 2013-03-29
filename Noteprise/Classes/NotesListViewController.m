	//
	//  NotesListViewController.m
	//  client
	//
	//  Evernote API sample code is provided under the terms specified in the file LICENSE.txt which was included with this distribution.
	//

#import "NotesListViewController.h"
#import "RootViewController.h"

#import "SettingsViewController.h"
#import "SignInViewController.h"
#import "NoteDetailViewController.h"
#import "Keys.h"
#import "EvernoteSDK.h"
#import "InfoViewController.h"
#import "SFNativeRestAppDelegate.h"




@implementation NotesListViewController

@synthesize  noteBooks;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
			// Custom initialization
	}
	return self;
}
	//viewDidLoad method declared in RootViewController.m
- (void)viewDidLoad
{	
	[super viewDidLoad];
   
    //Add cover screen
    //[Utility addSemiTransparentOverlay];
    
    notebookCountForLoadedNotes = 0;
    isError = NO;
    isSearchModeEnabled = NO;
	fetchNotesList = YES;
    flag1 = 0;
	flag2 = 0;
	searchBar.text = @"";
	orgTableOriginY = notesTbl.frame.origin.y;
    
	if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
		addNoteBtn.enabled = NO;
	}
	
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
    {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Toolbar_768x44.png"] forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
	}
	
	//Initialize the arrays
	listOfNotes = [[NSMutableArray alloc] init];
	listOfNotebooks = [[NSMutableArray alloc] init];
	listOfTags = [[NSMutableArray alloc] init];
	searchResults = [[NSMutableArray alloc] init];
	backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
	UIImage *buttonImage = [UIImage imageNamed:@"Logout.png"];
	UIImage *buttonSelectedImage = [UIImage imageNamed:@"Logout_down.png"];
	
    //create the button and assign the image
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:buttonImage forState:UIControlStateNormal];
	[button setImage:buttonSelectedImage forState:UIControlStateSelected];
	[button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
		//sets the frame of the button to the size of the image
	button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
		//creates a UIBarButtonItem with the button as a custom view
	UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	self.navigationItem.leftBarButtonItem = customBarItem;
	
//    //Create InfoBarButton and add it as a navigation bar's right bar button
//    UIButton * infobutton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//    [infobutton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * infoBarButton = [[UIBarButtonItem alloc]initWithCustomView:infobutton];
//    self.navigationItem.rightBarButtonItem = infoBarButton;
//    [infoBarButton release];
    
    
    UIImageView * logo = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 187.0f, 31.0f)];
	logo.image = [UIImage imageNamed:@"noteprise_logo.png"];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		logo.image = [UIImage imageNamed:@"Noteprise_icon_iPhone.png"];
	logo.center = [self.navigationController.navigationBar center];
	self.navigationItem.titleView = logo;
	notesTbl.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
	NSString *device,*orientation;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		device = @"iPhone";
		if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
			orientation = @"landscape";
		else
			orientation = @"potrait";
	} else {
		device = @"iPad";
		if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
			orientation = @"landscape";
		else
			orientation = @"potrait";
	}
    
    
//    //If device is ipad then loadNotesList on viewDidLoad
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self loadNotesList];
//    }
    
    
    //Set tint color of UISegmentedControl
    //[searchOptionsChoiceCntrl setTintColor:[UIColor colorWithRed:169.0f/255.0f green:216.0f/255.0f blue:238.0f/255.0f alpha:1]];
    
    //UIColor * tintColor = [UIColor colorWithRed:169.0f/255.0f green:216.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    //searchOptionsChoiceCntrl.tintColor = tintColor;
    
    //UIColor *selectedTintColor = [UIColor colorWithRed: 0/255.0 green:255/255.0 blue:0/255.0 alpha:1.0];
    //[[[searchOptionsChoiceCntrl subviews] objectAtIndex:0] setTintColor:selectedTintColor];
    
		//Customize segement control buttons
	//[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_all_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:0];
	//[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_notebook_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:1];
	//[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_tag_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:2];
	
	//[searchOptionsChoiceCntrl setBackgroundColor:[UIColor whiteColor]];
		//Customize segement control search bar

    
    //searchBar.tintColor = [UIColor colorWithRed:169.0f/255.0f green:216.0f/255.0f blue:238.0f/255.0f alpha:1];
    
//	for (UIView * subview in searchBar.subviews) {
//		if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//        {
//			DebugLog(@"width:%f",subview.frame.size.width);
//			UIView *bg = [[UIView alloc] initWithFrame:subview.frame];
//			bg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//			bg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Search_bar_background_1x44.png"]];
//			[searchBar insertSubview:bg aboveSubview:subview];
//			[subview removeFromSuperview];
//			break;
//		}
//    }
	
	
}


//Shows the InfoViewController
-(void)infoButtonPressed
{
    NSString * userName = [((SFNativeRestAppDelegate *)[[UIApplication sharedApplication]delegate]) userName];
    
    if(userName != nil && ![userName isEqualToString:@""])
    {
        InfoViewController * infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
        [self.navigationController pushViewController:infoViewController animated:YES];
        [infoViewController release];
    }
}


-(void)changeSegmentControlBtnsWithOrientationAndDevice
{
	NSString *device,*orientation;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		device = @"iPhone";
		if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
			orientation = @"landscape";
		else
			orientation = @"potrait";
	} else {
		device = @"iPad";
		if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
			orientation = @"landscape";
		else
			orientation = @"potrait";
	}
		//Customize segement control buttons
//	if([searchOptionsChoiceCntrl selectedSegmentIndex] == 0)
//		[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_all_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:0];
//	else
//		[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_all_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:0];
//	if([searchOptionsChoiceCntrl selectedSegmentIndex] == 1)
//		[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_notebook_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:1];
//	else [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_notebook_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:1];
//	if([searchOptionsChoiceCntrl selectedSegmentIndex] == 2)
//		[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_tag_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:2];
//	else
//		[searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_tag_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:2];
}



-(void)loadNotesList
{
    if(!isSearchModeEnabled)
    {
        [self changeSegmentControlBtnsWithOrientationAndDevice];
        [self fetchNoteBasedOnSelectedSegement];
        
        if(flag1 == 0)
        {
            searchbarFrame = searchBar.frame;
            orgTableHeight = notesTbl.frame.size.height;
            orgBarOriginY = bottom_bar.frame.origin.y;
        }
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    if(fetchNotesList)
    {
        [self loadNotesList];
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fetchNotesList = NO;
    }
    
    [super viewDidAppear:animated];
    
//    for (id subview in [searchBar subviews]) {
//		if ([subview isKindOfClass:[UIButton class]]) {
//			[subview setEnabled:YES];
//            //[subview addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
//		}
//	}
    
		
}

/*-(void)changeBkgrndImgWithOrientation {
 if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
 if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
 backgroundImgView.image = [UIImage imageNamed:@"bgE-480x287.png"];
 else {
 backgroundImgView.image = [UIImage imageNamed:@"bgE-320x480.png"];
 }
 } else {
 if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
 backgroundImgView.image = [UIImage imageNamed:@"bgE-1024x572.png"];
 else {
 backgroundImgView.image = [UIImage imageNamed:@"bgE-768x1024.png"];
 }
 }
 }*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	orgTableHeight = notesTbl.frame.size.height;
	orgBarOriginY = bottom_bar.frame.origin.y;
	[self changeSegmentControlBtnsWithOrientationAndDevice];
    
    //Set progress indicator's position
    //[self setProgressIndicatorPosition:interfaceOrientation];
}


//-(void)setProgressIndicatorPosition:(UIInterfaceOrientation)interfaceOrientation
//{
//    if(interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        dialog_imgView.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
//        loadingLbl.center = CGPointMake(self.view.center.x, self.view.center.y);
//    }
//    else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        dialog_imgView.center = CGPointMake(self.view.center.x, self.view.center.y - 10);
//        loadingLbl.center = CGPointMake(self.view.center.x, self.view.center.y + 10);
//    }
//}


-(IBAction)showSettings:(id)sender
{
	SettingsViewController *settingsView = [[SettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
	settingsView.popover_delegate = self;
	UINavigationController *settingsNavCntrl = [[UINavigationController alloc] initWithRootViewController:settingsView];
	settingsNavCntrl.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		//sendSubView.view.frame=CGRectMake(0, 0, 300, 400);
		[self dissmissPopover];
		UIPopoverController *popoverSettings = [[UIPopoverController alloc] initWithContentViewController:settingsNavCntrl];
			//popoverSend.delegate = self;
        
		//settingsNavCntrl.contentSizeForViewInPopover = CGSizeMake(320, 400);

        
		popoverController = popoverSettings;
		[popoverSettings presentPopoverFromBarButtonItem:settingsBtn
						    permittedArrowDirections:UIPopoverArrowDirectionAny
										animated:YES];
        
     	//[popoverSettings release];
	}
    else
    {
		if ([settingsNavCntrl.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
        {
            [settingsNavCntrl.navigationBar setBackgroundImage:[UIImage imageNamed:@"Toolbar_768x44.png"] forBarMetrics:UIBarMetricsDefault];
            settingsNavCntrl.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
        }
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered
														    target:self action:@selector(dismissModalView)];
		settingsView.navigationItem.leftBarButtonItem = cancelButton;
		[self.navigationController presentModalViewController:settingsNavCntrl animated:YES];
		[cancelButton release];
	}
}


-(IBAction)showNotes:(id)sender
{
    //Clear table data as a new segment is selected
    if(searchOptionsChoiceCntrl.selectedSegmentIndex == 0)
    {
        [listOfNotes removeAllObjects];
    }
    else if(searchOptionsChoiceCntrl.selectedSegmentIndex == 1)
    {
        [listOfNotebooks removeAllObjects];
    }
    else if(searchOptionsChoiceCntrl.selectedSegmentIndex == 1)
    {
        [listOfTags removeAllObjects];
    }
    
    [notesTbl reloadData];
    
    [self changeSegmentControlBtnsWithOrientationAndDevice];
//    searchBar.userInteractionEnabled = NO;
    //searchBar.alpha = 0.75;
    searchBar.text = @"";
    searchKeyword = @"";
    
    //Show loading indicator
    [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
    
    //[self showLoadingLblWithText:LOADING_MSG];
    
    [self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
            // Loading all the notebooks linked to the account using the evernote API
        [self fetchDataFromEverNote];
    });
}


-(void)logout
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[alert show];
	[alert release];
	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		[[EvernoteSession sharedSession] logout];
		SignInViewController *loginView = [[SignInViewController alloc]init];

		[[[UIApplication sharedApplication]delegate]window].rootViewController = loginView;
		[loginView release];
    }	
}

-(void)fetchDataFromEverNote
{
    //Show progress indicator
    [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
			// Loading all the notebook & tags linked to the account using the evernote API
		@try
        {
			EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
			[noteStore listNotebooksWithSuccess:^(NSArray *noteBooksArr) {
				DebugLog(@"notebooks fetched: %@", noteBooksArr);
				noteBooks = [noteBooksArr retain];
				DebugLog(@"notebooks: %@", noteBooks);
			}
								   failure:^(NSError *error)
                                   {
									   DebugLog(@"error %@", error);
//                                       

								   }];
			
			[noteStore listTagsWithSuccess: ^(NSArray *tagsArr) {
				DebugLog(@"tagsArr fetched: %@", tagsArr);
				tags = [tagsArr retain];
				DebugLog(@"tagsArr: %@", tagsArr);
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					switch (searchOptionsChoiceCntrl.selectedSegmentIndex) {
						case 0:
							[self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
							if (![searchBar.text isEqualToString:@""]) {
								[self searchNotes:searchBar.text];
							}
							else
							    {
								[self listAllNotes];
							    }
							break;
						case 1:
							[self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
							
							if (![searchBar.text isEqualToString:@""]) {
								[self searchNotes:searchBar.text];
							}
							else
                            {
                                [self listAllNotebooks];
                            }
							
							break;
						case 2:
							[self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
							
							
							if (![searchBar.text isEqualToString:@""]) {
								[self searchNotes:searchBar.text];
							}
							else{
								
								[self listAllTags];
							}
							break;
					}
//					searchBar.userInteractionEnabled = YES;
					//searchBar.alpha = 0.75;
					
				});
			}
							   failure:^(NSError *error)
                               {
								   DebugLog(@"error %@", error.localizedFailureReason);

                                   //Hide loading indicator
                                   [Utility hideCoverScreen];
                                   
                                   //[self hideDoneToastMsg:nil];
                                   
                                   
                                   //Show error message
                                   if(error.code == -3000)
                                   {
                                       [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
                                       
                                   }
                                   else
                                   {
                                       [Utility showAlert:@"An error occured."];
                                       
                                   }

							   }];
			
		}
		@catch (EDAMUserException *exception) {
			DebugLog(@"Recvd Exception:%d",exception.errorCode );
			[Utility showAlert:EVERNOTE_LOGIN_FAILED_MSG];
		}
		@catch (EDAMSystemException *exception) {
			[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
		}
		@catch (EDAMNotFoundException *exception) {
			[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
		}
		
	});
}


-(void)fetchNoteBasedOnSelectedSegement
{
    //[self showLoadingLblWithText:LOADING_MSG];

    [self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
    
    // Loading all the notebooks linked to the account using the evernote API
    [self fetchDataFromEverNote];
}


//-(void)showLoadingLblWithText:(NSString*)Loadingtext{
////	dialog_imgView.hidden = NO;
////	loadingLbl.text = Loadingtext;
////	loadingLbl.hidden = NO;
//}
//-(void)hideDoneToastMsg:(id)sender{
////	dialog_imgView.hidden = YES;
////	loadingLbl.hidden = YES;
//}


-(void)listAllNotes
{
	[listOfNotes removeAllObjects];
	
    @try
    {
        if([noteBooks count] > 0)
        {
            for (int i = 0; i < [noteBooks count]; i++)
		    {			
				// listing all the notes for every notebook
			
				// Accessing notebook
                EDAMNotebook * notebook = (EDAMNotebook*)[noteBooks objectAtIndex:i];
				// Creating & configuring filter to load specific notebook
                EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
                [filter setNotebookGuid:[notebook guid]];
                [filter setOrder:NoteSortOrder_TITLE];
                [filter setAscending:YES];
			
				// Searching on the Evernote API
                EvernoteNoteStore * noteStore = [EvernoteNoteStore noteStore];
			
                [noteStore findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *noteList)
                {
                    if([noteList.notes count] > 0)
                    {
                        for (EDAMNote *noteRead in noteList.notes)
                        {
                            // Populating the arrays
                            NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
					
                            [noteListDict setValue:[noteRead title] forKey:NOTE_KEY];
                            [noteListDict setValue:[noteRead guid] forKey:NOTE_GUID_KEY];
                            NSString *readProp = noteRead.attributes.contentClass?@"Yes":@"No";
                            [noteListDict setValue:readProp forKey:READABLE];
                            [listOfNotes addObject:noteListDict];
//                            [self reloadNotesTable];
                            [noteListDict release];
                        }
                        
                        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                        listOfNotes = [[listOfNotes sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
                        DebugLog(@"SORTED list Of all Notes: new%@",listOfNotes);
                    }
                    
                    //Increament counter
                    notebookCountForLoadedNotes++;
                                        
                    [self reloadTableWhenAllNotesReceived];                    
                    
                }
                failure:^(NSError *error)
                {
                    DebugLog(@" findNotesWithFilter error %@", error);
                    
                    //Increament counter
                    notebookCountForLoadedNotes++;
                    
                    isError = YES;
                    
                    [self reloadTableWhenAllNotesReceived];
                    
                }];
			
		    }
        }
        else
        {
            [self reloadNotesTable];           
        }
		
	}
	@catch (EDAMSystemException *exception) {
		[Utility showExceptionAlert:exception.description];
	}
	@catch (EDAMNotFoundException *exception) {
		[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
	}
	@catch (id exception) {
		DebugLog(@"Recvd Exception");
		[Utility showExceptionAlert:ERROR_LISTING_NOTE_MSG];
	}
	
}


-(void)reloadTableWhenAllNotesReceived
{
    if(notebookCountForLoadedNotes == [noteBooks count])
    {
        //Reload table to show notes
        [self reloadNotesTable];
        
        //Show error if any
        if(isError)
        {
            [Utility showExceptionAlert:@"An error occured."];
        }
        
        //Reset variables
        notebookCountForLoadedNotes = 0;
        isError = NO;
    }
    
}



-(void)listAllNotebooks {
	[listOfNotebooks removeAllObjects];
	@try {
        if([noteBooks count] > 0)
        {
            for (int i = 0; i < [noteBooks count]; i++)
		    {			
				// listing all the notes for every notebook
			
				// Accessing notebook
                EDAMNotebook* notebook = (EDAMNotebook*)[noteBooks objectAtIndex:i];
				// Creating & configuring filter to load specific notebook
                EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
                [filter setNotebookGuid:[notebook guid]];
                [filter setOrder:NoteSortOrder_TITLE];
                [filter setAscending:YES];
                NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
			
                [noteListDict setValue:[notebook name] forKey:NOTEBOOK_KEY];
			
			
                [listOfNotebooks addObject:noteListDict];
//                [self reloadNotesTable];
			
                [noteListDict release];
			
		    }
        }
        
        //Reload table
        [self reloadNotesTable];
        
		
	}
	@catch (EDAMSystemException *exception) {
		[Utility showExceptionAlert:exception.description];
	}
	@catch (EDAMNotFoundException *exception) {
		[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
	}
	@catch (id exception) {
		DebugLog(@"Recvd Exception");
		[Utility showExceptionAlert:ERROR_LISTING_NOTE_MSG];
	}
	
}


-(void)listAllTags
{
	[listOfTags removeAllObjects];
	@try {
        if([tags count] > 0)
        {
            for (int i = 0; i < [tags count]; i++)
		    {
			    // Accessing notebook
                EDAMTag * tag = (EDAMTag*)[tags objectAtIndex:i];
				// Creating & configuring filter to load specific notebook
                EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
                [filter setNotebookGuid:[tag guid]];
                [filter setOrder:NoteSortOrder_TITLE];
                [filter setAscending:YES];
				
                // Populating the arrays
                NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
				[noteListDict setValue:[tag name] forKey:TAG_KEY];
                [listOfTags addObject:noteListDict];
//                [self reloadNotesTable];
                [noteListDict release];
		    }
		}
        
        //Reload table
        [self reloadNotesTable];
        
	}
    
	@catch (EDAMSystemException *exception)
    {
		[Utility showExceptionAlert:exception.description];
	}
    
	@catch (EDAMNotFoundException *exception)
    {
		[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
	}
    
	@catch (id exception)
    {
		DebugLog(@"Recvd Exception");
		[Utility showExceptionAlert:ERROR_LISTING_NOTE_MSG];
	}
}



-(void)reloadNotesTable
{
	[Utility hideCoverScreen];
    
	[self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
	
    notesTbl.delegate =self;
	notesTbl.dataSource =self;
    
	//[self hideDoneToastMsg:nil];
	//loadingLbl.hidden = YES;
	
    [notesTbl reloadData];
}

-(void)stopActivity
{
	[Utility hideCoverScreen];
    
	[self makeSearchBarResignFirstResponder]; //Instead of [searchBar resignFirstResponder];
	
    //[self hideDoneToastMsg:nil];
	//loadingLbl.hidden = YES;
}

-(void)searchNotes:(NSString*)searchingKeyword {
	
	searchKeyword = searchingKeyword;
	[searchResults removeAllObjects];__block int flag=0;
	if((![Utility isBlank:searchingKeyword])){
		@try
        {
			for (int i = 0; i < [noteBooks count]; i++)
			{
				// Accessing notebook
				EDAMNotebook* notebook = (EDAMNotebook*)[noteBooks objectAtIndex:i];
				EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
				
                // Creating & configuring filter to load specific notebook
				EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
				[filter setNotebookGuid:[notebook guid]];
				
				[noteStore findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *noteList){
					for (EDAMNote *noteRead in noteList.notes) {
							// Populating the arrays
						NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
						[noteListDict setValue:[noteRead title] forKey:NOTE_KEY];
						[noteListDict setValue:[noteRead guid] forKey:NOTE_GUID_KEY];
						NSString *readProp = noteRead.attributes.contentClass?@"Yes":@"No";
						[noteListDict setValue:readProp forKey:READABLE];
						if([[noteRead title] rangeOfString:searchingKeyword options:NSCaseInsensitiveSearch].location!=NSNotFound){
							
							[searchResults addObject:noteListDict];
							flag=1;
						}
						
						
						[noteListDict release];
					}
					if(i == [noteBooks count]- 1 && flag !=1) {
						[Utility showAlert:NOTE_NOT_FOUND];
					}
					NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					searchResults = [[searchResults sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
					DebugLog(@"sorted list Of notes found:%@",searchResults);
					
//                    [self reloadNotesTable];
                    
                    //Increament counter
                    notebookCountForLoadedNotes++;
                    
                    [self reloadTableWhenAllNotesReceived];

				}
                 
                failure:^(NSError *error)
                {
					DebugLog(@" findNotesWithFilter error %@", error);
                    
                    //Increament counter
                    notebookCountForLoadedNotes++;
                    
                    isError = YES;
                    
                    [self reloadTableWhenAllNotesReceived];
                    
//                    [Utility hideCoverScreen];
//					loadingLbl.hidden = YES;
//					DebugLog(@" findNotesWithFilter error %@", error);
//					[Utility showExceptionAlert:error.description];
				}];
                
			    }
		}
		@catch (EDAMSystemException *exception) {
			[Utility showExceptionAlert:exception.description];
		}
		@catch (EDAMNotFoundException *exception) {
			[Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
		}
		@catch (id exception) {
			DebugLog(@"Recvd Exception");
			[Utility showExceptionAlert:ERROR_LISTING_NOTE_MSG];
		}
		
	}
	else
    {		
		//Hide progress indicator
        [Utility hideCoverScreen];
		
        //[self hideDoneToastMsg:nil];
		
        [Utility showAlert:note_please_enter_text_for_search_message];
		
        [self reloadNotesTable];
		
	}
	
	
}
#pragma mark -
#pragma mark UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
	DebugLog(@"searchBarShouldBeginEditing");
	
    notesTbl.dataSource=nil;
	[notesTbl reloadData];
	
//	[[NSNotificationCenter defaultCenter] addObserver:self
//									 selector:@selector (keyboardDidShow:)
//										name: UIKeyboardDidShowNotification object:nil];
//	
//	[[NSNotificationCenter defaultCenter] addObserver:self
//									 selector:@selector (keyboardDidHide:)
//										name: UIKeyboardDidHideNotification object:nil];
	
	toolbar.hidden=YES;
    
    //Animates search bar
    [UIView beginAnimations:@"SearchBarAnimation" context:nil];
    [UIView setAnimationDuration:0.2f];
	searchBar.frame = CGRectMake(toolbar.frame.origin.x, toolbar.frame.origin.y, self.view.frame.size.width, toolbar.frame.size.height);

    if(isSearchModeEnabled == NO)
    {
        notesTbl.frame = CGRectMake(0,searchBar.frame.size.height, self.view.frame.size.width, notesTbl.frame.size.height+searchBar.frame.size.height);
    }
        
    [UIView commitAnimations];
    
    //Shows cancel button
    [searchBar setShowsCancelButton:YES animated:YES];
    
    //Shift bottom bar upward
    //bottom_bar.frame=CGRectMake(0,notesTbl.frame.origin.y+notesTbl.frame.size.height, self.view.frame.size.width,bottom_bar.frame.size.height);
    
    isSearchModeEnabled = YES;

}


//-(void) keyboardDidShow: (NSNotification *)notif
//{
    // If keyboard is visible, return
//	if (keyboardVisible)
//    {
//        return;
//    }
//    
//    // Get the size of the keyboard.
//	notesTbl.dataSource=nil;
//	[notesTbl reloadData];
	//NSDictionary* info = [notif userInfo];
	//NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
	//CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Save the current location so we can restore
    // when keyboard is dismissed
//    if(i==0)
//    {
//		tempHeight = notesTbl.frame.size.height;
//	}
//	else
//    {
//		tempHeight = notesTbl.frame.size.height-searchBar.frame.size.height;
//	}
//    
//	if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//		if(i==0)
//        {
//			notesTbl.frame = CGRectMake(0,searchBar.frame.size.height, self.view.frame.size.width, notesTbl.frame.size.height+searchBar.frame.size.height);
//		}
//		else
//        {
//			notesTbl.frame = CGRectMake(0,searchBar.frame.size.height, self.view.frame.size.width, notesTbl.frame.size.height);
//		}
//	}
//	else
//    {
//		if(i==0)
//        {
//			notesTbl.frame = CGRectMake(0,searchBar.frame.size.height, notesTbl.frame.size.width, notesTbl.frame.size.height+searchBar.frame.size.height);
//		}
//		else
//        {
//			notesTbl.frame = CGRectMake(0,searchBar.frame.size.height, notesTbl.frame.size.width, notesTbl.frame.size.height);
//		}
//	}
	
    //bottom_bar.frame=CGRectMake(0,notesTbl.frame.origin.y+notesTbl.frame.size.height, self.view.frame.size.width,bottom_bar.frame.size.height);
	
//    keyboardVisible = YES;
	
//}

//-(void) keyboardDidHide: (NSNotification *)notif
//{
//    for (id subview in [searchBar subviews]) {
//		if ([subview isKindOfClass:[UIButton class]]) {
//			[subview setEnabled:YES];
//            //[subview addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
//		}
//	}

    
//    // Is the keyboard already shown
//	if (!keyboardVisible)
//	{
//		return;
//	}
//	
//	if(flag2!=1)
//    {
//		//i=1;
//        
//        //notesTbl.frame = CGRectMake(0, toolbar.frame.size.height + searchBar.frame.size.height, self.view.frame.size.width, tempHeight - toolbar.frame.size.height + searchBar.frame.size.height);
//        
//	}
//	else
//    {
//		flag2 = 0;
//	}
    
    
//    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
//    {
//        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//        {
//            notesTbl.frame = CGRectMake(0, 85, self.view.frame.size.width, 575);
//        }
//        else
//        {
//            notesTbl.frame = CGRectMake(0, 85, self.view.frame.size.width, 831);
//        }
//	}
//	else
//    {
//		if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//        {
//			notesTbl.frame = CGRectMake(0, 85, self.view.frame.size.width, 139);
//        }
//		else
//        {
//			notesTbl.frame = CGRectMake(0, 85, self.view.frame.size.width, 287);
//		}
//	}
	
	//bottom_bar.frame=CGRectMake(0,orgBarOriginY, self.view.frame.size.width,bottom_bar.frame.size.height);
//	keyboardVisible = NO;
//}



-(void)makeSearchBarResignFirstResponder
{
    //Hide keyboard
    [searchBar resignFirstResponder];
    
    //Enable cancel button
    for (UIView *view in searchBar.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            [(UIButton *)view setEnabled:YES];
        }
    }
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar1
{	
	[searchBar resignFirstResponder];
    
    //Hides cancel button
    [searchBar setShowsCancelButton:NO animated:YES];
    
	searchBar.text=@"";
    
    //Make the table empty
    notesTbl.dataSource=nil;
	[notesTbl reloadData];
    
	[searchResults removeAllObjects];
	[self fetchNoteBasedOnSelectedSegement];
    
    //Animates search bar
    [UIView beginAnimations:@"SearchBarAnimation" context:nil];
    [UIView setAnimationDuration:0.2f];
	searchBar.frame = CGRectMake(searchbarFrame.origin.x, toolbar.frame.size.height, self.view.frame.size.width, searchbarFrame.size.height);
    notesTbl.frame = CGRectMake(0, toolbar.frame.size.height + searchbarFrame.size.height, self.view.frame.size.width, notesTbl.frame.size.height - toolbar.frame.size.height);
	[UIView commitAnimations];
    
	
	isSearchModeEnabled = NO;
    
	flag2=1;
	toolbar.hidden = NO;
	notesTbl.dataSource = self;
    
    //Shift bottom bar downward
    //bottom_bar.frame=CGRectMake(0,orgBarOriginY, self.view.frame.size.width,bottom_bar.frame.size.height);
}


//- (void) searchBarTextDidEndEditing:(UISearchBar *)theSearchBar
//{
//	[self makeSearchBarResignFirstResponder];
//    
//    
//    //Shift bottom bar downward
//    //bottom_bar.frame=CGRectMake(0,orgBarOriginY, self.view.frame.size.width,bottom_bar.frame.size.height);
//}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBarContent
{
	//Show progress indicator
    [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
    
	//[self showLoadingLblWithText:LOADING_MSG];
	
    [listOfNotes removeAllObjects];
    
	
    [self makeSearchBarResignFirstResponder];     //Instead of [searchBar resignFirstResponder];
	
    if(searchBarContent.text.length == 0)
    {
		[Utility showAlert:note_please_enter_text_for_search_message];
		[Utility hideCoverScreen];
//		[self hideDoneToastMsg:loadingLbl];
	}
	else
    {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
			[self fetchNoteBasedOnSelectedSegement];
		});
	}
    
    //Shift bottom bar downward
    //bottom_bar.frame=CGRectMake(0,orgBarOriginY, self.view.frame.size.width,bottom_bar.frame.size.height);
}


-(IBAction)addNote:(id)sender
{
    if([Utility checkNetwork])
    {
        AddNoteViewController *addNoteVCntrl = [[AddNoteViewController alloc]init];
        addNoteVCntrl.delegate =self;
        UINavigationController *addNoteNavCntrl = [[UINavigationController alloc] initWithRootViewController:addNoteVCntrl];
        addNoteNavCntrl.navigationBar.barStyle = UIBarStyleBlackOpaque;
            //[addNoteNavCntrl.navigationBar setBackgroundImage:[UIImage imageNamed:@"blue_bcg_iPhone.png"]];
        if ([addNoteNavCntrl.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
        {
            [addNoteNavCntrl.navigationBar setBackgroundImage:[UIImage imageNamed:@"Toolbar_768x44.png"] forBarMetrics:UIBarMetricsDefault];
            addNoteNavCntrl.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
        }
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self dissmissPopover];
            UIPopoverController *popoverSettings = [[UIPopoverController alloc] initWithContentViewController:addNoteNavCntrl];
            addNoteVCntrl.contentSizeForViewInPopover =CGSizeMake(320, 400);
            popoverController = popoverSettings;
            [popoverSettings presentPopoverFromBarButtonItem:addNoteBtn
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
            
        }
        else
        {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(dismissModalView)];
            addNoteVCntrl.navigationItem.leftBarButtonItem = cancelButton;
            [self.navigationController presentModalViewController:addNoteNavCntrl animated:YES];
            [cancelButton release];
        }
    }
    else
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}



-(void)clearDetailView
{
    [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
    
    self.detailViewController.title = nil;
    [self.detailViewController setReadProp:nil];
    [self.detailViewController setGuid:nil];
    
    //Show selected note's content
    [self.detailViewController showSelectedNoteContent];
}



-(void)dismissModalView
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)dissmissPopover
{
	if(popoverController!=nil)
		[popoverController dismissPopoverAnimated:YES];
}

- (void)evernoteCreatedSuccessfullyListener
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		[self dissmissPopover];
        [self fetchNoteBasedOnSelectedSegement];
    }
	else
    {
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
    
	//[self fetchNoteBasedOnSelectedSegement];
}

- (void)evernoteCreationFailedListener
{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		[self dissmissPopover];
	else {
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}
/************************************************************
 *
 *  Function opening the next view
 *
 ************************************************************/
#pragma mark -
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && (searchOptionsChoiceCntrl.selectedSegmentIndex == 0 || isSearchModeEnabled)))
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
	
    if(![Utility checkNetwork])
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
        return;
    }
    
	if(searchOptionsChoiceCntrl.selectedSegmentIndex==1)
    {
		if(searchBar.text.length != 0)
        {
			NSString* guid = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
			NSString* readProp = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:READABLE];
            NSString * title = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                NoteDetailViewController* noteDetailController= [[NoteDetailViewController alloc] init];
                
                noteDetailController.title = title;
                [noteDetailController setReadProp:readProp];
                [noteDetailController setGuid:guid];
                
                flag1 =1;
                [self.navigationController pushViewController:noteDetailController animated:YES];
            }
            else
            {
                [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
                
                self.detailViewController.title = title;
                [self.detailViewController setReadProp:readProp];
                [self.detailViewController setGuid:guid];
                
                //Show selected note's content
                [self.detailViewController showSelectedNoteContent];
            }
		}
		else
        {
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
			NSString *cellText = selectedCell.textLabel.text;
			NotesViewController *notesViewController = [[[NotesViewController alloc]init]autorelease];
			notesViewController.title = cellText;
			notesViewController.detailViewController = self.detailViewController;
			notesViewController.selectedSegment = 1;
			[self.navigationController pushViewController:notesViewController animated:YES];
		}
	}
	
	else if(searchOptionsChoiceCntrl.selectedSegmentIndex==2)
    {
		if(searchBar.text.length != 0)
        {
			NSString* guid = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
			NSString* readProp = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:READABLE];
			NSString * title = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
			   
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                NoteDetailViewController* noteViewController= [[NoteDetailViewController alloc] init];
                
                noteViewController.title = title;
                [noteViewController setReadProp:readProp];
                [noteViewController setGuid:guid];
                
                flag1 =1;
                [self.navigationController pushViewController:noteViewController animated:YES];
            }
            else
            {
                [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
                
                self.detailViewController.title = title;
                [self.detailViewController setReadProp:readProp];
                [self.detailViewController setGuid:guid];
                
                //Show selected note's content
                [self.detailViewController showSelectedNoteContent];

            }
		}
		else
        {
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
			NSString *cellText = selectedCell.textLabel.text;
			NotesViewController *notesViewController = [[[NotesViewController alloc]init]autorelease];
			notesViewController.detailViewController = self.detailViewController;
			notesViewController.title = cellText;
			notesViewController.selectedSegment = 2;
			[self.navigationController pushViewController:notesViewController animated:YES];
		}
	}
	else
    {	
		if(searchBar.text.length != 0){
			
			NSString * guid = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
			NSString *readProp = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:READABLE];
			NSString * title = (NSString *)[ [searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
			
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                NoteDetailViewController* noteDetailViewController = [[NoteDetailViewController alloc] init];
                
                noteDetailViewController.title = title;
                [noteDetailViewController setReadProp:readProp];
                [noteDetailViewController setGuid:guid];
                
                flag1 =1;
                [self.navigationController pushViewController:noteDetailViewController animated:YES];
            }
            else
            {
                [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];

                self.detailViewController.title = title;
                [self.detailViewController setReadProp:readProp];
                [self.detailViewController setGuid:guid];
                
                //Show selected note's content
                [self.detailViewController showSelectedNoteContent];

            }
		}
		else
        {			
			NSString * guid = (NSString *)[ [listOfNotes objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
			NSString *readProp = (NSString *)[ [listOfNotes objectAtIndex:indexPath.row]valueForKey:READABLE];
			NSString * title = (NSString *)[ [listOfNotes objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                NoteDetailViewController* noteDetailViewController = [[NoteDetailViewController alloc] init];
                noteDetailViewController.title = title;
                [noteDetailViewController setReadProp:readProp];
                [noteDetailViewController setGuid:guid];
                [self.navigationController pushViewController:noteDetailViewController animated:YES];
            }
            else
            {
                [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
 
                self.detailViewController.title = title;
                [self.detailViewController setReadProp:readProp];
                [self.detailViewController setGuid:guid];
                
                //Show selected note's content
                [self.detailViewController showSelectedNoteContent];

            }
			
		}
		
    }
}

/************************************************************
 *
 *  Function deleting a note
 *
 ************************************************************/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(searchOptionsChoiceCntrl.selectedSegmentIndex != 0 || isSearchModeEnabled)
    {
        return NO;
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * guid = (NSString *)[[listOfNotes objectAtIndex:[indexPath row]]valueForKey:NOTE_GUID_KEY];
	EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
		// As an example, we are going to show the first element if it is an image
	[noteStore deleteNoteWithGuid:guid success:^(int32_t success)
	{
        //Delete the object from array listOfNotes
        [listOfNotes removeObjectAtIndex:[indexPath row]];
        
        //Delete the row with animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && [guid isEqualToString:self.detailViewController.guid])
        {
            //Clear the detail view
            [self clearDetailView];
        }
        
        [Utility hideCoverScreen];
        
        [Utility showCoverScreenWithText:NOTE_DELETE_SUCCESS_MSG andType:kProcessDoneCoverScreen];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hideCoverScreen) userInfo:nil repeats:NO];
        
        //[Utility showAlert:NOTE_DELETE_SUCCESS_MSG];
        
        DebugLog(@"deleteNoteWithGuid %d ::::",success);
        
        
//        [self fetchNoteBasedOnSelectedSegement];
        

        //	loadingLbl.hidden = YES;
	
    }failure:^(NSError *error)
    {
        DebugLog(@"note::::::::error %@", error);
        
  	    //[Utility hideCoverScreen];

        [Utility showCoverScreenWithText:NOTE_DELETE_FAILED_MSG andType:kWarningCoverScreen];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hideCoverScreen) userInfo:nil repeats:NO];
        
		//[Utility showAlert:NOTE_DELETE_FAILED_MSG];

//		 loadingLbl.hidden = YES;
	}];
    
    
    //Show progressIndicator
    [Utility showCoverScreenWithText:NOTE_DELETING_MSG andType:kInProcessCoverScreen];
	
		// Removing the note from our cache
	//[listOfNotes removeObjectAtIndex:[indexPath row]];
	//[self fetchNoteBasedOnSelectedSegement];
	
}


-(void)hideCoverScreen
{
    [Utility hideCoverScreen];
}


/************************************************************
 *
 *  Functions configuring the listView
 *
 ************************************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(searchOptionsChoiceCntrl.selectedSegmentIndex == 0)
    {
		if(searchBar.text.length != 0){
			return [searchResults count];
		}
		else{
			return [listOfNotes count];
		}
		
	} else if (searchOptionsChoiceCntrl.selectedSegmentIndex == 1)
    {
		if(searchBar.text.length != 0){
			return [searchResults count];
		}
		else{
			return [listOfNotebooks count];
		}
		
	}
	else if (searchOptionsChoiceCntrl.selectedSegmentIndex == 2) {
		if(searchBar.text.length != 0){
			return [searchResults count];
		}
		else{
			
			return [listOfTags count];
		}
	}
	else{
		return [listOfNotes count];
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
		//[self initConextAndFetchController];
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
	}
	NSString *cellValue = nil;
		//
	if(searchOptionsChoiceCntrl.selectedSegmentIndex == 0) {
		if(![searchBar.text isEqualToString:@""] && searchResults.count !=0 )
        {
			
			if(indexPath.row < searchResults.count){
				cellValue = [[searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
			}
		}
		else
        {
			cellValue = [[listOfNotes objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
		}
	}
	else if (searchOptionsChoiceCntrl.selectedSegmentIndex == 1) {
		
		
		if((![searchBar.text isEqualToString:@""] && searchResults.count !=0 )){
			if(indexPath.row < searchResults.count){
				cellValue = [[searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
			}
			
		}
		else {
			
			cellValue =[[listOfNotebooks objectAtIndex:indexPath.row]valueForKey:NOTEBOOK_KEY];
			
		}
	}
	else if(searchOptionsChoiceCntrl.selectedSegmentIndex == 2) {
		if(![searchBar.text isEqualToString:@""] && searchResults.count !=0 ){
			
			if(indexPath.row < searchResults.count){
				cellValue = [[searchResults objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
			}
		}
		else{
			cellValue = [[listOfTags objectAtIndex:indexPath.row]valueForKey:TAG_KEY];
		}
	}
	
	
	cell.textLabel.text = (NSString*)cellValue;
	cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
	cell.textLabel.textColor = [UIColor blackColor];

    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) &&  searchOptionsChoiceCntrl.selectedSegmentIndex == 0)
    {
        cell.accessoryView = nil;
    }
    else
    {
        UIImageView *accIMGView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        accIMGView.image =[UIImage imageNamed:@"Blue_arrow_30x30.png"];
        cell.accessoryView = accIMGView;
        [accIMGView release];
    }
    
//	cell.accessoryView.backgroundColor  =[UIColor clearColor];
//	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	return cell;
}


#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


//dealloc method declared in RootViewController.m
- (void)dealloc
{	
	[listOfNotes release];
	[listOfNotebooks release];
	[listOfTags release];
	[searchResults release];
    [_detailViewController release];
    
    
	[super dealloc];
}

@end
