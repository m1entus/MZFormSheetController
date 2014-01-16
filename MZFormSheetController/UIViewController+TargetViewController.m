//
//  UIViewController+TargetViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 16.01.2014.
//  Copyright (c) 2014 Michał Zaborowski. All rights reserved.
//

#import "UIViewController+TargetViewController.h"

@implementation UIViewController (MZTargetViewController)

- (UIViewController *)mz_parentTargetViewController
{
    UIViewController *parentTargetViewController = self;
    while (parentTargetViewController.presentedViewController) {
        parentTargetViewController = parentTargetViewController.presentedViewController;
    }
    return parentTargetViewController;
}

- (UIViewController *)mz_childTargetViewControllerForStatusBarStyle
{
    UIViewController *childTargetViewController;
	
    if ([self respondsToSelector:@selector(childViewControllerForStatusBarStyle)]) {
        childTargetViewController = [self childViewControllerForStatusBarStyle];
        if (childTargetViewController) {
            return [childTargetViewController mz_childTargetViewControllerForStatusBarStyle];
        }
    }
	
    return self;
}

- (UIViewController *)mz_childTargetViewControllerForStatusBarHidden
{
    UIViewController *childTargetViewController;
	
    if ([self respondsToSelector:@selector(childViewControllerForStatusBarHidden)]) {
        childTargetViewController = [self childViewControllerForStatusBarHidden];
        if (childTargetViewController) {
            return [childTargetViewController mz_childTargetViewControllerForStatusBarHidden];
        }
    }
	
    return self;
}

@end
