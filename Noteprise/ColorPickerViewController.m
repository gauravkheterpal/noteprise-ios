//
//  ColorPickerViewController.m
//  NoteBox
//
//  Created by John Bennedict on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorPickerViewController

@synthesize delegate=_delegate;

+ (NSArray *)supportedColors {

    return [NSArray arrayWithObjects:
                [UIColor purpleColor],
                [UIColor blueColor],
                [UIColor greenColor],            
                [UIColor redColor],
                [UIColor orangeColor],
                [UIColor yellowColor],
                [UIColor whiteColor],
                [UIColor lightGrayColor],            
                [UIColor grayColor],            
                [UIColor darkGrayColor],
                [UIColor blackColor],
                nil];
}

NSString *htmlColorFromUIColor(UIColor *color) {
    const CGFloat* colors = CGColorGetComponents(color.CGColor);

    size_t colorComponents = CGColorGetNumberOfComponents(color.CGColor);
    
    unsigned char r = 0, g = 0, b = 0;
    
    if (colorComponents == 2) {
        r = (unsigned char)(colors[0] * 255);
        g = r;
        b = r;
    } else if (colorComponents == 4) {
        r = (unsigned char)(colors[0] * 255);
        g = (unsigned char)(colors[1] * 255);
        b = (unsigned char)(colors[2] * 255);
    }
    
    NSString *ret = [NSString stringWithFormat:@"rgb(%d,%d,%d)",r,g,b];
    
    return ret;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)didSelectColor:(id)sender {
    
    if ([sender isKindOfClass:[UIView class]]) {
        NSUInteger tag = [(UIView *)sender tag];
                          
        if ([_delegate respondsToSelector:@selector(colorPicker:didSelectColor:)])
            [_delegate colorPicker:self didSelectColor:[self.class.supportedColors objectAtIndex:tag]];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    static CGFloat const kSpacing = 10.0f;
    
    static CGSize const kButtonSize = { .width = 200.0f, .height = 44.0f };
    
    CGFloat y = kSpacing + kButtonSize.height / 2;

    CGRect rect = CGRectZero;
    rect.size.height = (kSpacing + kButtonSize.height) * self.class.supportedColors.count + kSpacing;
    rect.size.width = 2 * kSpacing + kButtonSize.width;

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.contentSize = rect.size;
    
    self.view = scrollView;
    [scrollView release];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight
                                | UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleTopMargin;
    
    for (UIColor *color in self.class.supportedColors) {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = color;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.borderWidth = 0.5f;
        button.layer.cornerRadius = 10.0f;
        button.tag = [self.class.supportedColors indexOfObject:color];
        
        CGRect frame = button.frame;
        frame.size = kButtonSize;
        button.frame = frame;
        button.center = CGPointMake(self.view.center.x, y);    
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleLeftMargin
                                | UIViewAutoresizingFlexibleRightMargin;
        
        [button addTarget:self action:@selector(didSelectColor:) forControlEvents:UIControlEventTouchUpInside];        
        
        [self.view addSubview:button];
        
        y += button.frame.size.height + kSpacing;
        
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.alpha = 0.5f;
}

@end
