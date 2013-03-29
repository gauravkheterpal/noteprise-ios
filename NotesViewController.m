     //
     //  NotesViewController.m
     //  Noteprise
     //
     //  Created by Meenal Jain on 1/5/13.
     //
     //

#import "NotesViewController.h"
#import "Keys.h"
#import "EvernoteSDK.h"
#import "SettingsViewController.h"
#import "NotesListViewController.h"
#import "NoteDetailViewController.h"


@interface NotesViewController ()

@end

@implementation NotesViewController
@synthesize notes,selectedSegment,noteBooks;


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
    
    //If device is iPad then add a back button
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self addbackButton];
    }
    
	notes = [[NSMutableArray alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self fetchDataFromEvernote];
    }
}


-(void)addbackButton
{
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    [backBarButton release];
}


-(void)backButtonPressed
{
    self.detailViewController.notesViewController = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewDidAppear:(BOOL)animated
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self fetchDataFromEvernote];
    }
}


- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
}


-(void) fetchDataFromEvernote
{
    [Utility showCoverScreenWithText:@"Loading..." andType:kInProcessCoverScreen];
    
    @try
    {
         EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
          
         if(selectedSegment == 1)
         {
		     [noteStore listNotebooksWithSuccess:^(NSArray *noteBooksArr)
             {
                 DebugLog(@"notebooks fetched: %@", noteBooksArr);
                 noteBooks = [noteBooksArr retain];
                 [self reloadNotebookNotes:noteBooks];
                 DebugLog(@"notebooks: %@", noteBooks);
             }
			
             failure:^(NSError *error)
             {
			     DebugLog(@"error %@", error);
                 
                 //Hide progress indicator
                 [Utility hideCoverScreen];
                 
                 
                 [self showError:error];
                 
             }];
		 }
         else
         {
		     [noteStore listTagsWithSuccess: ^(NSArray *tagsArr)
             {
                 DebugLog(@"tagsArr fetched: %@", tagsArr);
                 tags = [tagsArr retain];
                 [self reloadTagNotes:tags];
                 DebugLog(@"tagsArr: %@", tagsArr);
             }
			 failure:^(NSError *error)
             {
                 DebugLog(@"error %@", error);
                 
                 //Hide progress indicator
                 [Utility hideCoverScreen];
                 
                 [self showError:error];
             }
              
			 ];
         }
     }
    
     @catch (EDAMUserException *exception)
    {
          DebugLog(@"Recvd Exception:%d",exception.errorCode );
          [Utility showAlert:EVERNOTE_LOGIN_FAILED_MSG];
     }
     @catch (EDAMSystemException *exception) {
          [Utility showExceptionAlert:exception.description];
     }
     @catch (EDAMNotFoundException *exception) {
          [Utility showExceptionAlert:SOME_ERROR_OCCURED_MESSAGE];
     }
     
     
     
}


-(void)showError:(NSError *)error
{   
    if(error.code == -3000)
    {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
    else
    {
        [Utility showAlert:@"An error occured."];
        
    }    
}





-(void)reloadNotebookNotes:(NSArray*)notebooks {
    
     @try {
          if(self.selectedSegment == 1)
              {
               
                    // __block NSMutableArray *tempArray = [noteBooks retain];
               [notes removeAllObjects];
               EDAMNotebook *notebook,*notebook1;
               for (int i = 0; i < [notebooks count]; i++)
                   {
                    notebook = (EDAMNotebook*)[notebooks objectAtIndex:i];
                    if ([[notebook name] isEqualToString:[self title]]) {
                         notebook1= notebook;
                         break;
                    }
                   }
               
                    // Creating & configuring filter to load specific notebook
               EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
               [filter setNotebookGuid:[notebook1 guid]];
               [filter setOrder:NoteSortOrder_TITLE];
               [filter setAscending:YES];
               
                    // Searching on the Evernote API
               EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
               [noteStore findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *noteList){
                    for (EDAMNote *noteRead in noteList.notes) {
                              // Populating the arrays
                         NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
                         
                         [noteListDict setValue:[noteRead title] forKey:NOTE_KEY];
                         [noteListDict setValue:[noteRead guid] forKey:NOTE_GUID_KEY];
                         NSString *readProp = noteRead.attributes.contentClass?@"Yes":@"No";
                         [noteListDict setValue:readProp forKey:READABLE];
                         [notes addObject:noteListDict];
                         
                    }
                   
                   
                   if([notes count] == 0)
                   {
                       [Utility showAlert:NO_NOTE_FOUND_WITH_THIS_NOTEBOOK];
                   }
                   else
                   {
                       NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                       notes = [[notes sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
                   }
                   [self reloadNotesTable];
               }
                                      failure:^(NSError *error) {
                                           DebugLog(@" findNotesWithFilter error %@", error);
                                           [Utility showExceptionAlert:error.description];
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

-(void)reloadTagNotes:(NSArray*)tagsArray {
     
     @try {
          if(self.selectedSegment == 2)
              {
                    // __block NSMutableArray *tempArray = [noteBooks retain];
               [notes removeAllObjects];
               EDAMTag *tag,*tag1;
               for (int i = 0; i < [tagsArray count]; i++)
                   {
                    tag = (EDAMTag*)[tagsArray objectAtIndex:i];
                    if ([[tag name] isEqualToString:[self title]]) {
                         tag1= tag;
                         break;
                    }
                   }
               
                    // Creating & configuring filter to load specific notebook
               EDAMNoteFilter * filter = [[EDAMNoteFilter alloc] init];
               [filter setTagGuids:[[NSArray alloc]initWithObjects:[tag1 guid],[tag1 parentGuid], nil]];
               [filter setOrder:NoteSortOrder_TITLE];
               [filter setAscending:YES];
               
                    // Searching on the Evernote API
               EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
               [noteStore findNotesWithFilter:filter offset:0 maxNotes:100 success:^(EDAMNoteList *noteList){
                    for (EDAMNote *noteRead in noteList.notes) {
                              // Populating the arrays
                         NSMutableDictionary *noteListDict = [[NSMutableDictionary alloc]init];
                         
                         [noteListDict setValue:[noteRead title] forKey:NOTE_KEY];
                         [noteListDict setValue:[noteRead guid] forKey:NOTE_GUID_KEY];
                         NSString *readProp = noteRead.attributes.contentClass?@"Yes":@"No";
                         [noteListDict setValue:readProp forKey:READABLE];
                         [notes addObject:noteListDict];
                         
                    }
				
                if([notes count] == 0)
                {
					[Utility showAlert:NO_NOTE_FOUND_WITH_THIS_TAG];
				}
				else
                {
					NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
					notes = [[notes sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
				}
				[self reloadNotesTable];
               }
                                      failure:^(NSError *error) {
                                           DebugLog(@" findNotesWithFilter error %@", error);
                                           [Utility showExceptionAlert:error.description];
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


-(void)reloadNotesTable
{
    //Hide progress indicator
    [Utility hideCoverScreen];
    
    self.tableView.delegate =self;
    self.tableView.dataSource =self;
    [self.tableView reloadData];
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
     return [notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
     }
     NSString *cellValue = [[notes objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
     
     cell.textLabel.text = (NSString*)cellValue;
     cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
     cell.textLabel.textColor = [UIColor blackColor];
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        UIImageView *accIMGView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        accIMGView.image =[UIImage imageNamed:@"Blue_arrow_30x30.png"];
        cell.accessoryView = accIMGView;
    }

//	cell.accessoryView.backgroundColor  =[UIColor clearColor];
//    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * guid = (NSString *)[ [notes objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
    NSString * readProp = (NSString *)[ [notes objectAtIndex:indexPath.row]valueForKey:READABLE];
    NSString * title = (NSString *)[[notes objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];

    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        NoteDetailViewController * noteDetailController= [[NoteDetailViewController alloc] init];
        noteDetailController.title = title;
        [noteDetailController setReadProp:readProp];
        [noteDetailController setGuid:guid];
        [self.navigationController pushViewController:noteDetailController animated:YES];
    }
    else
    {
        [self.detailViewController.navigationController popToRootViewControllerAnimated:YES];
        
        self.detailViewController.title = title;
        [self.detailViewController setReadProp:readProp];
        [self.detailViewController setGuid:guid];
        self.detailViewController.notesViewController = self;
        
        //Show selected note's content
        [self.detailViewController showSelectedNoteContent];
    }
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
 else if (editingStyle ==UITableViewCellEditingStyleInsert) {
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


- (void)dealloc
{
    [notes release];
    [_detailViewController release];
    
    [super dealloc];
}


@end