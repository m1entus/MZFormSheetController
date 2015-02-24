//
//  MZFormSheetPresentationController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import "MZFormSheetPresentationController.h"
#import "UIViewController+TargetViewController.h"
#import "MZFormSheetPresentationControllerAnimator.h"

static NSMutableDictionary *_instanceOfTransitionClasses = nil;

@interface MZFormSheetPresentationController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;
@end

@implementation MZFormSheetPresentationController

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
        [appearance setMovementActionWhenKeyboardAppears:MZFormSheetActionWhenKeyboardAppearsDoNothing];
    }
}

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
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

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapGestureRecognizer:)];
    tapGesture.delegate = self;
    self.backgroundTapGestureRecognizer = tapGesture;

    [self.view addGestureRecognizer:tapGesture];

    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];

    [self setupFormSheetViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    MZFormSheetPresentationControllerTransitionHandler transitionCompletionHandler = ^(){
        
    };

    if (animated) {
        [self transitionEntryWithCompletionBlock:transitionCompletionHandler];
    } else {
        transitionCompletionHandler();
    }

}

#pragma mark - Transitions

- (void)transitionEntryWithCompletionBlock:(MZFormSheetPresentationControllerTransitionHandler)completionBlock
{
    Class transitionClass = [MZFormSheetPresentationController sharedTransitionClasses][@(self.transitionStyle)];

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
    Class transitionClass = [MZFormSheetPresentationController sharedTransitionClasses][@(self.transitionStyle)];

    if (transitionClass) {
        id <MZFormSheetControllerTransition> transition = [[transitionClass alloc] init];

        [transition exitFormSheetControllerTransition:self
                                    completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

#pragma mark - Setup

- (void)setupFormSheetViewController
{
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingNone;

    self.contentViewController.view.frame = CGRectMake(0, 0, self.contentViewSize.width, self.contentViewSize.height);
    self.contentViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

#pragma mark - UIGestureRecognizer

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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self setupFormSheetViewController];

    [self.contentViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
