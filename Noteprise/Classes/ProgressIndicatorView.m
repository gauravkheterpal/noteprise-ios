//
//  ProgressIndicatorView.m
//  Noteprise
//
//  Created by Ravi Chaudhary on 06/03/13.
//
//

#import "ProgressIndicatorView.h"
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"

@implementation ProgressIndicatorView

- (id)init
{
    self = [super init];
    if (self)
    {        
        //Create view
        [self createView];
        
        //Set instance variable value
        _showsSemiTransparentOverlay = YES;
    }
    return self;
}


-(void)setShowsSemiTransparentOverlay:(BOOL)showsSemiTransparentOverlay
{
    _showsSemiTransparentOverlay = showsSemiTransparentOverlay;
    self.backgroundColor = showsSemiTransparentOverlay ?  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] : [UIColor clearColor];
}


-(void)createView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        self.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    }
    else
    {
        self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.hidden = NO;
    self.tag = kProgressIndicatorViewTag;
    
    //    UIView * semiTransparentOverlay = [[UIView alloc]init];
    //    semiTransparentOverlay.frame = progressIndicatorView.frame;
    //    semiTransparentOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    semiTransparentOverlay.backgroundColor = [UIColor blackColor];
    //    semiTransparentOverlay.alpha = 0.5f;
    //    [progressIndicatorView addSubview:semiTransparentOverlay];
    //    [semiTransparentOverlay release];
    
    UIView * roundedRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    roundedRectView.center = self.center;
    roundedRectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    roundedRectView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    roundedRectView.layer.cornerRadius = 10.0f;
    roundedRectView.tag = kRoundedRectViewTag;
    
    UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(81, 15, 37, 37)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activity.tag = kActivityIndicatorViewTag;
    [activity startAnimating];
    [roundedRectView addSubview:activity];
    [activity release];
    
    UIImageView * warningImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.png"]];
    warningImageView.frame = CGRectMake(87, 21, 24, 24);
    warningImageView.tag = kWarningImageTag;
    [roundedRectView addSubview:warningImageView];
    [warningImageView release];
    
    UIImageView * checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkbox_checked.png"]];
    checkmarkImageView.frame = CGRectMake(87, 21, 24, 24);
    checkmarkImageView.tag = kCheckmarkImageTag;
    [roundedRectView addSubview:checkmarkImageView];
    [checkmarkImageView release];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, roundedRectView.frame.size.width, 50)];
    label.font = [UIFont systemFontOfSize:17.0f];

    label.numberOfLines = 0;
    [label setLineBreakMode:NSLineBreakByWordWrapping];

//    label.adjustsFontSizeToFitWidth = YES;
//    label.minimumFontSize = 12.0f;

    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = UITextAlignmentCenter;
    label.tag = kProgressIndicatorLabelTag;
    [roundedRectView addSubview:label];
    [label release];
    
    [self addSubview:roundedRectView];
    [roundedRectView release];
}



-(void)setText:(NSString *) text andType:(NSInteger)coverScreenType
{
    UIView * roundedRectView = [self viewWithTag:kRoundedRectViewTag];
    
    //Set text
    UILabel * label = (UILabel *)[roundedRectView viewWithTag:kProgressIndicatorLabelTag];
    label.text = text;
    
    //Show imageView depending on parameter type
    UIImageView * warningImageView = (UIImageView *)[roundedRectView viewWithTag:kWarningImageTag];
    UIImageView * checkmarkImageView = (UIImageView *)[roundedRectView viewWithTag:kCheckmarkImageTag];
    UIActivityIndicatorView * activity = (UIActivityIndicatorView *)[roundedRectView viewWithTag:kActivityIndicatorViewTag];
    
    [warningImageView setHidden:YES];
    [checkmarkImageView setHidden:YES];
    [activity setHidden:YES];
    
    switch (coverScreenType)
    {
        case kWarningCoverScreen:
            [warningImageView setHidden:NO];
            break;
            
        case kInProcessCoverScreen:
            [activity setHidden:NO];
            break;
            
        case kProcessDoneCoverScreen:
            [checkmarkImageView setHidden:NO];
            break;
            
        default:
            break;
    }    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
