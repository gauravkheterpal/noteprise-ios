//
//  InfoViewController.m
//  Noteprise
//
//  Created by admin on 25/02/13.
//
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"About Me";
    
   /*NSString * userName = [((SFNativeRestAppDelegate *)[[UIApplication sharedApplication]delegate]) userName];
    
    if(userName != nil && ![userName isEqualToString:@""])
    {
        self.userNameLabel.text = userName;
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.userNameLabel release];
    
    [super dealloc];
}

@end
