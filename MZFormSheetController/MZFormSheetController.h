//
//  MZFormSheetController.h
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

#import <UIKit/UIKit.h>

extern CGFloat const MZFormSheetControllerDefaultAnimationDuration;

typedef NS_ENUM(NSInteger, MZFormSheetTransitionStyle) {
    MZFormSheetTransitionStyleSlideFromTop = 0,
    MZFormSheetTransitionStyleSlideFromBottom,
    MZFormSheetTransitionStyleFade,
    MZFormSheetTransitionStyleBounce,
    MZFormSheetTransitionStyleDropDown,
    MZFormSheetTransitionStyleCustom,
    MZFormSheetTransitionStyleNone,
};

/**
 Notifications are posted right after completion handlers
 
 @see willPresentCompletionHandler
 @see willDismissCompletionHandler
 @see didPresentCompletionHandler
 @see didDismissCompletionHandler
 */
extern NSString *const MZFormSheetWillPresentNotification;
extern NSString *const MZFormSheetWillDismissNotification;
extern NSString *const MZFormSheetDidPresentNotification;
extern NSString *const MZFormSheetDidDismissNotification;

@class MZFormSheetController;

typedef void(^MZFormSheetCompletionHandler)();
typedef void(^MZFormSheetBackgroundViewTapCompletionHandler)(CGPoint location);
typedef void(^MZFormSheetPresentationCompletionHandler)(MZFormSheetController *formSheetController);

@interface MZFormSheetController : UIViewController

/**
 The view controller that is presented by this form sheet controller
 */
@property (nonatomic, readonly, strong) UIViewController *presentedFSViewController;

/**
 The transition style to use when presenting the receiver
 By default, this is MZFormSheetTransitionStyleSlideFromTop
 */
@property (nonatomic, assign) MZFormSheetTransitionStyle transitionStyle;

/**
 The handler to call when presented form sheet is before entry transition and its view will show on window.
 */
@property (nonatomic, copy) MZFormSheetCompletionHandler willPresentCompletionHandler;

/**
 The handler to call when presented form sheet will be dismiss, this is called before out transition animation.
 */
@property (nonatomic, copy) MZFormSheetCompletionHandler willDismissCompletionHandler;

/**
 The handler to call when presented form sheet is after entry transition animation.
 */
@property (nonatomic, copy) MZFormSheetCompletionHandler didPresentCompletionHandler;

/**
 The handler to call when presented form sheet is after dismiss.
 */
@property (nonatomic, copy) MZFormSheetCompletionHandler didDismissCompletionHandler;

/**
 The handler to call when user tap on background view
 */
@property (nonatomic, copy) MZFormSheetBackgroundViewTapCompletionHandler didTapOnBackgroundViewCompletionHandler;

/**
 Distance that the presented form sheet view is inset from the status bar in landscape orientation.
 By default, this is 66.0
 */
@property (nonatomic, assign) CGFloat landscapeTopInset;

/**
 Distance that the presented form sheet view is inset from the status bar in portrait orientation.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat portraitTopInset;

/**
 The radius to use when drawing rounded corners for the layer’s presented form sheet view background.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 The blur radius (in points) used to render the layer’s shadow.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 The opacity of the layer’s shadow.
 By default, this is 0.5
 */
@property (nonatomic, assign) CGFloat shadowOpacity;

/**
 Size for presented form sheet controller
 By default, this is CGSizeMake(284.0,284.0)
 */
@property (nonatomic, assign) CGSize presentedFormSheetSize;

/**
 Returns whether the form sheet controller should dismiss after background view tap.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap;

/**
 Subclasses may override to add custom transition animation.
 You need to setup transitionStyle to MZFormSheetTransitionStyleCustom to call this method.
 When animation is finished you should must call super method or completionBlock to keep view life cycle.
 */
- (void)customTransitionEntryWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock;
- (void)customTransitionOutWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock;

/**
 Initializes and returns a newly created form sheet controller.
 
 @param presentedFormSheetViewController The view controller that is presented by form sheet controller.
 */
- (instancetype)initWithViewController:(UIViewController *)presentedFormSheetViewController;

/**
 Initializes and returns a newly created form sheet controller.
 
 @param formSheetSize The size, in points, for the form sheet controller.
 @param presentedFormSheetViewController The view controller that is presented by form sheet controller.
 */
- (instancetype)initWithSize:(CGSize)formSheetSize viewController:(UIViewController *)presentedFormSheetViewController;

/**
 Presents a form sheet controller.
 
 @param completionHandler A completion handler (didPresentCompletionHandler) or NULL.
 */
- (void)presentWithCompletionHandler:(MZFormSheetCompletionHandler)completionHandler;

/**
 Dismisses a form sheet controller.
 
 @param completionHandler A completion handler (didDismissCompletionHandler) or NULL.
 */
- (void)dismissWithCompletionHandler:(MZFormSheetCompletionHandler)completionHandler;

@end

/*
 Category on UIViewController to provide access to the formSheetController.
 */
@interface UIViewController (MZFormSheet)
@property(nonatomic, readonly) MZFormSheetController *formSheetController;

/**
 Presents a form sheet controller.
 
 @param viewController The view controller that is presented by form sheet controller.
 @param completionHandler A completion handler or NULL.
 */
- (void)presentFormSheetWithViewController:(UIViewController *)viewController completionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler;

/**
 Dismisses the form sheet controller that was presented by the receiver. If not find, last form sheet will be dismissed.
 
 @param completionHandler A completion handler (didDismissCompletionHandler) or NULL.
 */
- (void)dismissFormSheetControllerWithCompletionHandler:(MZFormSheetPresentationCompletionHandler)completionHandler;

@end
