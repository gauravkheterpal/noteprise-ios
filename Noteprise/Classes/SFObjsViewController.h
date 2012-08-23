//
//  SFObjsViewController.h
//  Noteprise
//
//  Created by Ritika on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
@interface SFObjsViewController : UITableViewController <SFRestDelegate> {
    NSArray  *sfObjsList;
    int selectedRowIndex;
    id delegate;
}
@property (nonatomic,retain)   NSArray  *sfObjsList;
@property (nonatomic,retain)   id delegate;
@end
