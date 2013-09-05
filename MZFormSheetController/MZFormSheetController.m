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
CGFloat const MZFormSheetControllerDefaultTransitionBounceDuration = 0.4;
CGFloat const MZFormSheetControllerDefaultTransitionDropDownDuration = 0.4;

CGFloat const MZFormSheetPresentedControllerDefaultCornerRadius = 6.0;
CGFloat const MZFormSheetPresentedControllerDefaultShadowRadius = 6.0;
CGFloat const MZFormSheetPresentedControllerDefaultShadowOpacity = 0.5;

UIWindowLevel const UIWindowLevelFormSheet = 3;
CGFloat const MZFormSheetControllerWindowTag = 10001;

static const char* MZFormSheetControllerAssociatedKey = "MZFormSheetControllerAssociatedKey";

@class MZFormSheetBackgroundWindow;

static MZFormSheetBackgroundWindow *instanceOfFormSheetBackgroundWindow = nil;
static NSMutableArray *instanceOfSharedQueue = nil;
static BOOL instanceOfFormSheetAnimating = 0;

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
        [instanceOfFormSheetBackgroundWindow makeKeyAndVisible];

        instanceOfFormSheetBackgroundWindow.alpha = 0;

        if (animated) {
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 instanceOfFormSheetBackgroundWindow.alpha = 1;
                             }];
        } else {
            instanceOfFormSheetBackgroundWindow.alpha = 1;
        }
    }

}

+ (void)hideBackgroundWindowAnimated:(BOOL)animated
{
    if (!animated) {
        [instanceOfFormSheetBackgroundWindow removeFromSuperview];
        instanceOfFormSheetBackgroundWindow = nil;
        return;
    }
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                     animations:^{
                         instanceOfFormSheetBackgroundWindow.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [instanceOfFormSheetBackgroundWindow removeFromSuperview];
                         instanceOfFormSheetBackgroundWindow = nil;
                     }];
}

@end

#pragma mark - MZFormSheetController

@interface MZFormSheetController () <UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIViewController *presentingViewController;
@property (nonatomic, strong) UIViewController *presentedFSViewController;

@property (nonatomic, strong) UITapGestureRecognizer *backgroundTapGestureRecognizer;

@property (nonatomic, weak) UIWindow *applicationKeyWindow;
@property (nonatomic, strong) UIWindow *formSheetWindow;

@property (nonatomic, assign, getter = isPresented) BOOL presented;
@property (nonatomic, assign, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, strong) NSValue *screenFrame;
@end

@implementation MZFormSheetController
@synthesize presentingViewController = _presentingViewController;

#pragma mark - Class methods

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

+ (void)load
{
    @autoreleasepool {
        id appearance = [self appearance];
        
        [appearance setPresentedFormSheetSize:CGSizeMake(MZFormSheetControllerDefaultWidth, MZFormSheetControllerDefaultHeight)];
        [appearance setCornerRadius:MZFormSheetPresentedControllerDefaultCornerRadius];
        [appearance setShadowOpacity:MZFormSheetPresentedControllerDefaultShadowOpacity];
        [appearance setShadowRadius:MZFormSheetPresentedControllerDefaultShadowRadius];
        [appearance setPortraitTopInset:MZFormSheetControllerDefaultPortraitTopInset];
        [appearance setLandscapeTopInset:MZFormSheetControllerDefaultLandscapeTopInset];
        [appearance setShouldMoveToTopWhenKeyboardAppears:YES];
    }
}

+ (BOOL)isAutoLayoutAvailable
{
    if (NSClassFromString(@"NSLayoutConstraint")) {
        return YES;
    }
    return NO;
}

+ (void)setAnimating:(BOOL)animating
{
    instanceOfFormSheetAnimating = animating;
}

+ (BOOL)isAnimating
{
    return instanceOfFormSheetAnimating;
}

+ (NSArray *)formSheetControllersStack
{
    return [instanceOfSharedQueue copy];
}

+ (MZFormSheetBackgroundWindow *)sharedBackgroundWindow
{
    if (!instanceOfFormSheetBackgroundWindow) {
        instanceOfFormSheetBackgroundWindow = [[MZFormSheetBackgroundWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    return instanceOfFormSheetBackgroundWindow;
}


+ (NSMutableArray *)sharedQueue
{
    if (!instanceOfSharedQueue) {
        instanceOfSharedQueue = [NSMutableArray array];
    }
    return instanceOfSharedQueue;
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
            _portraitTopInset += [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }
}

- (void)setLandscapeTopInset:(CGFloat)landscapeTopInset
{
    if (_landscapeTopInset != landscapeTopInset) {
        _landscapeTopInset = landscapeTopInset;

        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _landscapeTopInset += [UIApplication sharedApplication].statusBarFrame.size.height;
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

- (UIWindow *)formSheetWindow
{
    if (!_formSheetWindow) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelFormSheet;
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
        
        // viewDidLoad is called
        self.presentedFSViewController = presentedFormSheetViewController;
        
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

    if (self.presented){
        if (completionHandler) {
            completionHandler(self.presentedFSViewController);
        }
        return;
    }
    
    self.applicationKeyWindow = [UIApplication sharedApplication].keyWindow;
    
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

//  Created by Kevin Cao on 13/4/29.
//  Copyright (c) 2013 Sumi Interactive
//  Modified by Michał Zaborowski.
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

#pragma mark - Transitions

- (void)transitionEntryWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    switch (self.transitionStyle) {
        case MZFormSheetTransitionStyleSlideFromTop:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            CGRect originalFormSheetRect = formSheetRect;
            formSheetRect.origin.y = -formSheetRect.size.height;
            self.presentedFSViewController.view.frame = formSheetRect;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = originalFormSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideFromBottom:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            CGRect originalFormSheetRect = formSheetRect;
            formSheetRect.origin.y = self.view.bounds.size.height;
            self.presentedFSViewController.view.frame = formSheetRect;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = originalFormSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideFromRight:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            CGRect originalFormSheetRect = formSheetRect;
            formSheetRect.origin.x = self.view.bounds.size.width;
            self.presentedFSViewController.view.frame = formSheetRect;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = originalFormSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideFromLeft:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            CGRect originalFormSheetRect = formSheetRect;
            formSheetRect.origin.x = -self.view.bounds.size.width;
            self.presentedFSViewController.view.frame = formSheetRect;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = originalFormSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideAndBounceFromLeft:
        {
            CGFloat x = self.presentedFSViewController.view.center.x;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
            animation.values = @[@(x - self.view.bounds.size.width), @(x + 20), @(x - 10), @(x)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = MZFormSheetControllerDefaultTransitionDropDownDuration;
            animation.delegate = self;
            [animation setValue:completionBlock forKey:@"completionHandler"];
            [self.presentedFSViewController.view.layer addAnimation:animation forKey:@"bounceLeft"];
        }break;
            
        case MZFormSheetTransitionStyleSlideAndBounceFromRight:
        {
            CGFloat x = self.presentedFSViewController.view.center.x;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
            animation.values = @[@(x + self.view.bounds.size.width), @(x - 20), @(x + 10), @(x)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = MZFormSheetControllerDefaultTransitionDropDownDuration;
            animation.delegate = self;
            [animation setValue:completionBlock forKey:@"completionHandler"];
            [self.presentedFSViewController.view.layer addAnimation:animation forKey:@"bounceRight"];
        }break;
            
        case MZFormSheetTransitionStyleFade:
        {
            self.presentedFSViewController.view.alpha = 0;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleBounce:
        {
            CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            bounceAnimation.fillMode = kCAFillModeBoth;
            bounceAnimation.duration = MZFormSheetControllerDefaultTransitionBounceDuration;
            bounceAnimation.values = @[
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 0.01f)],
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.1f)],
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 0.9f)],
                                       [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            bounceAnimation.keyTimes = @[@0.0f, @0.5f, @0.75f, @1.0f];
            bounceAnimation.timingFunctions = @[
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            bounceAnimation.delegate = self;
            [bounceAnimation setValue:completionBlock forKey:@"completionHandler"];
            [self.presentedFSViewController.view.layer addAnimation:bounceAnimation forKey:@"bounce"];
        }break;
            
        case MZFormSheetTransitionStyleDropDown:
        {
            CGFloat y = self.presentedFSViewController.view.center.y;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@(y - self.view.bounds.size.height), @(y + 20), @(y - 10), @(y)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = MZFormSheetControllerDefaultTransitionDropDownDuration;
            animation.delegate = self;
            [animation setValue:completionBlock forKey:@"completionHandler"];
            [self.presentedFSViewController.view.layer addAnimation:animation forKey:@"dropdown"];
        }break;
            
        case MZFormSheetTransitionStyleCustom:
        {
            [self customTransitionEntryWithCompletionBlock:completionBlock];
            
        }break;
            
        case MZFormSheetTransitionStyleNone:
        default:{
            if (completionBlock) {
                completionBlock();
            }
        }break;
    }
}

- (void)transitionOutWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    switch (self.transitionStyle) {
        case MZFormSheetTransitionStyleSlideFromTop:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            formSheetRect.origin.y = -self.view.bounds.size.height;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = formSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideFromBottom:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            formSheetRect.origin.y = self.view.bounds.size.height;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.presentedFSViewController.view.frame = formSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideAndBounceFromRight:
        case MZFormSheetTransitionStyleSlideFromRight:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            formSheetRect.origin.x = self.view.bounds.size.width;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = formSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleSlideAndBounceFromLeft:
        case MZFormSheetTransitionStyleSlideFromLeft:
        {
            CGRect formSheetRect = self.presentedFSViewController.view.frame;
            formSheetRect.origin.x = -self.view.bounds.size.width;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.frame = formSheetRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleFade:
        {
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                             animations:^{
                                 self.presentedFSViewController.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleBounce:
        {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@(1), @(1.2), @(0.01)];
            animation.keyTimes = @[@(0), @(0.4), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = MZFormSheetControllerDefaultAnimationDuration;
            animation.delegate = self;
            [animation setValue:completionBlock forKey:@"completionHandler"];
            [self.presentedFSViewController.view.layer addAnimation:animation forKey:@"bounce"];
            
            self.presentedFSViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }break;
            
        case MZFormSheetTransitionStyleDropDown:
        {
            CGPoint point = self.presentedFSViewController.view.center;
            point.y += self.view.bounds.size.height;
            [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.presentedFSViewController.view.center = point;
                                 CGFloat angle = ((CGFloat)arc4random_uniform(100) - 50.f) / 100.f;
                                 self.presentedFSViewController.view.transform = CGAffineTransformMakeRotation(angle);
                             }
                             completion:^(BOOL finished) {
                                 if (completionBlock) {
                                     completionBlock();
                                 }
                             }];
        }break;
            
        case MZFormSheetTransitionStyleCustom:
        {
            [self customTransitionOutWithCompletionBlock:completionBlock];
            
        }break;
            
        case MZFormSheetTransitionStyleNone:
        default:{
            if (completionBlock) {
                completionBlock();
            }
        }break;
    }
}

- (void)customTransitionEntryWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    if (completionBlock) {
        completionBlock();
    }
}
- (void)customTransitionOutWithCompletionBlock:(MZFormSheetTransitionCompletionHandler)completionBlock
{
    if (completionBlock) {
        completionBlock();
    }
}

- (void)resetTransition
{
    [self.presentedFSViewController.view.layer removeAllAnimations];
}

#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^completionHandler)(void) = [anim valueForKey:@"completionHandler"];
    if (completionHandler) {
        completionHandler();
    }
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
        CGRect screenRect = [self.screenFrame CGRectValue];

        if (screenRect.size.height > formSheetRect.size.height) {
            if (self.centerFormSheetVerticallyWhenKeyboardAppears) {
                formSheetRect.origin.y = ([UIApplication sharedApplication].statusBarFrame.size.height + screenRect.size.height - formSheetRect.size.height)/2 - screenRect.origin.y;
            }
        } else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                formSheetRect.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
            } else {
                formSheetRect.origin.y = 0;
            }
        }

        self.presentedFSViewController.view.frame = formSheetRect;
 
    } else if (self.centerFormSheetVertically) {
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
        screenRect.origin.y = [UIApplication sharedApplication].statusBarFrame.size.height;
    }

    self.screenFrame = [NSValue valueWithCGRect:screenRect];
    self.keyboardVisible = YES;

    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration animations:^{
        [self setupPresentedFSViewControllerFrame];
    }];
    
}

- (void)willHideKeyboardNotification:(NSNotification *)notification
{
    self.keyboardVisible = NO;
    self.screenFrame = nil;
    
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)cleanup
{
    [self.presentedFSViewController.view removeFromSuperview];
    self.presentedFSViewController = nil;
    
    [self.formSheetWindow removeGestureRecognizer:self.backgroundTapGestureRecognizer];
    
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

- (void)presentFormSheetController:(MZFormSheetController *)formSheetController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
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

- (void)presentFormSheetWithViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
{
    [self presentFormSheetWithViewController:viewController animated:animated transitionStyle:MZFormSheetTransitionStyleSlideFromTop completionHandler:completionHandler];
}


- (void)dismissFormSheetControllerAnimated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler
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

@end
