     //
     //  NotesViewController.h
     //  Noteprise
     //
     //  Created by Meenal Jain on 1/5/13.
     //
     //

#import <UIKit/UIKit.h>
#import "Utility.h"
#define IDX_SEARCH_BASED_ON_NOTEBOOK 0

#define IDX_SEARCH_VIA_TAG 1
#define IDX_SEARCH_ACROSS_ACCOUNT 2
#define NOTE_KEY @"note"
#define NOTE_GUID_KEY @"note_guid"
#define NOTEBOOK_KEY @"notebook"
#define TAG_KEY @"tag"
#define READABLE @"readable"
@interface NotesViewController : UITableViewController{
     NSArray *noteBooks;
     NSArray * tags;
      UILabel *loadingLbl;
      UIImageView *dialog_imgView;

}
@property(nonatomic,retain) NSMutableArray *notes;
@property(nonatomic,assign) int selectedSegment;
@property(nonatomic,retain) NSArray *noteBooks;

@end
