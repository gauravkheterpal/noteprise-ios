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


#define POST_TO_CHATTER_WALL_URL @"v23.0/chatter/feeds/news/me/feed-items"
#define LIST_OF_CHATTER_FOLLOWING_URL @"/services/data/v23.0/chatter/users/me/following?filterType=005&pageSize=1000"
#define LIST_OF_CHATTER_GROUP_URL @"v23.0/chatter/users/me/groups?pageSize=250"

#define OBJ_NAME @"name"
#define OBJ_LABEL @"label"
#define FIELD_NAME @"name"
#define FIELD_LABEL @"label"
#define FIELD_LIMIT @"length"

#define CHATTER_POST_LIMIT_ALERT_TAG               2000
#define CHATTER_POST_TO_GROUP_LIMIT_ALERT_TAG      3000
#define SAVE_TO_SFOBJ_LIMIT_ALERT_TAG              4000

#pragma mark - Generic Messages
#define NETWORK_UNAVAILABLE_MSG  @"No network connectivity!"
#define ALERT_POSITIVE_BUTTON_TEXT @"Yes"
#define ALERT_NEGATIVE_BUTTON_TEXT @"No"
#define ALERT_NEUTRAL_BUTTON_TEXT @"OK"
#define LOADING_MSG @"Loading.."
#define DONE_MSG @"Done!"
#define SOME_ERROR_OCCURED_MESSAGE @"An error occurred. Please try again."

#pragma mark - Note related Messages
#define ERROR_AUTHENTICATE_WITH_EVERNOTE_MSG @"Error. Could not authenticate."
#define EVERNOTE_LOGIN_FAILED_MSG @"Login Failed. Please check your username and password."
#define ERROR_LISTING_NOTE_MSG @"Note listing failed.Please retry again later."
#define LOADING_NOTEBOOKS_MSG @"Loading user Notebooks..."
#define note_please_enter_text_for_search_message @"Please enter the text to be searched"
#define progress_dialog_tag_search_message @"Searching tag in notes.."
#define progress_dialog_keyword_search_message @"Searching keyword in notes.."
#define progress_dialog_note_search_message @"Searching note.."
#define progress_dialog_notebook_search_message @"Searching notebook.."
#define NOTE_CREATION_SUCCESS_MSG @"Note successfully created"
#define NOTE_CREATION_FAILED_MSG @"Note creation failed!"
#define NOTE_DELETE_SUCCESS_MSG @"Note deleted successfully."
#define NOTE_DELETE_FAILED_MSG @"Note could not be deleted!"
#define NOTE_CREATING_MSG @"Creating Note..."
#define GETTING_NOTE_DETAILS_MSG @"Getting note details.."

#define SF_FIELDS_LIMIT_CROSSED_ALERT_MSG @"The number of characters in your note exceed the allowed limit on Salesforce Field.Do you want to truncate note content & post?"
#define CHATTER_LIMIT_CROSSED_ALERT_MSG  @"The number of characters in your note exceed the allowed limit on Salesforce Chatter.Do you want to truncate note content & post?"
#define CHATTER_LIMIT_CROSSED_ERROR_MSG @"The number of characters in your note exceed the allowed limit on Salesforce Chatter. Please split your content into multiple notes and try again."
#define CHATTER_MENTIONS_CROSSED_ERROR_MSG @"The number of Mentions exceed the allowed limit on Salesforce Chatter. Please deselect some users and try again."
#define SF_FIELDS_LIMIT_CROSSED_ERROR_MSG @"The number of characters in your note exceed the length of the Salesforce field. Please choose another field and try again"
#define CHATTER_API_DISABLED @"Unable to post. Chatter Connect API is disabled."

#define NOTEBOOK_MISSING_IN_EVERNOTE_MSG @"There isnt any notebook in your Evernote account.Please create one & try again"
#define NOTEBOOK_MISSING_MSG @"Please select a Notebook"
#define NOTE_CREATION_ALL_FIELDS_REQUIRED_MSG @"All fields are required."
#define LOCATION_TRACKING_DISABLED_MSG @"To re-enable & attach location with Note, please go to Settings and turn on Location Service for this app."
#define ATTACHING_USER_LOCATION_TO_NOTE_MSG @"Attaching user location..."
#define FAILED_RETRIEVE_USER_LOCATION_MSG @"Failed to retrieve user location!"

#pragma mark - Salesforce Related messages
#define SF_OBJECT_FIELD_MISSING_MSG @"Please select a object and field through Settings first."
#define SF_OBJECT_MISSING_MSG @"Please select a object first before you can select a field."
#define salesforce_record_saving_failed_message @"Failed to save record(s)."
#define progress_dialog_salesforce_getting_record_list_message @"Getting records list.."
#define CHATTER_POST_USER_MISSING_MSG @"Please select a user to make Chatter Post"
#define CHATTER_POST_GROUP_MISSING_MSG @"Please select a group to make Chatter Post"

#define NO_RECORD_IN_SF_OBJ_MSG @"No Record in Selected Salesforce object:"
#define ERROR_LISTING_SFOBJECTS_MSG @"Error in fetching sobjects."
#define ERROR_LISTING_SF_OBJECT_MSG @"Error in fetching selected SF object listing."
#define ERROR_LISTING_SFOBJECT_METADATA_MSG @"Error in fetching descriptions of selected sobjects."
#define progress_dialog_salesforce_record_updated_success_message @"Record(s) updated successfully."
#define progress_dialog_salesforce_record_updating_message @"Updating selected record(s)..."
#define progress_dialog_salesforce_save_record_message @"Saving record.."

#pragma mark - Chatter Related messages
#define POSTING_NOTE_TO_CHATTER_WALL_MSG @"Publishing to your feed.."
#define POSTING_NOTE_TO_CHATTER_USER_MSG @"Publishing to your Chatter feed.."
#define POSTING_NOTE_TO_CHATTER_GROUP_MSG @"Publishing to Chatter group feed.."
#define progress_dialog_chatter_getting_following_data_message @"Getting list of Chatter users.."
#define progress_dialog_chatter_getting_group_data_message @"Getting list of Chatter groups.."
#define salesforce_chatter_post_self_success_message @"The selected note has been succesfully posted to your Chatter feed."
#define salesforce_chatter_post_user_with_mentions_success_message @"The selected note has been succesfully posted to the chosen Chatter user feeds."
#define salesforce_chatter_post_group_success_message @"The selected note has been succesfully posted to the chosen Chatter group feed."


#define ERROR_SAVING_NOTE_TO_EVERNOTE_MSG @"Error saving note:"
#define POSTING_NOTE_FAILED_TO_CHATTER_WALL_MSG @"Failed to publish the selected note to your Chatter feed"
#define ERROR_LISTING_CHATTER_USERS_MSG @"Error in getting list of Chatter Users"
#define POSTING_NOTE_FAILED_TO_CHATTER_USER_MSG @"Failed to publish the selected note to chosen Chatter users"
#define ERROR_LISTING_CHATTER_GROUPS_MSG @"Failed to publish the selected note to chosen Chatter groups"

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
+ (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos;
@end
@interface UINavigationBar (CustomImage)
- (void) setBackgroundImage:(UIImage*)image;
- (void) clearBackgroundImage;
@end
@implementation UINavigationBar (CustomImage)

- (void) setBackgroundImage:(UIImage*)image {
    if (image == NULL) return;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 320, 44);
    [self insertSubview:imageView atIndex:0];
    [imageView release];
}

- (void) clearBackgroundImage {
    NSArray *subviews = [self subviews];
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i]  isMemberOfClass:[UIImageView class]]) {
            [[subviews objectAtIndex:i] removeFromSuperview];
        }
    }    
}

@end
