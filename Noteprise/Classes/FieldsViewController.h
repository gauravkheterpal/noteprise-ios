//
//  FieldsViewController.h
//  Noteprise
//
//  Created by Ritika on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "Utility.h"
#import "SettingsViewController.h"
@interface FieldsViewController : UITableViewController <SFRestDelegate>{
    NSArray *objFields;
    int selectedRowIndex;
    NSIndexPath *lastIndexPath;
    id<MyPopoverDelegate> delegate;

}
@property (nonatomic,retain)   id<MyPopoverDelegate> delegate;
@property(nonatomic,retain) NSString *selectedObj;
@property(nonatomic,retain) NSString *objectID;
@property(nonatomic,retain) NSString *noteContent;
@property(nonatomic,retain) NSString *noteTitle;
@property(nonatomic,retain) NSArray *objFields;
@end
