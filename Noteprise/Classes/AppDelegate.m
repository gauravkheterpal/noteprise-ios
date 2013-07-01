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

#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"
#import "InitialViewController.h"
#import "RootViewController.h"
#import "SignInViewController.h"
#import "Utility.h"
#import "Keys.h"
#import "NotesListViewController.h"
#import "NoteDetailViewController.h"
#import "EvernoteSDK.h"
#import "SFJsonUtils.h"
#import "SFAccountManager.h"
#import "SFAuthenticationManager.h"
#import "SFOAuthInfo.h"
#import "SFLogger.h"

/*
 NOTE if you ever need to update these, you can obtain them from your Salesforce org,
 (When you are logged in as an org administrator, go to Setup -> Develop -> Remote Access -> New )
 */


// Fill these in when creating a new Remote Access client on Force.com 
//static NSString *const RemoteAccessConsumerKey = @"3MVG9Y6d_Btp4xp4XNcguxcwQ2Z0yAk6hikPUvgnnD3vptoPEfo6Ot7RfdiPO.Do15UInElV747dL.QEstRxE";
static NSString *const RemoteAccessConsumerKey = @"3MVG9Y6d_Btp4xp7TYnbVJx2W7iPeWGju0BzaRrm4HDO0q32dR3xmWgh4DCGWOhPZ2SF2RHFQIPME.KaoCQcm";
static NSString *const OAuthRedirectURI = @"https://login.salesforce.com/services/oauth2/success";;//@"sdfc://success";

@interface AppDelegate ()

/**
 * Success block to call when authentication completes.
 */
@property (nonatomic, copy) SFOAuthFlowSuccessCallbackBlock initialLoginSuccessBlock;

/**
 * Failure block to calls if authentication fails.
 */
@property (nonatomic, copy) SFOAuthFlowFailureCallbackBlock initialLoginFailureBlock;

/**
 * Handles the notification from SFAuthenticationManager that a logout has been initiated.
 * @param notification The notification containing the details of the logout.
 */
- (void)logoutInitiated:(NSNotification *)notification;

/**
 * Handles the notification from SFAuthenticationManager that the login host has changed in
 * the Settings application for this app.
 * @param The notification whose userInfo dictionary contains:
 *        - kSFLoginHostChangedNotificationOriginalHostKey: The original host, prior to host change.
 *        - kSFLoginHostChangedNotificationUpdatedHostKey: The updated (new) login host.
 */
- (void)loginHostChanged:(NSNotification *)notification;

/**
 * Convenience method for setting up the main UIViewController and setting self.window's rootViewController
 * property accordingly.
 */
- (void)setupRootViewController;

/**
 * (Re-)sets the view state when the app first loads (or post-logout).
 */

- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize initialLoginSuccessBlock = _initialLoginSuccessBlock;
@synthesize initialLoginFailureBlock = _initialLoginFailureBlock;

- (id)init
{
    self = [super init];
    if (self) {
        [SFLogger setLogLevel:SFLogLevelDebug];
        
        // These SFAccountManager settings are the minimum required to identify the Connected App.
        [SFAccountManager setClientId:RemoteAccessConsumerKey];
        [SFAccountManager setRedirectUri:OAuthRedirectURI];
        [SFAccountManager setScopes:[NSSet setWithObjects:@"web", @"api", nil]];
        
        // Logout and login host change handlers.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutInitiated:) name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHostChanged:) name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
        
        // Blocks to execute once authentication has completed.  You could define these at the different boundaries where
        // authentication is initiated, if you have specific logic for each case.
        __weak AppDelegate *weakSelf = self;
        self.initialLoginSuccessBlock = ^(SFOAuthInfo *info) {
            [weakSelf setupRootViewController];
        };
        self.initialLoginFailureBlock = ^(SFOAuthInfo *info, NSError *error) {
            [[SFAuthenticationManager sharedManager] logout];
        };
    }
    
    return self;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
}


#pragma mark - Remote Access / OAuth configuration


- (NSString*)remoteAccessConsumerKey {
    return RemoteAccessConsumerKey;
}

- (NSString*)oauthRedirectURI {
    return OAuthRedirectURI;
}


#pragma mark - App delegate lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
    
    return YES;
}


- (void)initializeAppViewState
{
    self.window.rootViewController = [[InitialViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    
    self.window.rootViewController = [self newRootViewController];
}

- (void)logoutInitiated:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Logout notification received.  Resetting app."];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
}

- (void)loginHostChanged:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Login host changed notification received.  Resetting app."];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
}

//NOTE be sure to call all super methods you override.

- (UIViewController*)newRootViewController
{
    //Set SFRestAPI version
    [[SFRestAPI sharedInstance] setApiVersion:kSFRestAPIVersion];
    
    
//    [Utility addSemiTransparentOverlay];
    
    // Initial development is done on the sandbox service
    // Change this to @"www.evernote.com" to use the production Evernote service
    
    NSString *EVERNOTE_HOST = [Utility valueInPrefForEvernoteHost];
    
    //NSString *EVERNOTE_HOST = @"sandbox.evernote.com";
    
    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    //NSString *CONSUMER_KEY = @"noteprise-6118";
    //NSString *CONSUMER_SECRET = @"86270bc68d76886d";
    
    NSString *CONSUMER_KEY = @"noteprise-3933";
    NSString *CONSUMER_SECRET = @"ce361e9ac663ad4a";
    
    //NSString * const CONSUMER_KEY  = @"dubeynikhileshs";
    //NSString * const CONSUMER_SECRET = @"1845964c8335f00c";
    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST 
                              consumerKey:CONSUMER_KEY 
                           consumerSecret:CONSUMER_SECRET]; 
    EvernoteSession *session = [EvernoteSession sharedSession];
    
    if (!session.isAuthenticated)
    {
        SignInViewController *signInVC = [[SignInViewController alloc]init];
        return signInVC;
    }
    else
    {
         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
         {
             NotesListViewController *noteListVC = [[NotesListViewController alloc]init];
             UINavigationController *navVC = [[[UINavigationController alloc] initWithRootViewController:noteListVC] autorelease];
             [noteListVC release];
             navVC.navigationBar.barStyle = UIBarStyleBlack;
             return navVC;
         }
         else
         {
             NotesListViewController *noteListViewController = [[[NotesListViewController alloc]init] autorelease];
             UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:noteListViewController] autorelease];
             
             NoteDetailViewController * noteDetailViewController = [[[NoteDetailViewController alloc] init] autorelease];
             UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:noteDetailViewController] autorelease];
             
             noteListViewController.detailViewController = noteDetailViewController;
             noteDetailViewController.masterViewController = noteListViewController;
             
             UISplitViewController * splitViewController = [[[UISplitViewController alloc] init] autorelease];
             splitViewController.delegate = noteDetailViewController;
             splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];

             return splitViewController;
         }
        
    }
}


@end
