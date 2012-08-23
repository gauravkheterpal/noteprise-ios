//
//  ColorPickerViewController.h
//  NoteBox
//
//  Created by John Bennedict on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate;

@interface ColorPickerViewController : UIViewController

@property (nonatomic,assign) id <ColorPickerDelegate> delegate;

@end

NSString *htmlColorFromUIColor(UIColor *color);

@protocol ColorPickerDelegate <NSObject>

@optional

- (void)colorPicker:(ColorPickerViewController *)picker didSelectColor:(UIColor *)color;

@end