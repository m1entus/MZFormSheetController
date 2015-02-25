//
//  MZFormSheetPresentationController.m
//  MZFormSheetPresentationController
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

#import "MZFormSheetPresentationController.h"
#import "UIViewController+TargetViewController.h"
#import "MZFormSheetPresentationControllerAnimator.h"

CGFloat const MZFormSheetPresentationControllerDefaultAnimationDuration = 0.35;

static NSMutableDictionary *_instanceOfTransitionClasses = nil;

@interface MZFormSheetPresentationController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;
@property (nonatomic, assign, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, strong) NSValue *screenFrameWhenKeyboardVisible;
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@end

@implementation MZFormSheetPresentationController

#pragma mark - Dealloc

- (void)dealloc {
    [self.view removeGestureRecognizer:self.backgroundTapGestureRecognizer];
    self.backgroundTapGestureRecognizer = nil;

    [self.contentViewController willMoveToParentViewController:nil];
    [self.contentViewController.view removeFromSuperview];
    [self.contentViewController removeFromParentViewController];
    self.contentViewController = nil;

    [self removeKeyboardNotifications];
}

#pragma mark - Class methods

+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle
{
    [[MZFormSheetPresentationController sharedTransitionClasses] setObject:transitionClass forKey:@(transitionStyle)];
}

+ (Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle
{
    return [MZFormSheetPresentationController sharedTransitionClasses][@(transitionStyle)];
}


+ (NSMutableDictionary *)sharedTransitionClasses
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceOfTransitionClasses = [[NSMutableDictionary alloc] init];
    });
    return _instanceOfTransitionClasses;
}

#pragma mark - Appearance

+ (void)load
{
    @autoreleasepool {
        MZFormSheetPresentationController *appearance = [self appearance];
        [appearance setContentViewSize:CGSizeMake(284.0, 284.0)];
        [appearance setPortraitTopInset:66.0];
        [appearance setLandscapeTopInset:6.0];
        [appearance setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [appearance setBlurEffectStyle:UIBlurEffectStyleLight];
        [appearance setMovementActionWhenKeyboardAppears:MZFormSheetActionWhenKeyboardAppearsDoNothing];
    }
}

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

#pragma mark - Setters

- (void)setContentViewSize:(CGSize)contentViewSize {
    if (!CGSizeEqualToSize(_contentViewSize, contentViewSize)) {
        _contentViewSize = CGSizeMake(nearbyintf(contentViewSize.width), nearbyintf(contentViewSize.height));

        CGPoint center = self.contentViewController.view.center;
        self.contentViewController.view.frame = CGRectMake(0, 0, _contentViewSize.width, _contentViewSize.height);
        self.contentViewController.view.center = center;
        [self setupFormSheetViewControllerFrame];
    }
}

#pragma mark - Getters

- (CGFloat)yCoordinateBelowStatusBar {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGFloat)topInset {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        return self.portraitTopInset + [self yCoordinateBelowStatusBar];
    } else {
        return self.landscapeTopInset + [self yCoordinateBelowStatusBar];
    }
}

#pragma mark - View Life cycle

- (instancetype)initWithContentViewController:(UIViewController *)viewController {
    if (self = [super init]) {

        NSParameterAssert(viewController);
        self.contentViewController = viewController;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.transitioningDelegate = self;

        id appearance = [[self class] appearance];
        [appearance applyInvocationTo:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addKeyboardNotifications];

    [self addBackgroundTapGestureRecognizer];

    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];

    [self setupFormSheetViewController];
    [self setupBackgroundBlurView];
    [self setupFormSheetViewControllerFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self handleEntryTransitionAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self handleOutTransitionAnimated:animated];

}


#pragma mark - Transitions

- (void)handleEntryTransitionAnimated:(BOOL)animated {
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        MZFormSheetPresentationControllerTransitionHandler transitionCompletionHandler = ^(){
            if (self.didPresentContentViewControllerHandler) {
                self.didPresentContentViewControllerHandler(self.contentViewController);
            }
        };

        if (self.willPresentContentViewControllerHandler) {
            self.willPresentContentViewControllerHandler(self.contentViewController);
        }

        if (animated) {
            [self transitionEntryWithCompletionBlock:transitionCompletionHandler];
        } else {
            transitionCompletionHandler();
        }

    } completion:nil];
}

- (void)handleOutTransitionAnimated:(BOOL)animated {
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        MZFormSheetPresentationControllerTransitionHandler transitionCompletionHandler = ^(){
            if (self.didDismissContentViewControllerHandler) {
                self.didDismissContentViewControllerHandler(self.contentViewController);
            }
        };

        if (self.willDismissContentViewControllerHandler) {
            self.willDismissContentViewControllerHandler(self.contentViewController);
        }

        if (animated) {
            [self transitionOutWithCompletionBlock:transitionCompletionHandler];
        } else {
            transitionCompletionHandler();
        }
        
    } completion:nil];
}

- (void)transitionEntryWithCompletionBlock:(MZFormSheetPresentationControllerTransitionHandler)completionBlock
{
    Class transitionClass = [MZFormSheetPresentationController sharedTransitionClasses][@(self.contentViewControllerTransitionStyle)];

    if (transitionClass) {
        id <MZFormSheetControllerTransition> transition = [[transitionClass alloc] init];

        [transition entryFormSheetControllerTransition:self
                                     completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)transitionOutWithCompletionBlock:(MZFormSheetPresentationControllerTransitionHandler)completionBlock
{
    Class transitionClass = [MZFormSheetPresentationController sharedTransitionClasses][@(self.contentViewControllerTransitionStyle)];

    if (transitionClass) {
        id <MZFormSheetControllerTransition> transition = [[transitionClass alloc] init];

        [transition exitFormSheetControllerTransition:self
                                    completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

#pragma mark - Blur

- (void)setupBackgroundBlurView {
    [self.blurBackgroundView removeFromSuperview];
    self.blurBackgroundView = nil;

    if (self.shouldApplyBackgroundBlurEffect) {

        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        self.blurBackgroundView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];

        self.blurBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

        self.blurBackgroundView.frame = self.view.bounds;
        self.blurBackgroundView.translatesAutoresizingMaskIntoConstraints = YES;
        self.blurBackgroundView.userInteractionEnabled = NO;

        self.view.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:self.blurBackgroundView atIndex:0];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
}

#pragma mark - Setup

- (void)setupFormSheetViewController {
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.contentViewController.view.layer.cornerRadius = 6.0;
    self.contentViewController.view.layer.masksToBounds = YES;
    self.contentViewController.view.frame = CGRectMake(0, 0, self.contentViewSize.width, self.contentViewSize.height);
    self.contentViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)setupFormSheetViewControllerFrame {
    if (self.keyboardVisible && self.movementActionWhenKeyboardAppears != MZFormSheetActionWhenKeyboardAppearsDoNothing) {
        CGRect formSheetRect = self.contentViewController.view.frame;
        CGRect screenRect = [self.screenFrameWhenKeyboardVisible CGRectValue];

        if (screenRect.size.height > formSheetRect.size.height) {
            switch (self.movementActionWhenKeyboardAppears) {
                case MZFormSheetActionWhenKeyboardAppearsCenterVertically:
                    formSheetRect.origin.y = ([self yCoordinateBelowStatusBar] + screenRect.size.height - formSheetRect.size.height)/2 - screenRect.origin.y;
                    break;
                case MZFormSheetActionWhenKeyboardAppearsMoveToTop:
                    formSheetRect.origin.y = [self yCoordinateBelowStatusBar];
                    break;
                case MZFormSheetActionWhenKeyboardAppearsMoveToTopInset:
                    formSheetRect.origin.y = [self topInset];
                    break;
                default:
                    break;
            }
        } else {
            formSheetRect.origin.y = [self yCoordinateBelowStatusBar];
        }

        self.contentViewController.view.frame = formSheetRect;
    } else if (self.shouldCenterVertically) {
        self.contentViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    } else {
        CGRect frame = self.contentViewController.view.frame;
        frame.origin.y = self.topInset;
        self.contentViewController.view.frame = frame;
    }
}

#pragma mark - UIKeyboard Notifications

- (void)willShowKeyboardNotification:(NSNotification *)notification
{
    CGRect screenRect = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    screenRect.size.height = [UIScreen mainScreen].bounds.size.height - screenRect.size.height;
    screenRect.size.width = [UIScreen mainScreen].bounds.size.width;
    screenRect.origin.y = 0;

    self.screenFrameWhenKeyboardVisible = [NSValue valueWithCGRect:screenRect];
    self.keyboardVisible = YES;

    [UIView animateWithDuration:MZFormSheetPresentationControllerDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setupFormSheetViewControllerFrame];
    } completion:nil];

}

- (void)willHideKeyboardNotification:(NSNotification *)notification
{
    self.keyboardVisible = NO;
    self.screenFrameWhenKeyboardVisible = nil;

    [UIView animateWithDuration:MZFormSheetPresentationControllerDefaultAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setupFormSheetViewControllerFrame];
    } completion:nil];

}

- (void)addKeyboardNotifications
{
    [self removeKeyboardNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - UIGestureRecognizer

- (void)addBackgroundTapGestureRecognizer {
    [self removeBackgroundTapGestureRecognizer];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapGestureRecognizer:)];
    tapGesture.delegate = self;
    self.backgroundTapGestureRecognizer = tapGesture;

    [self.view addGestureRecognizer:tapGesture];
}

- (void)removeBackgroundTapGestureRecognizer {
    [self.view removeGestureRecognizer:self.backgroundTapGestureRecognizer];
    self.backgroundTapGestureRecognizer = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // recive touch only on background window
    if (touch.view == self.view) {
        return YES;
    }
    return NO;
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGesture
{
    // If last form sheet controller will begin dismiss, don't want to recive touch
    if (tapGesture.state == UIGestureRecognizerStateEnded){
        CGPoint location = [tapGesture locationInView:[tapGesture.view superview]];
        if (self.didTapOnBackgroundViewCompletionHandler) {
            self.didTapOnBackgroundViewCompletionHandler(location);
        }
        if (self.shouldDismissOnBackgroundViewTap) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - UIViewController (UIContainerViewControllerProtectedMethods)

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        return [navigationController.topViewController mz_childTargetViewControllerForStatusBarStyle];
    }

    return [self.contentViewController mz_childTargetViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if ([self.contentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        return [navigationController.topViewController mz_childTargetViewControllerForStatusBarStyle];
    }
    return [self.contentViewController mz_childTargetViewControllerForStatusBarStyle];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self setupFormSheetViewControllerFrame];

    [self.contentViewController viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.contentViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return [self.contentViewController shouldAutorotate];
}

#pragma mark - <UIViewControllerTransitioningDelegate>

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MZFormSheetPresentationControllerAnimator *animator = [[MZFormSheetPresentationControllerAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MZFormSheetPresentationControllerAnimator *animator = [[MZFormSheetPresentationControllerAnimator alloc] init];
    animator.presenting = NO;
    return animator;
}

@end
