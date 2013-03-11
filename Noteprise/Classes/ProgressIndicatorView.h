//
//  ProgressIndicatorView.h
//  Noteprise
//
//  Created by Ravi Chaudhary on 06/03/13.
//
//

#import <UIKit/UIKit.h>

@interface ProgressIndicatorView : UIView

//Instance Methods
-(void)createView;
-(void)setText:(NSString *) text andType:(NSInteger)coverScreenType;

@end
