//
//  MZFormSheetPresentationController.h
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

#import <UIKit/UIKit.h>
#import "MZTransition.h"
#import "MZAppearance.h"

extern CGFloat const MZFormSheetPresentationControllerDefaultAnimationDuration;

typedef NS_ENUM(NSInteger, MZFormSheetActionWhenKeyboardAppears) {
    MZFormSheetActionWhenKeyboardAppearsDoNothing = 0,
    MZFormSheetActionWhenKeyboardAppearsCenterVertically,
    MZFormSheetActionWhenKeyboardAppearsMoveToTop,
    MZFormSheetActionWhenKeyboardAppearsMoveToTopInset,
};

typedef void(^MZFormSheetPresentationControllerCompletionHandler)(UIViewController *contentViewController);
typedef void(^MZFormSheetPresentationControllerTapHandler)(CGPoint location);
typedef void(^MZFormSheetPresentationControllerTransitionHandler)();

NS_CLASS_AVAILABLE_IOS(8_0) @interface MZFormSheetPresentationController : UIViewController <MZAppearance, UIViewControllerTransitioningDelegate>

/**
 *  Register custom transition animation style.
 *  You need to setup transitionStyle to MZFormSheetTransitionStyleCustom.
 *
 *  @param transitionClass Custom transition class.
 *  @param transitionStyle The transition style to use when presenting the receiver.
 */
+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

+ (Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;
/**
 *  The view controller responsible for the content portion of the popup.
 */
@property (nonatomic, readonly, strong) UIViewController *contentViewController;

@property (nonatomic, assign) CGSize contentViewSize MZ_APPEARANCE_SELECTOR;

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
 Returns whether the form sheet controller should dismiss after background view tap.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap MZ_APPEARANCE_SELECTOR;

/**
 Center form sheet vertically.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldCenterVertically MZ_APPEARANCE_SELECTOR;

/**
 The transition style to use when presenting the receiver.
 By default, this is MZFormSheetTransitionStyleSlideFromTop.
 */
@property (nonatomic, assign) MZFormSheetTransitionStyle contentViewControllerTransitionStyle MZ_APPEARANCE_SELECTOR;

/**
 The movement action to use when the keyboard appears.
 By default, this is MZFormSheetActionWhenKeyboardAppears.
 */
@property (nonatomic, assign) MZFormSheetActionWhenKeyboardAppears movementActionWhenKeyboardAppears MZ_APPEARANCE_SELECTOR;

/**
 The handler to call when user tap on background view.
 */
@property (nonatomic, copy) MZFormSheetPresentationControllerTapHandler didTapOnBackgroundViewCompletionHandler;

/**
 The handler to call when presented form sheet is before entry transition and its view will show on window.
 */
@property (nonatomic, copy) MZFormSheetPresentationControllerCompletionHandler willPresentContentViewControllerHandler;

/**
 The handler to call when presented form sheet is after entry transition animation.
 */
@property (nonatomic, copy) MZFormSheetPresentationControllerCompletionHandler didPresentContentViewControllerHandler;

/**
 The handler to call when presented form sheet will be dismiss, this is called before out transition animation.
 */
@property (nonatomic, copy) MZFormSheetPresentationControllerCompletionHandler willDismissContentViewControllerHandler;

/**
 The handler to call when presented form sheet is after dismiss.
 */
@property (nonatomic, copy) MZFormSheetPresentationControllerCompletionHandler didDismissContentViewControllerHandler;

/**
 The background color of the background view.
 By default, this is a black at with a 0.5 alpha component
 */
@property (nonatomic, strong) UIColor *backgroundColor MZ_APPEARANCE_SELECTOR;

/*
 The intensity of the blur effect. See UIBlurEffectStyle for valid options.
 By default, this is UIBlurEffectStyleLight
 */
@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle MZ_APPEARANCE_SELECTOR;

/*
 Apply background blur effect, this property need to be set before form sheet presentation
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldApplyBackgroundBlurEffect MZ_APPEARANCE_SELECTOR;

/**
 Returns an initialized popup controller object.
 @param viewController This parameter must not be nil.
 */
- (instancetype)initWithContentViewController:(UIViewController *)viewController;


@end
