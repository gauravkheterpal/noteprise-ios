//
//  ChatterGroupVCntrlViewController.h
//  Noteprise
//
//  Created by Gaurav on 20/08/12.
//
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "IconDownloader.h"
@interface ChatterGroupVCntrlViewController : UIViewController <SFRestDelegate,UITableViewDataSource,UITableViewDelegate,IconDownloaderDelegate>
{
    NSMutableArray *selectedGroupsRow;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *doneImgView;
    IBOutlet UIImageView *backgroundImgView;
    IBOutlet UITableView *chatterGroupTbl;
    int selectedGroupIndex;
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each app
}
@property(nonatomic,retain) NSString *noteTitle;
@property(nonatomic,retain) NSString *noteContent;
@property (nonatomic, retain) NSMutableArray *chatterGroupArray;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *unselectedImage;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (assign) BOOL inEditMode;
@end
