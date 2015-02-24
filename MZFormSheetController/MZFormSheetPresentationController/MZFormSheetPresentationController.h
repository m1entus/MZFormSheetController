//
//  MZFormSheetPresentationController.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTransition.h"
#import "MZAppearance.h"

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

@property (nonatomic, readonly, strong) UIViewController *contentViewController;
@property (nonatomic, assign) CGSize contentViewSize MZ_APPEARANCE_SELECTOR;

@property (nonatomic, assign) CGFloat landscapeTopInset MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat portraitTopInset MZ_APPEARANCE_SELECTOR;

@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shouldCenterVertically MZ_APPEARANCE_SELECTOR;

@property (nonatomic, assign) MZFormSheetTransitionStyle transitionStyle MZ_APPEARANCE_SELECTOR;

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

@property (nonatomic, readwrite) UIColor *backgroundColor;

@property (nonatomic, assign) UIBlurEffectStyle blurEffectStyle MZ_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shouldApplyBackgroundBlurEffect MZ_APPEARANCE_SELECTOR;

+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

+ (Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

- (instancetype)initWithContentViewController:(UIViewController *)viewController;


@end
