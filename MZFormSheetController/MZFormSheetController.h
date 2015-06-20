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
#import <MZAppearance/MZAppearance.h>
#import "MZFormSheetBackgroundWindow.h"
#import "MZFormSheetTransition.h"
#import "MZMacro.h"

extern CGFloat const MZFormSheetControllerDefaultAnimationDuration;
extern CGFloat const MZFormSheetControllerWindowTag;


typedef NS_ENUM(NSInteger, MZFormSheetWhenKeyboardAppears) {
  MZFormSheetWhenKeyboardAppearsDoNothing = 0,
  MZFormSheetWhenKeyboardAppearsCenterVertically,
  MZFormSheetWhenKeyboardAppearsMoveToTop,
  MZFormSheetWhenKeyboardAppearsMoveToTopInset,
  MZFormSheetWhenKeyboardAppearsMoveAboveKeyboard
};

/**
 Notifications are posted right after completion handlers
 
 @see willPresentCompletionHandler
 @see willDismissCompletionHandler
 @see didPresentCompletionHandler
 @see didDismissCompletionHandler
 */
extern NSString *const __nonnull MZFormSheetWillPresentNotification;
extern NSString *const __nonnull MZFormSheetWillDismissNotification;
extern NSString *const __nonnull MZFormSheetDidPresentNotification;
extern NSString *const __nonnull MZFormSheetDidDismissNotification;

@class MZFormSheetController;

typedef void(^MZFormSheetCompletionHandler)(UIViewController * __nonnull presentedFSViewController);
typedef void(^MZFormSheetBackgroundViewTapCompletionHandler)(CGPoint location);
typedef void(^MZFormSheetPresentationCompletionHandler)(MZFormSheetController * __nonnull formSheetController);
typedef void(^MZFormSheetTransitionCompletionHandler)();

@interface MZFormSheetWindow : UIWindow <MZAppearance>

/**
 Returns whether the window should be touch transparent.
 If transparent is set to YES, window will not recive touch and didTapOnBackgroundViewCompletionHandler will not be called.
 Also will not be possible to dismiss form sheet on background tap.
 By default, this is NO.
 */
@property (nonatomic, assign, getter = isTransparentTouchEnabled) BOOL transparentTouchEnabled MZ_APPEARANCE_SELECTOR;
@end

@interface MZFormSheetController : UIViewController <MZAppearance>
/**
 *  Register custom transition animation style.
 *  You need to setup transitionStyle to MZFormSheetTransitionStyleCustom.
 *
 *  @param transitionClass Custom transition class.
 *  @param transitionStyle The transition style to use when presenting the receiver.
 */
+ (void)registerTransitionClass:(nonnull Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

+ (nullable Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

/**
 Returns the background window that is displayed below form sheet controller.
 */
+ (nonnull MZFormSheetBackgroundWindow *)sharedBackgroundWindow;

/**
 Returns copy of formSheetController stack, last object in array (form sheet controller) is on top.
 */
+ (nonnull NSArray *)formSheetControllersStack;

/**
 Returns the window that form sheet controller is displayed .
 */
@property (nonatomic, readonly, strong, null_resettable) MZFormSheetWindow *formSheetWindow;

/**
 The view controller that is presented by this form sheet controller.
 MZFormSheetController (self) --> presentedFSViewController
 */
@property (nonatomic, readonly, strong, nullable) UIViewController *presentedFSViewController;

/**
 The view controller that is presenting this form sheet controller.
 This is only set up if you use UIViewController (MZFormSheet) category to present form sheet controller.
 presentingFSViewController --> MZFormSheetController (self) --> presentedFSViewController
 */
@property (nonatomic, readonly, weak, nullable) UIViewController *presentingFSViewController;

/**
 The transition style to use when presenting the receiver.
 By default, this is MZFormSheetTransitionStyleSlideFromTop.
 */
@property (nonatomic, assign) MZFormSheetTransitionStyle transitionStyle MZ_APPEARANCE_SELECTOR;

/**
 The handler to call when presented form sheet is before entry transition and its view will show on window.
 */
@property (nonatomic, copy, nullable) MZFormSheetCompletionHandler willPresentCompletionHandler;

/**
 The handler to call when presented form sheet will be dismiss, this is called before out transition animation.
 */
@property (nonatomic, copy, nullable) MZFormSheetCompletionHandler willDismissCompletionHandler;

/**
 The handler to call when presented form sheet is after entry transition animation.
 */
@property (nonatomic, copy, nullable) MZFormSheetCompletionHandler didPresentCompletionHandler;

/**
 The handler to call when presented form sheet is after dismiss.
 */
@property (nonatomic, copy, nullable) MZFormSheetCompletionHandler didDismissCompletionHandler;

/**
 The handler to call when user tap on background view.
 */
@property (nonatomic, copy, nullable) MZFormSheetBackgroundViewTapCompletionHandler didTapOnBackgroundViewCompletionHandler;

/**
 Distance that the presented form sheet view is inset from the status bar in landscape orientation.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat landscapeTopInset MZ_APPEARANCE_SELECTOR;

/**
 Distance that the presented form sheet view is inset from the status bar in portrait orientation.
 By default, this is 66.0
 */
@property (nonatomic, assign) CGFloat portraitTopInset MZ_APPEARANCE_SELECTOR;

/**
 The radius to use when drawing rounded corners for the layer’s presented form sheet view background.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat cornerRadius MZ_APPEARANCE_SELECTOR;

/**
 The blur radius (in points) used to render the layer’s shadow.
 By default, this is 6.0
 */
@property (nonatomic, assign) CGFloat shadowRadius MZ_APPEARANCE_SELECTOR;

/**
 The opacity of the layer’s shadow.
 By default, this is 0.5
 */
@property (nonatomic, assign) CGFloat shadowOpacity MZ_APPEARANCE_SELECTOR;

/**
 Size for presented form sheet controller
 By default, this is CGSizeMake(284.0,284.0)
 */
@property (nonatomic, assign) CGSize presentedFormSheetSize MZ_APPEARANCE_SELECTOR;

/**
 Center form sheet vertically.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldCenterVertically MZ_APPEARANCE_SELECTOR;

/**
 Returns whether the form sheet controller should dismiss after background view tap.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap MZ_APPEARANCE_SELECTOR;

/**
 The movement style to use when the keyboard appears.
 By default, this is MZFormSheetWhenKeyboardAppearsMoveToTop.
 */
@property (nonatomic, assign) MZFormSheetWhenKeyboardAppears movementWhenKeyboardAppears MZ_APPEARANCE_SELECTOR;

/**
 Initializes and returns a newly created form sheet controller.
 
 @param presentedFormSheetViewController The view controller that is presented by form sheet controller.
 */
- (nonnull instancetype)initWithViewController:(UIViewController * __nonnull )presentedFormSheetViewController;

/**
 Initializes and returns a newly created form sheet controller.
 
 @param formSheetSize The size, in points, for the form sheet controller.
 @param presentedFormSheetViewController The view controller that is presented by form sheet controller.
 */
- (nonnull instancetype)initWithSize:(CGSize)formSheetSize viewController:(UIViewController * __nonnull )presentedFormSheetViewController;

/**
 Presents a form sheet controller.
 
 @param animated Pass YES to animate the transition.
 @param completionHandler A completion handler (didPresentCompletionHandler) or NULL.
 */
- (void)presentAnimated:(BOOL)animated completionHandler:(MZFormSheetCompletionHandler __nullable)completionHandler;

/**
 Dismisses a form sheet controller.
 
 @param animated Pass YES to animate the transition.
 @param completionHandler A completion handler (didDismissCompletionHandler) or NULL.
 */
- (void)dismissAnimated:(BOOL)animated completionHandler:(MZFormSheetCompletionHandler __nullable)completionHandler;

@end

/**
 Category on UIViewController to provide access to the formSheetController.
 */
@interface UIViewController (MZFormSheet)
@property (nonatomic, readonly, nullable) MZFormSheetController *formSheetController;

/**
 Presents a form sheet cotnroller
 @param formSheetController The form sheet controller or a subclass of MZFormSheetController.
 @param completionHandler A completion handler or NULL.
 */
- (void)mz_presentFormSheetController:(MZFormSheetController * __nonnull )formSheetController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler __nullable)completionHandler;

/**
 Creates a new form sheet controller and presents it.
 
 @param viewController The view controller that is presented by form sheet controller.
 @param transitionStyle he transition style to use when presenting the receiver.
 @param completionHandler A completion handler or NULL.
 */
- (void)mz_presentFormSheetWithViewController:(UIViewController * __nonnull )viewController animated:(BOOL)animated transitionStyle:(MZFormSheetTransitionStyle)transitionStyle completionHandler:(MZFormSheetPresentationCompletionHandler __nullable)completionHandler;

- (void)mz_presentFormSheetWithViewController:(UIViewController * __nonnull )viewController animated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler __nullable)completionHandler;

/**
 Dismisses the form sheet controller that was presented by the receiver. If not find, last form sheet will be dismissed.
 @param animated Pass YES to animate the transition.
 @param completionHandler A completion handler (didDismissCompletionHandler) or NULL.
 */
- (void)mz_dismissFormSheetControllerAnimated:(BOOL)animated completionHandler:(MZFormSheetPresentationCompletionHandler __nullable)completionHandler;

@end
