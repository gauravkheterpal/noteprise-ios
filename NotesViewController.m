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
      [Utility showCoverScreen];
//     loadingLbl = [[UILabel alloc]initWithFrame:CGRectMake(57, 212, 90, 38)];
//     loadingLbl.text = @"Loading";
//     dialog_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 163, 220, 91)];
//     NSLog(@"Loading label text:%@",loadingLbl.text);
//     dialog_imgView.image=[UIImage imageNamed:@"Loader.png"];
//     CGRect bounds = CGRectMake(157, 212, 207, 38);
//     
//          // Create a view and add it to the window.
//     UIView* view = [[UIView alloc] initWithFrame: bounds];
//          // [view setBackgroundColor: [UIColor yellowColor]];
//          //[view addSubview: loadingLbl];
//          // [dialog_imgView setBackgroundColor:[UIColor purpleColor]];
//     [dialog_imgView addSubview:loadingLbl];
//     [view addSubview:dialog_imgView];
//     [self.view addSubview: view];
     
     notes = [[NSMutableArray alloc]init];
     NSLog(@"Loading Label Frame: origin-x=%f...origin-y=%f....width=%f....height=%f...",loadingLbl.frame.origin.x,loadingLbl.frame.origin.y,loadingLbl.frame.size.width,loadingLbl.frame.size.height);
          // Uncomment the following line to preserve selection between presentations.
          // self.clearsSelectionOnViewWillAppear = NO;
     
          // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
          // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated{
     
          // loadingLbl.frame =  CGRectMake(57, 212, 207, 38);
          //dialog_imgView.frame = CGRectMake(50, 163, 220, 91);
     loadingLbl.hidden=NO;
     dialog_imgView.hidden=NO;
     if(!loadingLbl.hidden){
          NSLog(@"Loading label is on screen with text:%@",loadingLbl.text);
     }
     [self fetchDataFromEvernote];
}

- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
          // Dispose of any resources that can be recreated.
}

-(void) fetchDataFromEvernote {
     
     @try {
          EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
          
          if(selectedSegment == 1){
          loadingLbl.hidden=NO;
               dialog_imgView.hidden=NO;
          [noteStore listNotebooksWithSuccess:^(NSArray *noteBooksArr) {
           DebugLog(@"notebooks fetched: %@", noteBooksArr);
           noteBooks = [noteBooksArr retain];
           [self reloadNotebookNotes:noteBooks];
           DebugLog(@"notebooks: %@", noteBooks);
           }
           failure:^(NSError *error) {
           DebugLog(@"error %@", error);
           }];
     }
          else{

          [noteStore listTagsWithSuccess: ^(NSArray *tagsArr) {
               DebugLog(@"tagsArr fetched: %@", tagsArr);
               tags = [tagsArr retain];
               [self reloadTagNotes:tags];
               DebugLog(@"tagsArr: %@", tagsArr); }
                                 failure:^(NSError *error) {DebugLog(@"error %@", error);}
           ];
          }
          
     }
     @catch (EDAMUserException *exception) {
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



-(void)reloadNotebookNotes:(NSArray*)notebooks {
     
     @try {
          if(self.selectedSegment == 1)
              {
               loadingLbl.hidden=NO;
               dialog_imgView.hidden=NO;
                    // __block NSMutableArray *tempArray = [noteBooks retain];
               [notes removeAllObjects];
               EDAMNotebook *notebook,*notebook1;
               for (int i = 0; i < [notebooks count]; i++)
                   {
                    notebook = (EDAMNotebook*)[notebooks objectAtIndex:i];
                    NSLog(@".............current notebook.......%@.......of index .....%d",notebook,i);
                    if ([[notebook name] isEqualToString:[self title]]) {
                         notebook1= notebook;
                         NSLog(@".............notebook selected.......%@",notebook1);
                         break;
                    }
                   }
               
               NSLog(@".............original notebook.......%@",notebooks);
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
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                    notes = [[notes sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
                    NSLog(@"...........array...........%@",notes);
                         // [self.tableView reloadData];
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
                         // NSLog(@".............current notebook.......%@.......of index .....%d",notebook,i);
                    if ([[tag name] isEqualToString:[self title]]) {
                         tag1= tag;
                              //   NSLog(@".............notebook selected.......%@",notebook1);
                         break;
                    }
                   }
               
                    // NSLog(@".............original notebook.......%@",notebooks);
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
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTE_KEY  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                    notes = [[notes sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
                    NSLog(@"...........array...........%@",notes);
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


-(void)reloadNotesTable {
     [Utility hideCoverScreen];
          //[searchBar resignFirstResponder];
     self.tableView.delegate =self;
     self.tableView.dataSource =self;
     [self hideDoneToastMsg:nil];
     loadingLbl.hidden = YES;
     [self.tableView reloadData];
}

-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
     loadingLbl.hidden = YES;
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
     NSLog(@"Notes..................in NotesViewController...........%@",notes);
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
     cell.backgroundColor = [UIColor clearColor];
     cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"White_bordered_background.png"]];
     
     cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
     UIImageView *accIMGView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
     accIMGView.image =[UIImage imageNamed:@"Blue_arrow_30x30.png"];
     cell.accessoryView = accIMGView;
     cell.accessoryView.backgroundColor  =[UIColor clearColor];
     cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
     return cell;
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NoteDetailViewController* noteViewController= [[NoteDetailViewController alloc] init];
     
     NSString* guid = (NSString *)[ [notes objectAtIndex:indexPath.row]valueForKey:NOTE_GUID_KEY];
     NSString* readProp = (NSString *)[ [notes objectAtIndex:indexPath.row]valueForKey:READABLE];
     noteViewController.title = (NSString *)[ [notes objectAtIndex:indexPath.row]valueForKey:NOTE_KEY];
     [noteViewController setReadProp:readProp];
     [noteViewController setGuid:guid];
     [self.navigationController pushViewController:noteViewController animated:YES];
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
- (void)dealloc {
     
     [notes release];
     [super dealloc];
}


@end
