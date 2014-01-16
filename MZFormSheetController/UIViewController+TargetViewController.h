//
//  UIViewController+TargetViewController.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 16.01.2014.
//  Copyright (c) 2014 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MZTargetViewController)

- (UIViewController *)mz_parentTargetViewController;
- (UIViewController *)mz_childTargetViewControllerForStatusBarStyle;
- (UIViewController *)mz_childTargetViewControllerForStatusBarHidden;

@end
