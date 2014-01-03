//
//  MZFormSheetController.m
//  MZFormSheetController
//
//  Created by Michał Zaborowski on 08.08.2013.
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

#import "MZFormSheetController.h"
#import "NSInvocation+Copy.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NSString *const MZFormSheetDidPresentNotification = @"MZFormSheetDidPresentNotification";
NSString *const MZFormSheetDidDismissNotification = @"MZFormSheetDidDismissNotification";
NSString *const MZFormSheetWillPresentNotification = @"MZFormSheetWillPresentNotification";
NSString *const MZFormSheetWillDismissNotification = @"MZFormSheetWillDismissNotification";

CGFloat const MZFormSheetControllerDefaultPortraitTopInset = 66.0;
CGFloat const MZFormSheetControllerDefaultLandscapeTopInset = 6.0;
CGFloat const MZFormSheetControllerDefaultWidth = 284.0;
CGFloat const MZFormSheetControllerDefaultHeight = 284.0;

CGFloat const MZFormSheetControllerDefaultAnimationDuration = 0.3;

CGFloat const MZFormSheetPresentedControllerDefaultCornerRadius = 6.0;
CGFloat const MZFormSheetPresentedControllerDefaultShadowRadius = 6.0;
CGFloat const MZFormSheetPresentedControllerDefaultShadowOpacity = 0.5;

CGFloat const MZFormSheetControllerWindowTag = 10001;

static const char* MZFormSheetControllerAssociatedKey = "MZFormSheetControllerAssociatedKey";

static MZFormSheetBackgroundWindow *_instanceOfFormSheetBackgroundWindow = nil;
static NSMutableArray *_instanceOfSharedQueue = nil;
static BOOL _instanceOfFormSheetAnimating = NO;
static NSMutableDictionary *_instanceOfTransitionClasses = nil;

#pragma mark - UIViewController (MZParentTargetViewController)

@interface UIViewController (MZParentTargetViewController)
- (UIViewController *)mz_parentTargetViewController;
@end

#pragma mark - UIViewController (OBJC_ASSOCIATION)

@implementation UIViewController (OBJC_ASSOCIATION)

- (MZFormSheetController *)formSheetController
{
    return objc_getAssociatedObject(self, MZFormSheetControllerAssociatedKey);
}

- (void)setFormSheetController:(MZFormSheetController *)formSheetController
{
    objc_setAssociatedObject(self, MZFormSheetControllerAssociatedKey, formSheetController, OBJC_ASSOCIATION_ASSIGN);
}

@end

#pragma mark - MZFormSheetBackgroundWidnow (Show/Hide)

@implementation MZFormSheetBackgroundWindow (Show)

+ (void)showBackgroundWindowAnimated:(BOOL)animated
{    
    if ([MZFormSheetController sharedBackgroundWindow].isHidden) {

        // Hack: I set rootViewController to presentingViewController because
        // if View controller-based status bar appearance is YES and background window was hiding animated,
        // there was problem with preferredStatusBarStyle (half second always black status bar)
        _instanceOfFormSheetBackgroundWindow.rootViewController = [[[MZFormSheetController formSheetControllersStack] firstObject] presentingViewController];

        [_instanceOfFormSheetBackgroundWindow makeKeyAndVisible];

        _instanceOfFormSheetBackgroundWindow.alpha = 0;

        if (animated) {
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 _instanceOfFormSheetBackgroundWindow.alpha = 1;
                             }];
        } else {
            _instanceOfFormSheetBackgroundWindow.alpha = 1;
        }
    }

}

+ (void)hideBackgroundWindowAnimated:(BOOL)animated
{
    if (!animated) {
        [_instanceOfFormSheetBackgroundWindow removeFromSuperview];
        _instanceOfFormSheetBackgroundWindow = nil;
        return;
    }

    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                     animations:^{
                         _instanceOfFormSheetBackgroundWindow.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_instanceOfFormSheetBackgroundWindow removeFromSuperview];
                         _instanceOfFormSheetBackgroundWindow = nil;
                     }];
}

@end

#pragma mark - MZFormSheetWindow

@implementation MZFormSheetWindow

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

- (void)setTransparentTouchEnabled:(BOOL)transparentTouchEnabled
{
    if (_transparentTouchEnabled != transparentTouchEnabled) {
        _transparentTouchEnabled = transparentTouchEnabled;
        [MZFormSheetController sharedBackgroundWindow].userInteractionEnabled = !transparentTouchEnabled;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        id appearance = [[self class] appearance];
        [appearance applyInvocationTo:self];
    }
    return self;
}

- (CGPoint)convertPoint:(CGPoint)point toInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGSize windowSize = self.bounds.size;

    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return CGPointMake(windowSize.height-point.y, point.x);

    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return CGPointMake(point.y, windowSize.width-point.x);

    } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {

        return CGPointMake(windowSize.width-point.x, windowSize.height-point.y);
    }
    return point;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    UIInterfaceOrientation orientaion = [UIApplication sharedApplication].statusBarOrientation;
    CGPoint convertedPoint = [self convertPoint:point toInterfaceOrientation:orientaion];

    // UIView will be "transparent" for touch events if we return NO
    if (self.isTransparentTouchEnabled) {
        MZFormSheetController *formSheet = (MZFormSheetController *)self.rootViewController;
        if (!CGRectContainsPoint(formSheet.presentedFSViewController.view.frame, convertedPoint)){
            return NO;
        }
    }
    return YES;
}

@end

#pragma mark - MZFormSheetController

@interface MZFormSheetController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, strong) UIViewController *presentedFSViewController;

@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;

@property (nonatomic, weak) UIWindow *applicationKeyWindow;
@property (nonatomic, strong) MZFormSheetWindow *formSheetWindow;

@property (nonatomic, assign, getter = isPresented) BOOL presented;
@property (nonatomic, assign, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, strong) NSValue *screenFrameWhenKeyboardVisible;
@end

@implementation MZFormSheetController
@synthesize presentingViewController = _presentingViewController;

#pragma mark - Helpers

+ (CGFloat)statusBarHeight
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

+ (BOOL)isAutoLayoutAvailable
{
    if (NSClassFromString(@"NSLayoutConstraint")) {
        return YES;
    }
    return NO;
}

#pragma mark - Appearance

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

+ (void)load
{
    @autoreleasepool {
        MZFormSheetController *appearance = [self appearance];

        [appearance setPresentedFormSheetSize:CGSizeMake(MZFormSheetControllerDefaultWidth, MZFormSheetControllerDefaultHeight)];
        [appearance setCornerRadius:MZFormSheetPresentedControllerDefaultCornerRadius];
        [appearance setShadowOpacity:MZFormSheetPresentedControllerDefaultShadowOpacity];
        [appearance setShadowRadius:MZFormSheetPresentedControllerDefaultShadowRadius];
        [appearance setPortraitTopInset:MZFormSheetControllerDefaultPortraitTopInset];
        [appearance setLandscapeTopInset:MZFormSheetControllerDefaultLandscapeTopInset];
        [appearance setShouldMoveToTopWhenKeyboardAppears:YES];

        _instanceOfTransitionClasses = [[NSMutableDictionary alloc] init];
        _instanceOfSharedQueue = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Class methods

+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle
{
    [_instanceOfTransitionClasses setObject:transitionClass forKey:@(transitionStyle)];
}

+ (Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle
{
    return _instanceOfTransitionClasses[@(transitionStyle)];
}

+ (void)setAnimating:(BOOL)animating
{
    _instanceOfFormSheetAnimating = animating;
}

+ (BOOL)isAnimating
{
    return _instanceOfFormSheetAnimating;
}

+ (NSMutableArray *)sharedQueue
{
    return _instanceOfSharedQueue;
}

+ (NSArray *)formSheetControllersStack
{
    return [[MZFormSheetController sharedQueue] copy];
}

+ (MZFormSheetBackgroundWindow *)sharedBackgroundWindow
{
    if (!_instanceOfFormSheetBackgroundWindow) {
        _instanceOfFormSheetBackgroundWindow = [[MZFormSheetBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    return _instanceOfFormSheetBackgroundWindow;
}

#pragma mark - Setters

- (void)setPresentingViewController:(UIViewController *)presentingViewController
{
    if (_presentingViewController != presentingViewController) {
        _presentingViewController = presentingViewController;
    }
}

- (void)setPortraitTopInset:(CGFloat)portraitTopInset
{
    if (_portraitTopInset != portraitTopInset) {
        _portraitTopInset = portraitTopInset;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _portraitTopInset += [MZFormSheetController statusBarHeight];
        }
    }
}

- (void)setLandscapeTopInset:(CGFloat)landscapeTopInset
{
    if (_landscapeTopInset != landscapeTopInset) {
        _landscapeTopInset = landscapeTopInset;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _landscapeTopInset += [MZFormSheetController statusBarHeight];
        }
    }
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (_shadowOpacity != shadowOpacity) {
        _shadowOpacity = shadowOpacity;
        self.view.layer.shadowOpacity = _shadowOpacity;
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        self.view.layer.shadowRadius = _shadowRadius;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        self.presentedFSViewController.view.layer.cornerRadius = _cornerRadius;
    }
}

- (void)setPresentedFormSheetSize:(CGSize)presentedFormSheetSize
{
    if (!CGSizeEqualToSize(_presentedFormSheetSize, presentedFormSheetSize)) {
        _presentedFormSheetSize = presentedFormSheetSize;
        
        CGPoint presentedFormCenter = self.presentedFSViewController.view.center;
        self.presentedFSViewController.view.frame = CGRectMake(0, 0, _presentedFormSheetSize.width, _presentedFormSheetSize.height);
        self.presentedFSViewController.view.center = presentedFormCenter;
        
        // This will make sure that origin be in good position
        [self setupPresentedFSViewControllerFrame];
    }
}

#pragma mark - Getters

- (MZFormSheetWindow *)formSheetWindow
{
    if (!_formSheetWindow) {
        MZFormSheetWindow *window = [[MZFormSheetWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = [MZFormSheetController sharedBackgroundWindow].windowLevel + 1;
        window.tag = MZFormSheetControllerWindowTag;
        window.rootViewController = self;

        _formSheetWindow = window;
    }
    
    return _formSheetWindow;
}

- (BOOL)viewUsingAutolayout
{
    if (self.view.constraints.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - Public

- (instancetype)initWithViewController:(UIViewController *)presentedFormSheetViewController
{
    if (self = [super init]) {
        

        presentedFormSheetViewController.formSheetController = self;
        self.presentedFSViewController = presentedFormSheetViewController;

        // viewDidLoad is called
        
        id appearance = [[self class] appearance];
        [appearance applyInvocationRecursivelyTo:self upToSuperClass:[MZFormSheetController class]];
        
        [self setupFormSheetViewController];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)formSheetSize viewController:(UIViewController *)presentedFormSheetViewController
{
    if (self = [self initWithViewController:presentedFormSheetViewController]) {
        if (!CGSizeEqualToSize(formSheetSize, CGSizeZero)) {
            _presentedFormSheetSize = formSheetSize;
            [self setupFormSheetViewController];
        }
    }
    return self;
}

- (void)presentAnimated:(BOOL)animated completionHandler:(MZFormSheetCompletionHandler)completionHandler
{
    NSAssert(self.presentedFSViewController, @"MZFormSheetController must have at least one view controller.");
    NSAssert(![MZFormSheetController isAnimating], @"Attempting to begin a form sheet transition from to while a transition is already in progress. Wait for didPresentCompletionHandler/didDismissCompletionHandler to know the current transition has completed");

    if (self.isPresented){
        if (completionHandler) {
            completionHandler(self.presentedFSViewController);
        }
        return;
    }
    
    self.applicationKeyWindow = [UIApplication sharedApplication].keyWindow;

    if (!self.presentingViewController) {
        self.presentingViewController = [self.applicationKeyWindow.rootViewController mz_parentTargetViewController];
    }

    if (![[MZFormSheetController sharedQueue] containsObject:self]) {
        [[MZFormSheetController sharedQueue] addObject:self];
    }
    
    [MZFormSheetController setAnimating:YES];
    
    [MZFormSheetBackgroundWindow showBackgroundWindowAnimated:animated];
    
    [self.formSheetWindow makeKeyAndVisible];
    
    [self setupPresentedFSViewControllerFrame];
    
    if (self.willPresentCompletionHandler) {
        self.willPresentCompletionHandler(self.presentedFSViewController);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MZFormSheetWillPresentNotification object:self userInfo:nil];
    
    MZFormSheetTransitionCompletionHandler transitionCompletionHandler = ^(){
        [MZFormSheetController setAnimating:NO];

        self.presented = YES;
        
        [self.presentedFSViewController setFormSheetController:self];

        [self addKeyboardNotifications];
        
        self.formSheetWindow.hidden = NO;

        if (self.didPresentCompletionHandler) {
            self.didPresentCompletionHandler(self.presentedFSViewController);
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:MZFormSheetDidPresentNotification object:self userInfo:nil];
        
        if (completionHandler) {
            completionHandler(self.presentedFSViewController);
        }
    };

    if (animated) {
        [self transitionEntryWithCompletionBlock:transitionCompletionHandler];
    } else {
        transitionCompletionHandler();
    }
    
}

- (void)dismissAnimated:(BOOL)animated completionHandler:(MZFormSheetCompletionHandler)completionHandler
{
    if (self.willDismissCompletionHandler) {
        self.willDismissCompletionHandler(self.presentedFSViewController);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MZFormSheetWillDismissNotification object:self userInfo:nil];
    
    [MZFormSheetController setAnimating:YES];
    
    [[MZFormSheetController sharedQueue] removeObject:self];
    
    if ([MZFormSheetController sharedQueue].count == 0) {
        [MZFormSheetBackgroundWindow hideBackgroundWindowAnimated:animated];
    }

    [self removeKeyboardNotifications];

    MZFormSheetTransitionCompletionHandler transitionCompletionHandler = ^(){
        [MZFormSheetController setAnimating:NO];
        self.presented = NO;

        if (self.didDismissCompletionHandler) {
            self.didDismissCompletionHandler(self.presentedFSViewController);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:MZFormSheetDidDismissNotification object:self userInfo:nil];
        
        if (completionHandler) {
            completionHandler(self.presentedFSViewController);
        }
        [self cleanup];
    };
    
    if (animated) {
        [self transitionOutWithCompletionBlock:transitionCompletionHandler];
    } else {
        transitionCompletionHandler();
    }

    [self.applicationKeyWindow makeKeyWindow];
    self.applicationKeyWindow.hidden = NO;
}

#pragma mark - Transitions

- (void)customTransitionEntryWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock {}
- (void)customTransitionOutWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock {}

- (void)transitionEntryWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    Class class = _instanceOfTransitionClasses[@(self.transitionStyle)];

    if (class) {
        id <MZFormSheetControllerTransition> transition = [[class alloc] init];

        [transition entryFormSheetControllerTransition:self
                                     completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)transitionOutWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    Class class = _instanceOfTransitionClasses[@(self.transitionStyle)];

    if (class) {
        id <MZFormSheetControllerTransition> transition = [[class alloc] init];

        [transition exitFormSheetControllerTransition:self
                                     completionHandler:completionBlock];
    } else {
        completionBlock();
    }
}

- (void)resetTransition
{
    [self.presentedFSViewController.view.layer removeAllAnimations];
}

/////////////////////////////////////////////////////////////////////////////

#pragma mark - Setup

- (void)setupFormSheetViewController
{
    self.presentedFSViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if ([MZFormSheetController isAutoLayoutAvailable]) {
        self.view.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    self.presentedFSViewController.view.frame = CGRectMake(0, 0, self.presentedFormSheetSize.width, self.presentedFormSheetSize.height);
    self.presentedFSViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), self.presentedFSViewController.view.center.y);
    self.presentedFSViewController.view.layer.cornerRadius = self.cornerRadius;
    self.presentedFSViewController.view.layer.masksToBounds = YES;

    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowRadius = self.shadowRadius;
    self.view.layer.shadowOpacity = self.shadowOpacity;
    self.view.frame = self.presentedFSViewController.view.frame;
}

- (void)setupPresentedFSViewControllerFrame
{
    if (self.keyboardVisible) {
        CGRect formSheetRect = self.presentedFSViewController.view.frame;
        CGRect screenRect = [self.screenFrameWhenKeyboardVisible CGRectValue];

        if (screenRect.size.height > formSheetRect.size.height) {
            if (self.shouldCenterVerticallyWhenKeyboardAppears) {
                formSheetRect.origin.y = ([MZFormSheetController statusBarHeight] + screenRect.size.height - formSheetRect.size.height)/2 - screenRect.origin.y;
            } else if (self.shouldMoveToTopWhenKeyboardAppears) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    formSheetRect.origin.y = [MZFormSheetController statusBarHeight];
                } else {
                    formSheetRect.origin.y = 0;
                }
            }
        } else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                formSheetRect.origin.y = [MZFormSheetController statusBarHeight];
            } else {
                formSheetRect.origin.y = 0;
            }
        }

        self.presentedFSViewController.view.frame = formSheetRect;
 
    } else if (self.shouldCenterVertically) {
        self.presentedFSViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    } else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        self.presentedFSViewController.view.frame = CGRectMake(self.presentedFSViewController.view.frame.origin.x, self.portraitTopInset, self.presentedFSViewController.view.frame.size.width, self.presentedFSViewController.view.frame.size.height);
    } else {
        self.presentedFSViewController.view.frame = CGRectMake(self.presentedFSViewController.view.frame.origin.x, self.landscapeTopInset, self.presentedFSViewController.view.frame.size.width, self.presentedFSViewController.view.frame.size.height);
    }
}

#pragma mark - UIGestureRecognizers

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
    if (tapGesture.state == UIGestureRecognizerStateEnded && [MZFormSheetController sharedQueue].count > 0){
        CGPoint location = [tapGesture locationInView:[tapGesture.view superview]];
        if (self.didTapOnBackgroundViewCompletionHandler) {
            self.didTapOnBackgroundViewCompletionHandler(location);
        }
        if (self.shouldDismissOnBackgroundViewTap) {
            [self dismissAnimated:YES completionHandler:nil];
        }
    }
}

#pragma mark - UIKeyboard Notifications

- (void)willShowKeyboardNotification:(NSNotification *)notification
{
    CGRect screenRect = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenRect.size.height = [UIScreen mainScreen].bounds.size.width - screenRect.size.width;
        screenRect.size.width = [UIScreen mainScreen].bounds.size.height;
    } else {
        screenRect.size.height = [UIScreen mainScreen].bounds.size.height - screenRect.size.height;
        screenRect.size.width = [UIScreen mainScreen].bounds.size.width;
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        screenRect.origin.y = 0;
    } else {
        screenRect.origin.y = [MZFormSheetController statusBarHeight];
    }

    self.screenFrameWhenKeyboardVisible = [NSValue valueWithCGRect:screenRect];
    self.keyboardVisible = YES;

    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration animations:^{
        [self setupPresentedFSViewControllerFrame];
    }];
    
}

- (void)willHideKeyboardNotification:(NSNotification *)notification
{
    self.keyboardVisible = NO;
    self.screenFrameWhenKeyboardVisible = nil;
    
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration animations:^{
        [self setupPresentedFSViewControllerFrame];
    }];

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

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapGestureRecognizer:)];
    tapGesture.delegate = self;
    self.backgroundTapGestureRecognizer = tapGesture;
    
    [self.formSheetWindow addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.presentedFSViewController.view];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Fix navigation bar height (minibar for landscape) when view controller will rotate (AutoLayout)
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]] && [MZFormSheetController isAutoLayoutAvailable] && [self viewUsingAutolayout]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        [navigationController.navigationBar sizeToFit];
    }

    [self setupPresentedFSViewControllerFrame];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self resetTransition];
    
    // Fix navigation bar height (minibar for landscape) when view controller will rotate (non-AutoLayout)
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        if (!([MZFormSheetController isAutoLayoutAvailable] && [self viewUsingAutolayout])) {
            UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
            [navigationController.navigationBar performSelector:@selector(sizeToFit) withObject:nil afterDelay:(0.5f * duration)];
        }
    }
    
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return navigationController.topViewController;
    }

    return self.presentedFSViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return navigationController.topViewController;
    }
    return self.presentedFSViewController;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.presentedFSViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return [navigationController.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return [self.presentedFSViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [self.presentedFSViewController shouldAutorotate];
}

- (void)cleanup
{

    self.presentedFSViewController.formSheetController = nil;
    self.presentingViewController.formSheetController = nil;
    
    [self.presentedFSViewController.view removeFromSuperview];
    self.presentedFSViewController = nil;

    [self.formSheetWindow removeGestureRecognizer:self.backgroundTapGestureRecognizer];
    self.formSheetWindow.hidden = YES;

    self.formSheetWindow.rootViewController = nil;
    [self.formSheetWindow removeFromSuperview];
    self.formSheetWindow = nil;

    self.backgroundTapGestureRecognizer = nil;

    [self removeKeyboardNotifications];
}

@end

#pragma mark - UIViewController (MZFormSheet)

@implementation UIViewController (MZFormSheet)
@dynamic formSheetController;

#pragma mark - Public

- (void)mz_presentFormSheetController:(MZFormSheetController *)formSheetController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    self.formSheetController = formSheetController;
    formSheetController.presentingViewController = self;

    [formSheetController presentAnimated:animated completionHandler:^(UIViewController *presentedFSViewController){
        if (completionHandler) {
            completionHandler(formSheetController);
        }
    }];
}

- (void)presentFormSheetController:(MZFormSheetController *)formSheetController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self mz_presentFormSheetController:formSheetController animated:animated completionHandler:completionHandler];
}

- (void)mz_presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated transitionStyle:(MZFormSheetTransitionStyle)transitionStyle completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    MZFormSheetController *formSheetController = [[MZFormSheetController alloc] initWithViewController:viewController];
    formSheetController.transitionStyle = transitionStyle;

    self.formSheetController = formSheetController;
    formSheetController.presentingViewController = self;

    [formSheetController presentAnimated:animated completionHandler:^(UIViewController *presentedFSViewController){
        if (completionHandler) {
            completionHandler(formSheetController);
        }
    }];
}

- (void)presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated transitionStyle:(MZFormSheetTransitionStyle)transitionStyle completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self mz_presentFormSheetWithViewController:viewController animated:animated transitionStyle:transitionStyle completionHandler:completionHandler];
}

- (void)mz_presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self mz_presentFormSheetWithViewController:viewController animated:animated transitionStyle:MZFormSheetTransitionStyleSlideFromTop completionHandler:completionHandler];
}

- (void)presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self mz_presentFormSheetWithViewController:viewController animated:animated completionHandler:completionHandler];
}

- (void)mz_dismissFormSheetControllerAnimated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    MZFormSheetController *formSheetController = nil;

    if (self.formSheetController) {
        formSheetController = self.formSheetController;
    } else {
        formSheetController = [[MZFormSheetController sharedQueue] lastObject];
    }

    [formSheetController dismissAnimated:animated completionHandler:^(UIViewController *presentedFSViewController) {
        if (completionHandler) {
            completionHandler(formSheetController);
        }
    }];
}

- (void)dismissFormSheetControllerAnimated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self mz_dismissFormSheetControllerAnimated:animated completionHandler:completionHandler];
}

@end

@implementation UIViewController (MZParentTargetViewController)

- (UIViewController *)mz_parentTargetViewController
{
    UIViewController *target = self;
    while (target.parentViewController) {
        target = target.parentViewController;
    }
    return target;
}

@end
