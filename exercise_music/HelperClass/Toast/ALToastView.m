//
//  ALToastView.h
//
//  Created by Alex Leutgöb on 17.07.11.
//  Copyright 2011 alexleutgoeb.com. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "ALToastView.h"


// Set visibility duration
static const CGFloat kDuration = 2;


// Static toastview queue variable
static NSMutableArray *toasts;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ALToastView ()

@property (nonatomic, readonly) UILabel * textLabel;

- (void)fadeToastOut;
+ (void)nextToastInView:(UIView *)parentView;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation ALToastView

@synthesize textLabel = _textLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithText:(NSString *)text isKeyBoardUp:(BOOL) isUP {
    if ((self = [self initWithFrame:CGRectZero])) {
        // Add corner radius
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 5;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.autoresizesSubviews = NO;
        
        _textLabel = [[UILabel alloc] init];
        
        _textLabel.numberOfLines = 0;
        _textLabel.text = text;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor lightGrayColor];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        
        [_textLabel sizeToFit];
        
        [self showNewMSG:text Label:_textLabel isKeyBoardUp:isUP];
        
        [self addSubview:_textLabel];
        _textLabel.frame = CGRectOffset(_textLabel.frame, 5, 5);
    }
    
    return self;
}

- (void) showNewMSG:(NSString *) msg Label:(UILabel *) lblMSG isKeyBoardUp:(BOOL) isUP {
    CGRect rectScreen = [UIScreen mainScreen].bounds;
    
    float keyBoard = 0.0;
    if (isUP)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            
            if ([[UIScreen mainScreen] nativeBounds].size.height >= 2436) //check for iPhone x
            {
                keyBoard = -295.0;
            }
            else
            {
                keyBoard = -253.0;
            }
        }
        else
        {
            keyBoard = -253.0;
        }
    }
    
    float width = rectScreen.size.width - 30;
    
    CGSize size = [self findHeightForText:msg havingWidth:width andFont:[UIFont fontWithName:@"TimesNewRomanPSMT" size:14]];
    
    width = size.width;
    
    lblMSG.text = msg;
    
    CGRect newRect = CGRectMake(0, 0, width, size.height);
    CGRect rectView = CGRectMake((rectScreen.size.width/2) - ((width + 10)/2), keyBoard + (-50) + rectScreen.size.height - size.height, width + 10, size.height + 10);
    
    lblMSG.frame = newRect;
    self.frame = rectView;
    
    [self addSubview:lblMSG];
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *) font {
    CGSize size = CGSizeZero;
    if (text) {
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    
    return size;
}

- (void)dealloc {
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

+ (void)toastInView:(UIView *)parentView withText:(NSString *)text isKeyBoardUp:(BOOL) isUP {
    // Add new instance to queue
    ALToastView * view = [[ALToastView alloc] initWithText:text isKeyBoardUp:isUP];
    view.alpha = 0.0f;
    
    if (toasts == nil) {
        toasts = [[NSMutableArray alloc] initWithCapacity:1];
        [toasts addObject:view];
        [ALToastView nextToastInView:parentView];
    }
    else {
        [toasts addObject:view];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fadeToastOut {
    // Fade in parent view
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.alpha = 0.f;
                     }
                     completion:^(BOOL finished){
                         UIView *parentView = self.superview;
                         [self removeFromSuperview];
                         
                         // Remove current view from array
                         [toasts removeObject:self];
                         if ([toasts count] == 0) {
                             toasts = nil;
                         }
                         else
                             [ALToastView nextToastInView:parentView];
                     }];
}

+ (void)nextToastInView:(UIView *)parentView {
    if ([toasts count] > 0) {
        ALToastView *view = [toasts objectAtIndex:0];
        
        // Fade into parent view
        [parentView addSubview:view];
        [UIView animateWithDuration:.5  delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 1.0;
                         } completion:^(BOOL finished){}];
        
        // Start timer for fade out
        [view performSelector:@selector(fadeToastOut) withObject:nil afterDelay:kDuration];
    }
}

@end
