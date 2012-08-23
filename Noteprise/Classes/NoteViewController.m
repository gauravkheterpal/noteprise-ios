//
//  NoteViewController.m
//  client
//

#import "NoteViewController.h"
#import "EvernoteSDK.h"
#import "RootViewController.h"
#import "NSString+HTML.h"
#import "ChatterUsersViewController.h"
#import "ChatterGroupVCntrlViewController.h"
@implementation NoteViewController {
}


@synthesize guid, noteNavigation, noteContent,textContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self changeBkgrndImgWithOrientation];
    
    //edit button as right bar button item
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(editPage:)];
    self.navigationItem.rightBarButtonItem = editButton;
    //--------------------------------------------------------------
    
    
    [Utility showCoverScreen];
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = @"Loading...";
    loadingLbl.hidden = NO;
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
                     [Utility hideCoverScreen];
                     [loadingSpinner stopAnimating];
                     dialog_imgView.hidden = YES;
                     loadingLbl.hidden = YES;
                     
                     
                     content = [content stringByReplacingOccurrencesOfString:@"<en-note>" withString:@"<en-note xmlns=\"http://www.w3.org/1999/xhtml\">"];
                     NSData *d= [content dataUsingEncoding:NSUTF8StringEncoding];
                     [noteContent loadData:d MIMEType:@"application/xhtml+xml" textEncodingName:@"UTF-8" baseURL:nil];
  
                     textContent = (NSMutableString *)[[[Utility flattenNoteBody:content]stringByDecodingHTMLEntities] retain];
                     DebugLog(@"%@", textContent);
                     //noteContent.text = [[Utility flattenNoteBody:content]stringByDecodingHTMLEntities] ;
                     //self.title = [note title];
                 }failure:^(NSError *error) {
                     DebugLog(@"note::::::::error %@", error);	  
                     [Utility hideCoverScreen];
                     [loadingSpinner stopAnimating];
                     dialog_imgView.hidden = YES;
                     loadingLbl.hidden = YES;
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
    

    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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

//0 Post to Wall
//1 Post to chatter users
//2 Post to chatter groups
//3 Cancel
#pragma mark -
#pragma mark UIActionSheet Delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    DebugLog(@"clickedButtonAtIndex:%d",buttonIndex);
    if(buttonIndex == actionSheet.cancelButtonIndex){
    } else if(buttonIndex == 0) {
        [self postToChatterWall];
    } else if (buttonIndex == 1) {
        //post to chatter users
        [Utility showCoverScreen];
        ChatterUsersViewController * chatterUsersVC = [[ChatterUsersViewController alloc] init];
        chatterUsersVC.noteTitle = self.title;
        chatterUsersVC.noteContent = textContent;
        [self.navigationController pushViewController:chatterUsersVC animated:YES];
        [chatterUsersVC release];
        [Utility hideCoverScreen];
    } else if (buttonIndex == 2) {
        //post to chatter groups
        [Utility showCoverScreen];
        ChatterGroupVCntrlViewController * chatterGroupVC = [[ChatterGroupVCntrlViewController alloc] init];
        chatterGroupVC.noteTitle = self.title;
        chatterGroupVC.noteContent = textContent;
        [self.navigationController pushViewController:chatterGroupVC animated:YES];
        [chatterGroupVC release];
        [Utility hideCoverScreen];
    }
        
}

-(void)postToChatterWall {
    [Utility showCoverScreen];
    [self showLoadingLblWithText:@"Posting to Chatter Wall"];
    NSString * path = @"v23.0/chatter/feeds/news/me/feed-items";
    NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",textContent, @"text",nil];
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:param],@"messageSegments", nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

-(IBAction)linkEvernoteToSF:(id)sender {
    [Utility showCoverScreen];
    [self moveToSF];
}
-(IBAction)postToChatter:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissPreviousPopover];
        postToChatterOptionActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Post to Wall",@"Post to Chatter Users",@"Post to Chatter Group", nil];
    } else {
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
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Edit"]) {
        saveToSFBarBtn.enabled = NO;
        postToChatterBarBtn.enabled = NO;
        
        self.navigationItem.rightBarButtonItem.title = @"Save to Evernote";
        dialog_imgView.hidden = NO;
        [loadingSpinner stopAnimating];
        loadingLbl.text = @"Edit mode activated...";
        loadingLbl.hidden = NO;
        [Utility hideCoverScreen];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
        
        [self setContentEditable:YES];
        [self setWebViewKeyPressDetectionEnabled:YES];
        [self setWebViewTapDetectionEnabled:YES];    
        [self increaseZoomFactorRange];
    }
    else if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Save to Evernote"]) {

        saveToSFBarBtn.enabled = YES;
        postToChatterBarBtn.enabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"Edit";
        [self setContentEditable:NO];
        [self setWebViewKeyPressDetectionEnabled:NO];
        [self setWebViewTapDetectionEnabled:NO];  
        [self resignFirstResponder];
        [noteContent resignFirstResponder];
        //[self increaseZoomFactorRange];
        // NSString *htmlString = [noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        // NSLog(@"htmlString : %@",htmlString);
        [self updateNoteEvernote];
    }
  
   
    
    
}

-(void)moveToSF{
    RootViewController * rootVC = [[RootViewController alloc] init];
    rootVC.fileName = self.title;
    rootVC.noteContent = textContent;
    //rootVC.noteContent = noteContent.text;
    [self.navigationController pushViewController:rootVC animated:YES];
    [rootVC release];
    
    [Utility hideCoverScreen];
    
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    [self changeBkgrndImgWithOrientation];
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
    
    NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"%@",result);
}


- (void)setContentEditable:(BOOL)isEditable {
    NSString *jsEnableEditing = 
    
    [NSString stringWithFormat:@"document.documentElement.contentEditable=%@;", isEditable ? @"true" : @"false"];
    NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:jsEnableEditing];
   
    /*
    [NSString stringWithFormat:@"document.body.contentEditable=%@;", isEditable ? @"true" : @"false"];
    NSString *result = [noteContent stringByEvaluatingJavaScriptFromString:jsEnableEditing];
     */
    
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
    
    [noteContent stringByEvaluatingJavaScriptFromString:js];
}


- (void)updateBarButtonItems {
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Edit"]) {
        self.navigationItem.rightBarButtonItem.title = @"Save to Evernote";
        saveToSFBarBtn.enabled = NO;
        postToChatterBarBtn.enabled = NO;
    }
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
    //[self setContentEditable:YES];
    //[self setWebViewKeyPressDetectionEnabled:YES];
    //[self setWebViewTapDetectionEnabled:YES];    
    //[self increaseZoomFactorRange];
}




-(void)updateNoteEvernote {
    
    // Closing controls
    [noteContent resignFirstResponder];
    
    // Creating the Note Object
    EDAMNote * note = [[[EDAMNote alloc] init]autorelease];
    note.title =self.title;
    
    
    NSMutableString *bodyTxt =(NSMutableString *) [noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    bodyTxt = (NSMutableString *)[bodyTxt stringByReplacingOccurrencesOfString:@"<en-note xmlns=\"http://www.w3.org/1999/xhtml\" contenteditable=\"false\">" withString:@"<en-note>"];
    
     NSLog(@"htmlString : %@",bodyTxt); 
    NSString * ENML = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n%@",bodyTxt];
    
    
    DebugLog(@"ENML:%@", ENML);
    
    
    // Adding the content to the note
    [Utility showCoverScreen];
    [note setContent:ENML];
    note.guid = self.guid;
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = @"Updating Note...";
    //[loadingLbl sizeToFit];
    loadingLbl.hidden = NO;
    
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
                     if(isErrorCreatingnote == NO) {
                         // Alerting the user that the note was created
                         dialog_imgView.hidden = NO;
                         doneImgView.hidden = NO;
                         [loadingSpinner stopAnimating];
                         loadingLbl.text = @"Note was saved!";
                         [Utility hideCoverScreen];
                         [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
                     }
                     [loadingSpinner stopAnimating];   
                 });
             }
                          failure:^(NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                  DebugLog(@"update note::::::::error %@", error);	  
                                  [Utility showAlert:error.description];
                                  dialog_imgView.hidden = YES;
                                  loadingLbl.hidden = YES;
                                  [loadingSpinner stopAnimating];
                                  [Utility hideCoverScreen];
                                  isErrorCreatingnote = YES;
                                  self.navigationItem.rightBarButtonItem.title = @"Edit";
                                  [self setContentEditable:NO];
                                  [self setWebViewKeyPressDetectionEnabled:NO];
                                  [self setWebViewTapDetectionEnabled:NO];
                                  //[delegate evernoteCreationFailedListener];
                                  return;
                              });
                              
                          }];
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
                //[delegate evernoteCreationFailedListener];
                return;
            });
        }
        
    });
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
#import "Utility.h"
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);

    if([[request path] rangeOfString:@"/chatter/feeds/news/me/feed-items"].location != NSNotFound){
        //post to wall
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            [Utility hideCoverScreen];
            [self showLoadingLblWithText:@"Done!"];
            [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
            [loadingSpinner stopAnimating];
            NSArray *records = [jsonResponse objectForKey:@"records"];
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            
        }
        else{
            [loadingSpinner stopAnimating];
            [Utility showAlert:@"Problem in Posting to Chatter feed."];
            [Utility hideCoverScreen];
        }
        
        
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
    [Utility hideCoverScreen];
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
    [self hideDoneToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
}



@end
