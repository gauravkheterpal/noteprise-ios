     //
     //  NotesViewController.m
     //  Noteprise
     //
     //  Created by Meenal Jain on 1/5/13.
     //
     //

#import "NotesViewController.h"
#import "EvernoteSDK.h"
#import "NotesListViewController.h"
#import "NoteDetailViewController.h"
@interface NotesViewController ()

@end

@implementation NotesViewController
@synthesize notes;
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
     
          //NotesListViewController *notesLists = [NotesListViewController alloc];
     
          // Uncomment the following line to preserve selection between presentations.
          // self.clearsSelectionOnViewWillAppear = NO;
     
          // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
          // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated{
     
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


@end
