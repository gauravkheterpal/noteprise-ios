
#import "Utility.h"
#import "Keys.h"
#import "Reachability.h"
#import "SVProgressHUD.h"


#define TAG_BACKGROUNDIMG_VIEW 1999

//UIImageView *imgView;
//ProgressIndicatorView * progressIndicatorView;

@implementation Utility

+(NSString*)archivedDatafilePath{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [NSString stringWithFormat:@"%@/data.plist",docPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        //[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}

+(void)createDataFile{

}

+(void)saveAuthResult:(id)data{
     NSMutableData *_data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:_data];          
    [archiver encodeObject:data forKey:KEY_AUTH_RESULT];
    [archiver finishEncoding];
    [_data writeToFile:[Utility archivedDatafilePath] atomically:YES];
    [archiver release];
    //[data release];
}

+(id)autResult{
    NSString * path = [Utility archivedDatafilePath];
    DebugLog(@"path %@",path);
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:path];    

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    id _data = [[unarchiver decodeObjectForKey:KEY_AUTH_RESULT] retain];    
    [unarchiver finishDecoding];
    [unarchiver release];
    return _data;

}

+(void)deleteAuthResult
{
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [NSString stringWithFormat:@"%@/data.plist",docPath];
    DebugLog(@"path:%@",path);
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        //[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}



//+(void)addSemiTransparentOverlay
//{
//    //Get window's reference
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    
//    if(window.rootViewController != nil)
//    {
//        //Create progress indicator view
//        progressIndicatorView = [[ProgressIndicatorView alloc] init];
//        
//        //Hide it
//        progressIndicatorView.hidden = YES;
//        
//        //Add it as a subview to window's rootViewController's view
//        [window.rootViewController.view addSubview:progressIndicatorView];
//    }
//}



+(void)hideCoverScreen
{
    //Diddmiss progress indicator
    [SVProgressHUD dismiss];
    
//    if([progressIndicatorView superview] != nil)
//    {
//        [progressIndicatorView setHidden:YES];
//    }
}


+(void)showCoverScreenWithText:(NSString *) text andType:(NSInteger)coverScreenType
{
    if(coverScreenType == kInProcessCoverScreen)
    {
        [SVProgressHUD showWithStatus:text maskType:SVProgressHUDMaskTypeGradient];
    }
    else if(coverScreenType == kProcessDoneCoverScreen)
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showSuccessWithStatus:text duration:-1];
    }
    else if(coverScreenType == kWarningCoverScreen)
    {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD showErrorWithStatus:text duration:-1];
    }

    
//    if([progressIndicatorView superview] != nil)
//    {
//        //Set text and type of progressIndicator
//        [progressIndicatorView setText:text andType:coverScreenType];
//        
//        [progressIndicatorView setHidden:NO];
//        
//        [[progressIndicatorView superview] bringSubviewToFront:progressIndicatorView];
//    }
}



+(BOOL)isBlank:(NSString*)str
{
    return ([str isEqualToString:@""] || !str);
}

+(void)showAlert:(NSString*)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Noteprise" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [alert release];
}
+(void)showExceptionAlert:(NSString*)message
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

+(void)setValueInPref:(NSString*)value forKey:(NSString*)key{
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    [stdDefaults setValue:value forKey:key];
    [stdDefaults synchronize];
}

+(NSString*)valueInPrefForKey:(NSString*)key{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}
+(void)removeValueInPrefForKey:(NSString*)key{
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    [stdDefaults removeObjectForKey:key];
    [stdDefaults synchronize];
}
+(void)setImage:(UIImage*)image forBtn:(UIButton*)btn{
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateSelected];
    [btn setImage:image forState:UIControlStateHighlighted];
}
+(void)setSFDefaultMappingValues{
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultSFObjValue = [NSDictionary dictionaryWithObjectsAndKeys:@"Account",OBJ_NAME,@"Account",OBJ_LABEL, nil];
    [stdDefaults setValue:defaultSFObjValue forKey:SFOBJ_TO_MAP_KEY];
    NSDictionary *defaultSFFieldValue = [NSDictionary dictionaryWithObjectsAndKeys:@"Account Description",FIELD_LABEL,@"Description",FIELD_NAME, nil];
    [stdDefaults setValue:defaultSFFieldValue forKey:SFOBJ_FIELD_TO_MAP_KEY];
    [stdDefaults synchronize];
    
}
+ (NSString *)flattenNoteBody:(NSString *)noteBobyContent {
    DebugLog(@"string to flatten:%@",noteBobyContent);
    
    NSString * startEnNoteTag = [NSString stringWithFormat:@"%@>",[self getDataBetweenFromString:noteBobyContent leftString:@"<en-note" rightString:@">" leftOffset:0]];
    NSString * endEnNoteTag = [NSString stringWithFormat:@"%@>",[self getDataBetweenFromString:noteBobyContent leftString:@"</en-note" rightString:@">" leftOffset:0]];
    
    NSRange start = [noteBobyContent rangeOfString:startEnNoteTag];
    NSRange end = [noteBobyContent rangeOfString:endEnNoteTag];
    if(start.location !=NSNotFound){
        noteBobyContent = [noteBobyContent substringWithRange:NSMakeRange(start.location+start.length, end.location-(start.location+start.length))]; 
        DebugLog(@"html:%@",noteBobyContent);
        noteBobyContent = [noteBobyContent stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
                noteBobyContent = [noteBobyContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        noteBobyContent = [Utility flattenHTML:noteBobyContent];
        DebugLog(@"flatten html:%@",noteBobyContent);
        return noteBobyContent;
    } else {
        noteBobyContent = [self flattenHTML:noteBobyContent];
        DebugLog(@"flatten html:%@",noteBobyContent);
        return noteBobyContent;
    }
    
    
}

+ (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos 
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


+ (NSString *)flattenHTML:(NSString *)html {
    
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
        
        [theScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}
+(NSString*)valueInPrefForEvernoteHost {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *primaryEvernoteLoginHost = [defs objectForKey:EVERNOTE_LOGIN_HOST];
    
    // If the primary host value is nil/empty, it's never been set.  Initialize it to default and return it.
    if (nil == primaryEvernoteLoginHost) {
        [defs setValue:@"www.evernote.com" forKey:EVERNOTE_LOGIN_HOST];
        [defs synchronize];
        return @"www.evernote.com";
    }
    return [defs objectForKey:EVERNOTE_LOGIN_HOST];
    
}

+ (BOOL) checkNetwork
{
	DebugLog(@"checkNetwork");
        
	Reachability *currentReach = [Reachability reachabilityForInternetConnection];
	NetworkStatus netStatus = [currentReach currentReachabilityStatus];
	switch (netStatus){
		case NotReachable:
			return NO;
		case ReachableViaWWAN:
			return YES;
		case ReachableViaWiFi:		
			return YES;  
	}
	
	[currentReach release];
	return NO;
    
}
+(BOOL)isDeviceiPhone5 {
    if ([[UIScreen mainScreen] bounds].size.height == 568)
        return YES;
    else
        return NO;
}
@end
