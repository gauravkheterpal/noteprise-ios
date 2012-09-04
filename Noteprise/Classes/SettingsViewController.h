//
//  SettingsViewController.h
//  Noteprise
//
//  Created by Ritika on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@protocol MyPopoverDelegate <NSObject>
-(void)dissmissPopover;
@end
@interface SettingsViewController : UITableViewController <SFRestDelegate>
{
    NSMutableArray *dataRows;
    
}
@property (nonatomic, retain) NSArray *dataRows;
@property (nonatomic, assign) id<MyPopoverDelegate> popover_delegate; 
@end
