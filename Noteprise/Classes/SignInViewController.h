//
//  SignInViewController.h
//  Noteprise
//
//  Created by Ritika on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignInViewController : UIViewController
{
    IBOutlet UITextField *userNameTxt;
    IBOutlet UITextField *pswdTxt;
    CGFloat animatedDistance; //textfield correction when keyboard is out
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *backgroundImg;
    IBOutlet UIButton *signInBtn;
}

@end
