/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFAuthorizingViewController.h"
#import "Utility.h"

@implementation SFAuthorizingViewController

@synthesize oauthView = _oauthView;
@synthesize authorizingMessageLabel=_authorizingMessageLabel;
@synthesize backgroundImgView;


#pragma mark - View lifecycle

-(void)viewDidLoad
{
    //Create subview array
    self.subviews = [NSMutableArray arrayWithCapacity:1];

    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return NO;
    }
	return YES;
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(self.scrollView == nil)
    {
        return;
    }
    
    rotationIsScrollingPage = YES;

    //Add currently displayed subview's copy to main view
    UIView * originalView = [self.subviews objectAtIndex:self.pageControl.currentPage];
    UIView * copyOfView =
    (UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:originalView]];
    
//    if([copyOfView isKindOfClass:[UIWebView class]])
//    {
//        NSString *html = [(UIWebView *)originalView stringByEvaluatingJavaScriptFromString:
//                          @"document.body.innerHTML"];
//        [((UIWebView *)copyOfView) loadHTMLString:html baseURL:nil];
//    }
    
    copyOfView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

    CGRect frame = copyOfView.frame;
    frame.origin.x = (self.scrollView.frame.size.width - frame.size.width)/2;
    copyOfView.frame = frame;
    
    
    //subviewCopy = (UIView *)copyOfView;
    cloneView = [[UIView alloc]initWithFrame:self.scrollView.frame];
    cloneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    cloneView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [cloneView addSubview:copyOfView];
    
    [self.view insertSubview:cloneView aboveSubview:self.scrollView];

    //hide scroll view
    self.scrollView.hidden = YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.scrollView == nil)
    {
        return;
    }
    
    [self addSubviewsToScrollView];
    
    //Set appropriate content offset
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    NSInteger currentPage = self.pageControl.currentPage;
    CGFloat x = scrollViewWidth * currentPage;
    [self.scrollView setContentOffset:CGPointMake(x, 0)];
    
    rotationIsScrollingPage = NO;
    
    //Show scroll view
    self.scrollView.hidden = NO;
    
    //Remove subview's copy
    [cloneView removeFromSuperview];
    [cloneView release];
}


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {    
        //    UIInterfaceOrientationMaskLandscape;
        //    24
        //
        //    UIInterfaceOrientationMaskLandscapeLeft;
        //    16
        //
        //    UIInterfaceOrientationMaskLandscapeRight;
        //    8
        //
        //    UIInterfaceOrientationMaskPortrait;
        //    2
        
        //    return UIInterfaceOrientationMaskPortrait;
        //    or
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - Properties
- (void)setOauthView:(UIView *)oauthView {
    if (![oauthView isEqual:_oauthView]) {
        [_oauthView removeFromSuperview];
        [_oauthView release];
        _oauthView = [oauthView retain];
        
        if (nil != _oauthView) {
            [_oauthView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_oauthView setFrame:self.view.bounds];
            
            //SetupView to show help tour
            [self setupView];
            //[self.view addSubview:_oauthView];
        }
    }
}


- (void)setupView
{
    //Create ScrollView
    UIScrollView * sv = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView = sv;
    [sv release];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[self.scrollView setCanCancelContentTouches:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
	
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.clipsToBounds = YES;
	self.scrollView.scrollEnabled = YES;
	self.scrollView.pagingEnabled = YES;
	[self.view addSubview:self.scrollView];
    
    
    //Create toolBar and add it at the bottom
    UIToolbar * tb = [[UIToolbar alloc]init];
    self.toolBar = tb;
    [tb release];
    
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.toolBar sizeToFit];
    CGRect frame = self.toolBar.frame;
    frame.size.width = self.view.bounds.size.width;
    frame.origin.x = 0;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    self.toolBar.frame = frame;
    
    UIBarButtonItem * loginButton = [[UIBarButtonItem alloc]initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(showLoginPage:)];
    
    //Use this to put space in between your toolbox buttons
    UIBarButtonItem * flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    
    NSArray * items = [NSArray arrayWithObjects:loginButton, flexItem, nil];
    
    [loginButton release];
    [flexItem release];
    
    [self.toolBar setItems:items];
        
    [self.view addSubview:self.toolBar];
        
    
    //Create PageControl
    UIPageControl * pc = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - kPageControlHeight - self.toolBar.frame.size.height, self.view.bounds.size.width, kPageControlHeight)];
    self.pageControl = pc;
    [pc release];
    
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];

    //Add subviews to scroll view
    [self addSubviewsToScrollView];
}


-(void)addSubviewsToScrollView
{
    //Remove all the subviews from scroll view and subviews array
    for(UIView * view in  self.subviews)
    {
        [view removeFromSuperview];
    }
    [self.subviews removeAllObjects];
    
    //Add images to scrollView
	NSUInteger nimages = 0;
	CGFloat cx = 0;
	
    for (; ; nimages++)
    {
		NSString *imageName = [NSString stringWithFormat:@"image%d.jpg", (nimages + 1)];
		UIImage *image = [UIImage imageNamed:imageName];
		
        if (image == nil)
        {
			break;
		}
        
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		
		CGRect rect = imageView.frame;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            rect.size.width = 320;
            rect.size.height = 460;
        }
        else
        {
            rect.size.width = 430;
            rect.size.height = 618;
        }
//		rect.size.height = image.size.height;
//		rect.size.width = image.size.width;
		rect.origin.x = ((self.scrollView.frame.size.width - rect.size.width) / 2) + cx;
		rect.origin.y = ((self.scrollView.frame.size.height - rect.size.height) / 2);
        
		imageView.frame = rect;
        
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        
		[self.scrollView addSubview:imageView];
        
        //Add imageView to subview array
        [self.subviews addObject:imageView];
        
		[imageView release];
        
		cx += self.scrollView.frame.size.width;
	}
	
    
    CGRect rect = _oauthView.frame;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        rect.size.width = 320;
        rect.size.height = 460;
    }
    else
    {
        rect.size.width = 430;
        rect.size.height = 618;
    }
    
    rect.origin.x = ((self.scrollView.frame.size.width - rect.size.width) / 2) + cx;
    rect.origin.y = ((self.scrollView.frame.size.height - rect.size.height) / 2);
    
    _oauthView.frame = rect;

//    _oauthView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.scrollView addSubview:_oauthView];

    //Add _oauthView to subview array
    [self.subviews addObject:_oauthView];
    
    cx += self.scrollView.frame.size.width;
    
    nimages++;
    
    
	self.pageControl.numberOfPages = nimages;
	[self.scrollView setContentSize:CGSizeMake(cx, [self.scrollView bounds].size.height)];
}


//-(void)adjustPlacingForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    CGFloat scrollViewWidth;
//    CGFloat scrollViewHeight;
//    
//    CGRect frame = [[UIScreen mainScreen] bounds];
//    
//    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        scrollViewWidth = frame.size.height;
//        scrollViewHeight = frame.size.width;
//    }
//    else
//    {
//        scrollViewWidth = frame.size.width;
//        scrollViewHeight = frame.size.height;
//    }
//    
//    CGFloat cx = 0;
//    for(UIView * subview in self.subviews)
//    {
//        CGRect rect = subview.frame;
//		rect.origin.x = ((scrollViewWidth - rect.size.width) / 2) + cx;
//		rect.origin.y = ((scrollViewHeight - rect.size.height) / 2);
//        
//        subview.frame = rect;
//        
//        cx += scrollViewWidth;
//        
//    }
//    
//    [self.scrollView setContentSize:CGSizeMake(cx, scrollViewHeight)];
//    
//    CGFloat x = self.pageControl.currentPage * scrollViewWidth;
//    [self.scrollView setContentOffset:CGPointMake(x, 0)];
//}


#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    if(rotationIsScrollingPage)
    {
        return;
    }
    
    CGFloat width = self.scrollView.contentSize.width - 2 * self.scrollView.frame.size.width;
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    
    if(contentOffsetX >  width)
    {
        CGFloat value = 1 - (contentOffsetX - width) / self.scrollView.frame.size.width;
        
        self.pageControl.alpha = self.toolBar.alpha = value;
    }
    
    if (pageControlIsChangingPage)
    {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sv
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (void)changePage:(id)sender
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
	
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}


-(void)showLoginPage:(id)sender
{
    self.pageControl.currentPage = self.pageControl.numberOfPages - 1;
    [self changePage:self.pageControl];
}



-(void)dealloc
{
    [_oauthView release];
    [_pageControl release];
    [_scrollView release];
    [_toolBar release];
    [_subviews release];
    
    [super dealloc];
}

@end
