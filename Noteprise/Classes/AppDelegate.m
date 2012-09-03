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

#import "AppDelegate.h"
#import "RootViewController.h"
#import "SignInViewController.h"
#import "Utility.h"
#import "Keys.h"
#import "NotesListViewController.h"
#import "EvernoteSDK.h"
/*
 NOTE if you ever need to update these, you can obtain them from your Salesforce org,
 (When you are logged in as an org administrator, go to Setup -> Develop -> Remote Access -> New )
 */


// Fill these in when creating a new Remote Access client on Force.com 
//static NSString *const RemoteAccessConsumerKey = @"3MVG9Y6d_Btp4xp4XNcguxcwQ2Z0yAk6hikPUvgnnD3vptoPEfo6Ot7RfdiPO.Do15UInElV747dL.QEstRxE";
static NSString *const RemoteAccessConsumerKey = @"3MVG9Y6d_Btp4xp7TYnbVJx2W7iPeWGju0BzaRrm4HDO0q32dR3xmWgh4DCGWOhPZ2SF2RHFQIPME.KaoCQcm";
static NSString *const OAuthRedirectURI = @"https://login.salesforce.com/services/oauth2/success";;//@"sdfc://success";

@implementation AppDelegate


#pragma mark - Remote Access / OAuth configuration


- (NSString*)remoteAccessConsumerKey {
    return RemoteAccessConsumerKey;
}

- (NSString*)oauthRedirectURI {
    return OAuthRedirectURI;
}



#pragma mark - App lifecycle


//NOTE be sure to call all super methods you override.

- (UIViewController*)newRootViewController {
    [Utility addSemiTransparentOverlay];
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
    
    if (!session.isAuthenticated) {
        SignInViewController *signInVC = [[SignInViewController alloc]init];
        return signInVC;
    
    }
    else{
        NotesListViewController *noteListVC = [[NotesListViewController alloc]init];
         UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:noteListVC];
        [noteListVC release];
        navVC.navigationBar.barStyle = UIBarStyleBlack;
        return navVC;
        
    }
}

@end
