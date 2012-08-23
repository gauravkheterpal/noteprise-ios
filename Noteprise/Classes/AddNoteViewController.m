//
//  FirstViewController.m
//  client
//

#import <CommonCrypto/CommonDigest.h> 
#import "AddNoteViewController.h"

#import "EvernoteSDK.h"
#import "Utility.h"
#import "NSString+HTML.h"
//#import "NSDataMD5Additions.h"

@implementation AddNoteViewController


@synthesize titleNote, sendNote, imageView,delegate;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    self.title = @"Add Note";
    selectedNotebookIndex = 0;
    bodyTxtView.layer.cornerRadius = 8;
	bodyTxtView.layer.borderWidth = 2;
	bodyTxtView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Create" 
                                                                             style:UIBarButtonItemStyleBordered 
                                                                            target:self 
                                                                            action:@selector(createNoteEvernote:)];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480);

    
   // [bodyTxtView loadHTMLString:@"<note><to>Tove</to><br \><from>Jani</from><heading>Reminder</heading><body>Don't forget me this weekend!</body></note>" baseURL:nil];
    
    
    //[sendNote addTarget:self action:@selector(sendNoteEvernote:) forControlEvents:UIControlEventTouchDown];
    
    
    // We are going to initialize the values in the picker
    //Initialize the array.
    listOfItems = [[NSMutableArray alloc] init];
    indexArray = [[NSMutableArray alloc] init];
    //[bodyTxtView loadHTMLString:@"" baseURL:nil];
    

    
    [self setContentEditable:YES];
    [self setWebViewKeyPressDetectionEnabled:YES];
    [self setWebViewTapDetectionEnabled:YES];    
    [self increaseZoomFactorRange];
    
    
    @try {
        
        // Loading all the notebooks linked to the account
        EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
        [noteStore listNotebooksWithSuccess:^(NSArray *noteBooksArr) {
            DebugLog(@"notebooks fetched: %@", noteBooksArr);
            // Populating the array
            NSArray *noteBooks = [noteBooksArr retain];
            DebugLog(@"notebooks: %@", noteBooks);
            for (int i = 0; i < [noteBooks count]; i++) {
                
                EDAMNotebook* notebook = (EDAMNotebook*)[noteBooks objectAtIndex:i];
                [listOfItems addObject:[notebook name]];
                [indexArray addObject:[notebook guid]];
                
            }
        }
        failure:^(NSError *error) {
            DebugLog(@"error %@", error);                                            
        }];
       // NSArray *noteBooks = (NSArray *)[[Evernote sharedInstance] listNotebooks];
        
        
        
    }
    @catch (EDAMUserException *exception) {
        DebugLog(@"Recvd Exception:%d",exception.errorCode );
        [Utility showAlert:@"Login Failed. Please check your username and password."];
    }
    @catch (EDAMSystemException *exception) {
        [Utility showExceptionAlert:exception.description];
    }   
    @catch (EDAMNotFoundException *exception) {
        [Utility showExceptionAlert:@"Reason Unknown"];
    }
    
    [super viewDidLoad];
}




/************************************************************
 *
 *  Function that sends the note to Evernote
 *  Started by the submit button
 *
 ************************************************************/

-(IBAction)createNoteEvernote:(id)sender{
    NSMutableString *bodyTxt =(NSMutableString *) [bodyTxtView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    DebugLog(@"outerhtml:%@",bodyTxt);
    if([titleNote.text isEqualToString:@""] || [bodyTxt isEqualToString:@""]){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Missing Field" message:@"Please Enter Note Title & Note Body text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    // Closing controls
    [titleNote resignFirstResponder];
    [bodyTxtView resignFirstResponder];
    
    //get current user location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    BOOL locationAllowed = [CLLocationManager locationServicesEnabled];
    if (locationAllowed==NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To re-enable & attach location with Note, please go to Settings and turn on Location Service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [self createEvernoteWithUserLocation:0.0 longitude:0.0];
    } else {
        [locationManager startUpdatingLocation];
        dialog_imgView.hidden = NO;
        loadingLbl.text = @"Attaching user location...";
        //[loadingLbl sizeToFit];
        loadingLbl.hidden = NO;
    }
}
-(void)createEvernoteWithUserLocation:(double)latitude longitude:(double)longitude
{
    // Creating the Note Object
    EDAMNote * note = [[[EDAMNote alloc] init]autorelease];
    note.title = titleNote.text;
    EDAMNoteAttributes *att = [[EDAMNoteAttributes alloc]init];
    if(latitude !=0 && longitude != 0) {
        att.latitude = latitude;
        att.longitude = longitude;
        // Setting initial values sent by the user
        
        [note setAttributes:att];
    }
    if([indexArray count] != 0) {
        note.notebookGuid = [indexArray objectAtIndex:selectedNotebookIndex];
        
        NSMutableString *bodyTxt = (NSMutableString *) [bodyTxtView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
       bodyTxt = (NSMutableString *)[bodyTxt stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
             /*NSRange start = [bodyTxt rangeOfString:@"<en-note>"];
            NSRange end = [bodyTxt rangeOfString:@"</en-note>"];
        if(start.location !=NSNotFound){
            bodyTxt = (NSMutableString *)[bodyTxt substringWithRange:NSMakeRange(start.location+start.length, end.location-(start.location+start.length))]; 
        }*/
        
        
        NSString * ENML = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@",bodyTxt];
        
        ENML = [NSString stringWithFormat:@"%@%@", ENML, @"</en-note>"];
        DebugLog(@"ENML:%@", ENML);
        
        // Adding the content to the note
        [Utility showCoverScreen];
        [note setContent:ENML];
        
        [loadingSpinner startAnimating];
        dialog_imgView.hidden = NO;
        
        loadingLbl.text = @"Creating Note...";
        loadingLbl.hidden = NO;
        __block BOOL isErrorCreatingnote = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void) {
            // Saving the note on the Evernote servers
            // Simple error management
            @try {
                EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
                [noteStore createNote:note success:^(EDAMNote *note)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^(void) {
                         DebugLog(@"create note success%@ :::: ",note);
                         if(isErrorCreatingnote == NO) {
                             // Alerting the user that the note was created
                             dialog_imgView.hidden = NO;
                             doneImgView.hidden = NO;
                             [loadingSpinner stopAnimating];
                             loadingLbl.text = @"Note was saved!";
                             DebugLog(@"note desc:lat:%f long:%f",[note attributes].latitude,[note attributes].longitude);
                             DebugLog(@"note desc:%@",[note description]);
                             [Utility hideCoverScreen];
                             [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
                         }
                         [loadingSpinner stopAnimating];
                     });
                 }
                              failure:^(NSError *error) {
                                  dispatch_async(dispatch_get_main_queue(), ^(void) {
                                      DebugLog(@"create note::::::::error %@", error);
                                      [Utility showAlert:error.description];
                                      dialog_imgView.hidden = YES;
                                      loadingLbl.hidden = YES;
                                      [loadingSpinner stopAnimating];
                                      [Utility hideCoverScreen];
                                      isErrorCreatingnote = YES;
                                      [delegate evernoteCreationFailedListener];
                                      return;
                                  });
                                  
                              }];
                //[[Evernote sharedInstance] createNote:note];
            }
            @catch (id  exception) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    NSString * errorMessage = [NSString stringWithFormat:@"Error saving note: error code %i", [exception errorCode]];
                    [Utility showAlert:errorMessage];
                    dialog_imgView.hidden = YES;
                    loadingLbl.hidden = YES;
                    [loadingSpinner stopAnimating];
                    [Utility hideCoverScreen];
                    isErrorCreatingnote = YES;
                    [delegate evernoteCreationFailedListener];
                    return;
                });
            }
        });
    } else {
        [Utility showAlert:@"Please select a notebook"];
    }
    
}
-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    doneImgView.hidden = YES;
    [loadingSpinner stopAnimating];
    [delegate evernoteCreatedSuccessfullyListener];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//Perform an action
	[bodyTxtView resignFirstResponder];
    [titleNote resignFirstResponder];
}


/************************************************************
 *
 *  Functions used by the picker view
 *
 ************************************************************/
-(IBAction)selectNoteBookForiPad:(id)sender{
    UITableViewController* popoverContent = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	popoverContent.tableView=notebooksTbl;
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.PNG"]];
    [tempImageView setFrame:notebooksTbl.frame]; 
    
    notebooksTbl.backgroundView = tempImageView;
    [tempImageView release];

	//resize the popover view shown in the current view to the view's size
	popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 480);
    popController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
	
	//present the popover view non-modal with a
	//refrence to the button pressed within the current view
	[popController presentPopoverFromRect:[sender frame]
											inView:self.view
						  permittedArrowDirections:UIPopoverArrowDirectionAny
										  animated:YES];
	[notebooksTbl reloadData];
}
-(IBAction)selectNoteBook:(id)sender{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self selectNoteBookForiPad:sender];
        return;
    }
    // User requested to see the picker
    [titleNote resignFirstResponder];
    UIPickerView *notebookPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 400)];
    //sortPickerView.tag = SORT_PICKER;
	notebookPicker.showsSelectionIndicator = YES;  
	notebookPicker.dataSource = self;
	notebookPicker.delegate = self;
    
    UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Select Notebook";
    label.textColor = [UIColor blackColor];
    UIBarButtonItem *titleLbl = [[UIBarButtonItem alloc] initWithCustomView:label];
    [barItems addObject:titleLbl];
    [titleLbl release];
    
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
	[flexSpace release];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActionSheet:)];
	[barItems addObject:doneBtn];
	[doneBtn release];
	
    
	[pickerDateToolbar setItems:barItems animated:YES];
    if (sortTypeActionSheet != nil) {
        [sortTypeActionSheet release];
    }
    
    sortTypeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Default Sort" delegate:nil cancelButtonTitle:@"Cancel Button" destructiveButtonTitle:@"Destructive Button" otherButtonTitles:@"Other Button 1", nil];
    
    sortTypeActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sortTypeActionSheet addSubview:pickerDateToolbar];
    [sortTypeActionSheet addSubview:notebookPicker];
    [sortTypeActionSheet showInView:self.view];   
    
    [pickerDateToolbar release];
    [barItems release];

}
-(IBAction)dismissActionSheet:(id)sender {
    [sortTypeActionSheet  dismissWithClickedButtonIndex:0 animated:YES];
    sortTypeActionSheet = nil;
}
/*-(IBAction)doneWithpickerView:(id)sender{
    // When the user is done with the picker
    [notebookPicker removeFromSuperview]; 
    [doneButtonPicker removeFromSuperview];
    
}*/

#pragma mark -
#pragma mark UITableView datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listOfItems count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //[self initConextAndFetchController];
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    cell.textLabel.text = [listOfItems objectAtIndex:indexPath.row];
    
    return cell;
}
#pragma mark -
#pragma mark UITableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedNotebookIndex = indexPath.row;
    [popController dismissPopoverAnimated:YES];
    //[self presentModalViewController:noteViewController animated:true];
}
#pragma mark -
#pragma mark UIPickerView datasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedNotebookIndex = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [listOfItems count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [listOfItems objectAtIndex:row];
}




/************************************************************
 *
 *  Functions used by the image picker
 *
 ************************************************************/

// Open the image picker
-(IBAction)getPhoto:(id)sender{
    
    [titleNote resignFirstResponder];
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	
    
	[self presentModalViewController:picker animated:YES];
    
}

// The user has selected the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    //[doneButtonPicker release];
    [titleNote release];
    [sendNote release];
    //[imageView release];
   // [notebookPicker release];
    [super dealloc];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    DebugLog(@"error desc:%@",[error description]);
    //if ([error code] != kCLErrorLocationUnknown) {
    [manager stopUpdatingLocation];
    manager.delegate = nil;
    loadingLbl.text = @"Failed to retrieve user location!";
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
    [Utility hideCoverScreen];
    [self createEvernoteWithUserLocation:0.0 longitude:0.0];
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    manager.delegate = nil;
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    NSLog(@"lat = %@ , longt = %@",lat,longt);
    // [manager stopUpdatingLocation];
    dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    
    [self createEvernoteWithUserLocation:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
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
    
    NSString *result = [bodyTxtView stringByEvaluatingJavaScriptFromString:js];
    
    NSLog(@"%@",result);
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
    
    NSString *result = [bodyTxtView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"%@",result);
}


- (void)setContentEditable:(BOOL)isEditable {
    NSString *jsEnableEditing = 
    [NSString stringWithFormat:@"document.body.contentEditable=%@;", isEditable ? @"true" : @"false"];
    
    NSString *result = [bodyTxtView stringByEvaluatingJavaScriptFromString:jsEnableEditing];
    
    NSLog(@"editable %@",result);
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
    
    [bodyTxtView stringByEvaluatingJavaScriptFromString:js];
}




- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    DebugLog(@"Url to load = %@",request.URL.absoluteString);
    if ([request.URL.absoluteString isEqualToString:kWebViewDidPressKeyURL]) {
        
        [self setWebViewKeyPressDetectionEnabled:NO];
        return NO;
    } else if ([request.URL.absoluteString isEqualToString:kWebViewDidTapURL]) {
        [self setWebViewKeyPressDetectionEnabled:NO];
        return NO;
    }
    else if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    }
    
    return NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [Utility showAlert:[error localizedDescription]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    /*[self setContentEditable:YES];
    [self setWebViewKeyPressDetectionEnabled:YES];
    [self setWebViewTapDetectionEnabled:YES];    
    [self increaseZoomFactorRange];*/
    
}









@end
