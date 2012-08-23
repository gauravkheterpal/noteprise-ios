//
//  SignInViewController.m
//  Noteprise
//
//  Created by Ritika on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "Utility.h"
#import "Keys.h"
#import "EvernoteSDK.h"
@interface SignInViewController ()

@end
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat iPad_LANDSCAPE_KEYBOARD_HEIGHT = 452;
static const CGFloat iPhone_PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat iPhone_LANDSCAPE_KEYBOARD_HEIGHT = 205;
@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     //   backgroundImg.image = [UIImage imageNamed:@"evernoteBg.png"];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self changeBkgrndImgWithOrientation:orientation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)changeBkgrndImgWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
       if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImg.image = [UIImage imageNamed:@"evernoteBg480x300.png"];
        else {
            backgroundImg.image = [UIImage imageNamed:@"evernoteBg320x460.png"];
            }
        } else {
            
           if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
               backgroundImg.image = [UIImage imageNamed:@"evernoteBg-1024x748.png"];
                //signInBtn.frame = CGRectMake(400, 520, 235, 57);
                }
           else {
               backgroundImg.image = [UIImage imageNamed:@"evernoteBg768x1024.png"];
                //signInBtn.frame = CGRectMake(270, 700, 235, 57);
                }
           }
}
//-(void)changeBkgrndImgWithOrientation {
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//            backgroundImg.image = [UIImage imageNamed:@"evernoteBg480x300.png"];
//        else {
//            backgroundImg.image = [UIImage imageNamed:@"evernoteBg320x460.png"];
//        }
//    } else {
//        
//        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeRight || self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//            DebugLog(@"land");
//            backgroundImg.image = [UIImage imageNamed:@"evernoteBg-1024x748.png"];
//            signInBtn.frame = CGRectMake(400, 520, 235, 57);
//        }
//        else {
//                        DebugLog(@"port");
//            backgroundImg.image = [UIImage imageNamed:@"evernoteBg768x1024.png"];
//                        signInBtn.frame = CGRectMake(270, 700, 235, 57);
//        }
//    }
//}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self changeBkgrndImgWithOrientation];
    return YES;
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self changeBkgrndImgWithOrientation:toInterfaceOrientation];
}
-(BOOL)validate{
    if([Utility isBlank:userNameTxt.text] || [Utility isBlank:pswdTxt.text]){
        return NO;
    }
    return YES;
}

-(void)navigateToSearchOptionVC{
    [Utility hideCoverScreen];
    NotesListViewController *notesListCnrl = [[NotesListViewController alloc]init];
    UINavigationController *noteListNavCntrl = [[UINavigationController alloc]initWithRootViewController:notesListCnrl];
    noteListNavCntrl.navigationBar.barStyle = UIBarStyleBlack;
    [[[UIApplication sharedApplication]delegate]window].rootViewController = noteListNavCntrl;
}
-(void)removeCoverScreen{
    [Utility hideCoverScreen];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == userNameTxt)
        [pswdTxt becomeFirstResponder];
    else if (textField == pswdTxt) {
        [self signin:nil];
    }
    return YES;
}
-(IBAction)signin:(id)sender{
    if([Utility checkNetwork]) {
        EvernoteSession *session = [EvernoteSession sharedSession];
        [session authenticateWithViewController:self completionHandler:^(NSError *error) {
            if (error || !session.isAuthenticated) {
                // authentication failed :(
                // show an alert, etc
                // ...
                DebugLog(@"authenticateWithViewController error:%d desc:%@",error.code,error.description);
                [Utility showAlert:@"Error. Could not authenticate."];
                /*UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                                 message:@"Could not authenticate" 
                                                                delegate:nil 
                                                       cancelButtonTitle:@"OK" 
                                                       otherButtonTitles:nil] autorelease];
                [alert show];*/
            } else {
                DebugLog(@"authenticated! noteStoreUrl:%@ webApiUrlPrefix:%@", session.noteStoreUrl, session.webApiUrlPrefix);
                // authentication succeeded :)
                // do something now that we're authenticated
                // ... 
                [self loadNotesListAfterAuthentication];
            } 
        }];
    } else {
        [Utility showAlert:@"Network connectivity needed to login to Evernote"];
    }
}
- (void)loadNotesListAfterAuthentication 
{    
    EvernoteSession *session = [EvernoteSession sharedSession];
    
    if (session.isAuthenticated) {
        NotesListViewController *noteListVC = [[NotesListViewController alloc]init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:noteListVC];
         navVC.navigationBar.barStyle = UIBarStyleBlack;
        [[[UIApplication sharedApplication]delegate]window].rootViewController = navVC;
        [noteListVC release];
        //[navVC release];
    } else {
        //LOAD NOTHING ON FAILURE
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//Perform an action
	[userNameTxt resignFirstResponder];
    [pswdTxt resignFirstResponder];
}

@end