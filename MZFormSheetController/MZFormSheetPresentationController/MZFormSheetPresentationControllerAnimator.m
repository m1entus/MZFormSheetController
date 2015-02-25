//
//  MZFormSheetPresentationControllerAnimator.m
//  MZFormSheetPresentationControllerAnimator
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
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

#import "MZFormSheetPresentationControllerAnimator.h"

CGFloat const MZFormSheetPresentationControllerAnimatorDefaultTransitionDuration = 0.35;

@implementation MZFormSheetPresentationControllerAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.duration = MZFormSheetPresentationControllerAnimatorDefaultTransitionDuration;
    }
    return self;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *sourceViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *targetViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *sourceView = [transitionContext respondsToSelector:@selector(viewForKey:)] ? [transitionContext viewForKey:UITransitionContextFromViewKey] : sourceViewController.view;
    UIView *targetView = [transitionContext respondsToSelector:@selector(viewForKey:)] ? [transitionContext viewForKey:UITransitionContextToViewKey] : sourceViewController.view;

    if (self.isPresenting) {
        [self animateTransitionForPresentation:transitionContext sourceViewController:sourceViewController sourceView:sourceView targetViewController:targetViewController targetView:targetView];
    } else {
        [self animateTransitionForDismiss:transitionContext sourceViewController:sourceViewController sourceView:sourceView targetViewController:targetViewController targetView:targetView];
    }

}

- (void)animateTransitionForPresentation:(id <UIViewControllerContextTransitioning>)transitionContext sourceViewController:(UIViewController *)sourceViewController sourceView:(UIView *)sourceView targetViewController:(UIViewController *)targetViewController targetView:(UIView *)targetView {

    UIView *containerView = [transitionContext containerView];

    [containerView addSubview:targetView];
    targetView.alpha = 0.0;

    [UIView animateWithDuration:self.duration animations:^{
        targetView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [sourceView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }
    }];
}

- (void)animateTransitionForDismiss:(id <UIViewControllerContextTransitioning>)transitionContext sourceViewController:(UIViewController *)sourceViewController sourceView:(UIView *)sourceView targetViewController:(UIViewController *)targetViewController targetView:(UIView *)targetView {
    UIView *containerView = [transitionContext containerView];

    [containerView insertSubview:targetView belowSubview:sourceView];
    sourceView.alpha = 1.0;

    [UIView animateWithDuration:self.duration animations:^{
        sourceView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [sourceView removeFromSuperview];
            sourceView.alpha = 1.0;
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }
    }];
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end
