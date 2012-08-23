
#import "Utility.h"
#import "Keys.h"
#import "Reachability.h"
UIImageView *imgView;
#define TAG_BACKGROUNDIMG_VIEW 1999
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
+(void)deleteAuthResult {
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [NSString stringWithFormat:@"%@/data.plist",docPath];
    DebugLog(@"path:%@",path);
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        //[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}
+(void)addSemiTransparentOverlay{
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    //UIImageView * 
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    imgView.alpha = 0.5f;
    imgView.backgroundColor = [UIColor blackColor];
    imgView.tag = TAG_BACKGROUNDIMG_VIEW;
    
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] init];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activity.center = imgView.center;
    [activity startAnimating];
    activity.hidden = NO;
    [imgView addSubview:activity];
    
    [window addSubview:imgView];
    
    [activity release];
    
}

+(void)removeSemiTransparentOverlay{
    [imgView removeFromSuperview];
}

+(void)hideCoverScreen{
    [imgView setHidden:YES];
}

+(void)showCoverScreen{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    imgView.userInteractionEnabled = YES;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        imgView.frame = CGRectMake(0, 0, 768, 1024);
    else {
        imgView.frame = CGRectMake(0, 0, 320, 480);
    }
    
    UIActivityIndicatorView *activity=nil;
    
    if(imgView.subviews.count>0)
        activity = [imgView.subviews objectAtIndex:0];
    
    activity.center = imgView.center;
    
    [imgView setHidden:NO];
    [window bringSubviewToFront:imgView];
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
    NSDictionary *defaultSFObjValue = [NSDictionary dictionaryWithObjectsAndKeys:@"Account",@"name",@"Account",@"label", nil];
    [stdDefaults setValue:defaultSFObjValue forKey:SFOBJ_TO_MAP_KEY];
    NSDictionary *defaultSFFieldValue = [NSDictionary dictionaryWithObjectsAndKeys:@"Account Description",@"label",@"Description",@"name", nil];
    [stdDefaults setValue:defaultSFFieldValue forKey:SFOBJ_FIELD_TO_MAP_KEY];
    [stdDefaults synchronize];
    
}
+ (NSString *)flattenNoteBody:(NSString *)noteBobyContent {
    //html =@"abcd<en-note>abc</en-note>";
    
    NSRange start = [noteBobyContent rangeOfString:@"<en-note>"];
    NSRange end = [noteBobyContent rangeOfString:@"</en-note>"];
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
+ (BOOL) checkNetwork {
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
@end