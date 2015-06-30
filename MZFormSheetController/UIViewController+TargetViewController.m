//
//  UIViewController+TargetViewController.m
//  MZFormSheetController
//
//  Created by Michał Zaborowski on 16.01.2014.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "UIViewController+TargetViewController.h"

@implementation UIViewController (MZFormSheetTargetViewController)

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
