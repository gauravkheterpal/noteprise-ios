//
//  Utility.h
//  TestApplication
//
//  Created by Gaurav on 25/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SFOBJ_TO_MAP_KEY @"sfobject"
#define SFOBJ_FIELD_TO_MAP_KEY @"sfobJField"
#define OLD_SFOBJ_TO_MAP_KEY @"old_sfobject"
#define OLD_SFOBJ_FIELD_TO_MAP_KEY @"old_sfobJField"
#define EVERNOTE_LOGIN_HOST @"evernote_login_host_pref"
#define kCellImageViewTag           1000
#define kCellLabelTag               1001

/*
 *  System Versioning Preprocessor Macros
 */ 

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



static NSString *const kWebViewDidPressKeyURL   = @"http://didPressKey/";
static NSString *const kWebViewDidTapURL        = @"http://didTap/";
static NSString *const kHTML2DOCConverterURL    = @"http://csboxnotes.appspot.com/html2doc";
@interface Utility : NSObject

+(void)hideCoverScreen;
+(void)showCoverScreen;
+(void)addSemiTransparentOverlay;

+(void)showAlert:(NSString*)message;
+(BOOL)isBlank:(NSString*)str;

+(void)setValueInPref:(NSString*)value forKey:(NSString*)key;
+(NSString*)valueInPrefForKey:(NSString*)key;

+(void)setImage:(UIImage*)image forBtn:(UIButton*)btn;

+(NSString*)archivedDatafilePath;
+(void)saveAuthResult:(id)data;
+(id)autResult;
+(void)deleteAuthResult;
+(void)removeValueInPrefForKey:(NSString*)key;
+(void)setSFDefaultMappingValues;
+ (NSString *)flattenNoteBody:(NSString *)noteBobyContent;
+ (NSString *)flattenHTML:(NSString *)html;
+(NSString*)valueInPrefForEvernoteHost;
+ (BOOL) checkNetwork;
+(void)showExceptionAlert:(NSString*)message;
@end
