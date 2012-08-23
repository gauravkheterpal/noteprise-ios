//
//  NoteViewController.h
//  
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"



@interface NoteViewController : UIViewController <UIWebViewDelegate,SFRestDelegate,UIActionSheetDelegate>{

    UINavigationBar * noteNavigation;
    //UITextView * noteContent;
    UIWebView * noteContent;
    //UIImageView * noteImage;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *backgroundImgView;
    
    //UIBarButtonItem *saveButton;
    //UIBarButtonItem *editButton;
    //UIToolbar* toolbar;
    IBOutlet UIImageView *doneImgView;
    UIActionSheet *postToChatterOptionActionSheet;
    IBOutlet UIBarButtonItem *saveToSFBarBtn;
    IBOutlet UIBarButtonItem *postToChatterBarBtn;

}

@property(nonatomic, assign) NSString * guid;
//@property (nonatomic, retain) IBOutlet UIImageView * noteImage;
@property (nonatomic, retain) IBOutlet UINavigationBar * noteNavigation;
//@property (nonatomic, retain) IBOutlet UITextView * noteContent;
@property (nonatomic, retain) IBOutlet UIWebView * noteContent;
@property (nonatomic, retain) NSMutableString * textContent;


-(void)goBack:(id)sender;
-(void)moveToSF;
-(void)setContentEditable:(BOOL)isEditable;
-(void)setWebViewKeyPressDetectionEnabled:(BOOL)isEnabled ;
-(void)setWebViewTapDetectionEnabled:(BOOL)isEnabled ;
-(void)increaseZoomFactorRange;
-(void)updateNoteEvernote ;
//-(void)setupNavigationButtons ;
-(void)changeBkgrndImgWithOrientation;
-(void)hideDoneToastMsg:(id)sender;

@end
