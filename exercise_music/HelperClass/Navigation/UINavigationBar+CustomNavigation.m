//
//  UINavigationBar+CustomNavigation.m
//  LA3ANDAK
//
//  Created by Adite Technologies on 29/07/17.
//  Copyright © 2017 Adite Technologies. All rights reserved.
//
#import "exercise_music-Swift.h"
#import "UINavigationBar+CustomNavigation.h"
#import "HelperMethod.h"

@implementation UINavigationBar (CustomNavigation)

-(void)SetCustomNavigationBar
{
    [self setTitleTextAttributes:
     @{NSForegroundColorAttributeName:KAppDelegate.customnavigationSignUpTintColor}];

    self.tintColor = KAppDelegate.customnavigationSignUpTintColor;
    self.barStyle = UIBarStyleDefault;
    self.barTintColor = KAppDelegate.customnavigationSignUpBackgroundColor;
    [self setTranslucent:false];
    self.hidden = false;
}
-(void)ResetCustomNavigationBar
{
//    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:KAppDelegate.resetnavigationSignUpTintColor}];
//    
//    self.tintColor = KAppDelegate.resetnavigationSignUpTintColor;
    [self setBackgroundImage:[UIImage new]
                            forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [UIImage new];
    self.barTintColor = [UIColor clearColor];
    self.translucent = YES;
    self.barStyle = UIBarStyleDefault;
    self.hidden = false;
}

@end
