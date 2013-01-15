     //
     //  NotesListViewController.h
     //  Noteprise
     //
     //  Created by Ritika on 23/04/12.
     //  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
     //

#import <UIKit/UIKit.h>
#import "AddNoteViewController.h"
#import "SettingsViewController.h"
#import "NotesViewController.h"
#define IDX_SEARCH_BASED_ON_NOTEBOOK 0

#define IDX_SEARCH_VIA_TAG 1
#define IDX_SEARCH_ACROSS_ACCOUNT 2
#define NOTE_KEY @"note"
#define NOTE_GUID_KEY @"note_guid"
#define NOTEBOOK_KEY @"notebook"
#define TAG_KEY @"tag"
#define READABLE @"readable"
@interface NotesListViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,AddNotesViewDelegate,MyPopoverDelegate>{
     
     
     NSMutableArray *listOfNotes;
     NSMutableArray *listOfNotebooks;
     NSMutableArray *listOfTags;
     NSMutableArray *searchResults;
          //NSMutableArray *indexArray;
          //NSMutableArray *noteBooksArr;
     IBOutlet UITableView *notesTbl;
     IBOutlet UILabel *loadingLbl;
     IBOutlet UISearchBar *searchBar;
     IBOutlet UIBarButtonItem *addNoteBtn;
     IBOutlet UIBarButtonItem *settingsBtn;
     UIBarButtonItem *saveToSFBtn;
     UIPopoverController *popoverController;
     IBOutlet UISegmentedControl *searchOptionsChoiceCntrl;
     NSArray *noteBooks;
     NSArray * tags;
     NSString *noteTitle;
     NSString *noteContent;
     NSString *searchKeyword;
     IBOutlet UIImageView *backgroundImgView;
     IBOutlet UIImageView *dialog_imgView;
     IBOutlet UIToolbar *bottom_bar;
     IBOutlet UIToolbar *toolbar;
     BOOL keyboardVisible;
     CGRect searchbarFrame;
    float orgHeight;
    float tempHeight;
    float orgOrigin;
     CGRect bottomFrame;
     int flag1,flag2;
}

@property(nonatomic,retain) NSArray *noteBooks;
@end
