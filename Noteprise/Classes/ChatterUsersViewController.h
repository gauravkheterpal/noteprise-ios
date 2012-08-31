//
//  ChatterUsersViewController.h
//  Noteprise
//
//  Created by Ritika on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "IconDownloader.h"
@interface ChatterUsersViewController : UIViewController <SFRestDelegate,UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>
{
    NSMutableArray *selectedUsersRow;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *doneImgView;
    IBOutlet UIImageView *backgroundImgView;
    IBOutlet UITableView *chatterUsersTbl; 
    int selectedUserIndex;
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
    int mentionUsersCharacterCount;
}
@property(nonatomic,retain) NSString *noteTitle; 
@property(nonatomic,retain) NSString *noteContent;
@property (nonatomic, retain) NSMutableArray *chatterUsersArray;
@property (assign) BOOL inEditMode;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *unselectedImage;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@end
