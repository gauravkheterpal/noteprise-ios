
#import "Utility.h"
#import "Keys.h"
#import "Reachability.h"


#define TAG_BACKGROUNDIMG_VIEW 1999

//UIImageView *imgView;
ProgressIndicatorView * progressIndicatorView;

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



+(void)addSemiTransparentOverlay
{
    //Get window's reference
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    if(window.rootViewController != nil)
    {   
//        progressIndicatorView = [[UIView alloc]init];
//        CGRect frame = [[UIScreen mainScreen] bounds];
//        
//        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//        
//        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
//        {
//            progressIndicatorView.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
//        }
//        else
//        {
//            progressIndicatorView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        }
//        
//        progressIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        progressIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//        progressIndicatorView.hidden = NO;
//        progressIndicatorView.tag = kProgressIndicatorViewTag;
//        
//        UIView * roundedRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
//        roundedRectView.center = progressIndicatorView.center;
//        roundedRectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
//        roundedRectView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//        roundedRectView.layer.cornerRadius = 10.0f;
//        roundedRectView.tag = kRoundedRectViewTag;
//        
//        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(81, 15, 37, 37)];
//        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//        activity.tag = kActivityIndicatorViewTag;
//        [activity startAnimating];
//        [roundedRectView addSubview:activity];
//        [activity release];
//        
//        UIImageView * warningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.png"]];
//        warningImageView.frame = CGRectMake(87, 21, 24, 24);
//        warningImageView.tag = kWarningImageTag;
//        [roundedRectView addSubview:warningImageView];
//        [warningImageView release];
//        
//        UIImageView * checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkbox_checked.png"]];
//        checkmarkImageView.frame = CGRectMake(87, 21, 24, 24);
//        checkmarkImageView.tag = kCheckmarkImageTag;
//        [roundedRectView addSubview:checkmarkImageView];
//        [checkmarkImageView release];
//        
//        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, roundedRectView.frame.size.width, 30)];
//        label.font = [UIFont systemFontOfSize:18.0f];
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor whiteColor];
//        label.textAlignment = UITextAlignmentCenter;
//        label.tag = kProgressIndicatorLabelTag;
//        [roundedRectView addSubview:label];
//        [label release];
//
//        [progressIndicatorView addSubview:roundedRectView];
//        [roundedRectView release];
        
        //Create progress indicator view
        progressIndicatorView = [[ProgressIndicatorView alloc] init];
        
        //Hide it
        progressIndicatorView.hidden = YES;
        
        //Add it as a subview to window's rootViewController's view
        [window.rootViewController.view addSubview:progressIndicatorView];
    }
        
//    NSArray * views = [window subviews];
//    
//    UIView * view = [views objectAtIndex:0];
//    
//    Class className = [view class];
//    
//    if(view != nil)
//    {
//        [view addSubview:progressIndicatorView];
//    }
    
}



+(void)hideCoverScreen
{
    if([progressIndicatorView superview] != nil)
    {
        [progressIndicatorView setHidden:YES];
    }
}

+(void)showCoverScreen
{
    [progressIndicatorView setHidden:NO];
    
    [[progressIndicatorView superview] bringSubviewToFront:progressIndicatorView];
}


+(void)showCoverScreenWithText:(NSString *) text andType:(NSInteger)coverScreenType
{
    //UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    //UIView * progressIndicatorView = [window viewWithTag:kProgressIndicatorViewTag];

    if([progressIndicatorView superview] != nil)
    {
        //Set text and type of progressIndicator
        [progressIndicatorView setText:text andType:coverScreenType];
        
//        UIView * roundedRectView = [progressIndicatorView viewWithTag:kRoundedRectViewTag];
//        
//        UILabel * label = (UILabel *)[roundedRectView viewWithTag:kProgressIndicatorLabelTag];
//        label.text = text;
//            
//        UIImageView * warningImageView = (UIImageView *)[roundedRectView viewWithTag:kWarningImageTag];
//        UIImageView * checkmarkImageView = (UIImageView *)[roundedRectView viewWithTag:kCheckmarkImageTag];
//        UIActivityIndicatorView * activity = (UIActivityIndicatorView *)[roundedRectView viewWithTag:kActivityIndicatorViewTag];
//        
//        [warningImageView setHidden:YES];
//        [checkmarkImageView setHidden:YES];
//        [activity setHidden:YES];
//        
//        switch (coverScreenType)
//        {
//            case kWarningCoverScreen:
//                [warningImageView setHidden:NO];
//                break;
//            
//            case kInProcessCoverScreen:
//                [activity setHidden:NO];
//                break;
//                
//            case kProcessDoneCoverScreen:
//                [checkmarkImageView setHidden:NO];
//                break;
//                
//            default:
//                break;
//        }
        
        [progressIndicatorView setHidden:NO];
        
        [[progressIndicatorView superview] bringSubviewToFront:progressIndicatorView];
    }
}


//+(void)addSemiTransparentOverlay
//{
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    
//    //UIImageView *
//    
//    imgView = [[UIImageView alloc] init];
//    imgView.frame = [[UIScreen mainScreen] bounds];
//    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    imgView.alpha = 0.5f;
//    imgView.backgroundColor = [UIColor blackColor];
//    imgView.tag = TAG_BACKGROUNDIMG_VIEW;
//    
//    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] init];
//    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    activity.center = imgView.center;
//    [activity startAnimating];
//    activity.hidden = NO;
//    [imgView addSubview:activity];
//    
//    [window addSubview:imgView];
//    
//    [activity release];
//    
//}
//
//+(void)removeSemiTransparentOverlay
//{
//    [imgView removeFromSuperview];
//}

//+(void)hideCoverScreen
//{
//    [imgView setHidden:YES];
//}
//
//+(void)showCoverScreen
//{
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    imgView.userInteractionEnabled = YES;
////    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
////        imgView.frame = CGRectMake(0, 0, 768, 1024);
////    else {
////        imgView.frame = CGRectMake(0, 0, 320, 480);
////    }
//    
//    UIActivityIndicatorView *activity=nil;
//    
//    if(imgView.subviews.count>0)
//        activity = [imgView.subviews objectAtIndex:0];
//    
//    activity.center = imgView.center;
//    
//    [imgView setHidden:NO];
//    [window bringSubviewToFront:imgView];
//}


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
