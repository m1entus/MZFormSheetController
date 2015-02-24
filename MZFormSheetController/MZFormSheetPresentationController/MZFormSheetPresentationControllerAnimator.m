//
//  MZFormSheetPresentationControllerAnimator.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import "MZFormSheetPresentationControllerAnimator.h"

@implementation MZFormSheetPresentationControllerAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.duration = 0.35;
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
