//
//  ChatterGroupVCntrlViewController.h
//  Noteprise
//
//  Created by Gaurav on 20/08/12.
//
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
@interface ChatterGroupVCntrlViewController : UIViewController <SFRestDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *selectedGroupsRow;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *doneImgView;
    IBOutlet UIImageView *backgroundImgView;
    IBOutlet UITableView *chatterGroupTbl;
    int selectedUserIndex;
}
@property(nonatomic,retain) NSString *noteTitle;
@property(nonatomic,retain) NSString *noteContent;
@property (nonatomic, retain) NSArray *chatterGroupArray;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *unselectedImage;
@end
