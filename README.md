[![](http://inspace.io/github-cover.jpg)](http://inspace.io)

MZFormSheetController v3
===========

### `MZFormSheetController` was rewritten and replaced by [`MZFormSheetPresentationController`](https://github.com/m1entus/MZFormSheetPresentationController) which base on new iOS 8 modal presentation API. You can still use MZFormSheetController if you want to support <iOS8, but if you have deployment target set to iOS8 `i recommed you to use  MZFormSheetPresentationController`, i have dropped support for this project in favour of MZFormSheetPresentationController. MZFormSheetPresentationController don't use any tricky hacks to present form sheet as a UIWindow, it use native modalPresentationStyle UIModalPresentationOverFullScreen, and use native `UIVisualEffect` view to make blur.

## MZFormSheetPresentationController contain example project for Swift and Objective-C.

MZFormSheetController
===========

MZFormSheetController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup controller size and feel form sheet.


[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation1.gif)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation1.gif)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen2.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen2.png)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)

## How To Use

Let's start with a simple example

``` objective-c
UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];

// present form sheet with view controller
[self mz_presentFormSheetController:vc animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
   //do sth
}];
```

This will display view controller inside form sheet container.

If you want to dismiss form sheet controller, you can use category on UIViewController to provide access to the formSheetController.

``` objective-c
[self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    // do sth
}];
```

## Passing data

``` objective-c
formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
    // Passing data
    UINavigationController *navController = (UINavigationController *)presentedFSViewController;
    navController.topViewController.title = @"PASSING DATA";
};
```

## Touch transparent background

If you want to have access to the controller that is below MZFormSheet, you can set background window to be touch transparent.

``` objective-c
MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];

formSheet.formSheetWindow.transparentTouchEnabled = YES;

[formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {

}];
```

## Blur background effect

It is possible to display blurry background, you can set MZFormSheetWindow appearance or directly to window


``` objective-c
[[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
[[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
[[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
```

``` objective-c
[[MZFormSheetController sharedBackgroundWindow] setBackgroundBlurEffect:YES];
[[MZFormSheetController sharedBackgroundWindow] setBlurRadius:5.0];
[[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor clearColor]];
```

## Transitions

MZFormSheetController has predefined couple transitions.

``` objective-c
typedef NS_ENUM(NSInteger, MZFormSheetTransitionStyle) {
    MZFormSheetTransitionStyleSlideFromTop = 0,
    MZFormSheetTransitionStyleSlideFromBottom,
    MZFormSheetTransitionStyleSlideFromLeft,
    MZFormSheetTransitionStyleSlideFromRight,
    MZFormSheetTransitionStyleSlideAndBounceFromLeft,
    MZFormSheetTransitionStyleSlideAndBounceFromRight,
    MZFormSheetTransitionStyleFade,
    MZFormSheetTransitionStyleBounce,
    MZFormSheetTransitionStyleDropDown,
    MZFormSheetTransitionStyleCustom,
    MZFormSheetTransitionStyleNone,
};
```

You can create your own transition by subclassing MZTransition.

``` objective-c
/**
 *  Register custom transition animation style.
 *  You need to setup transitionStyle to MZFormSheetTransitionStyleCustom.
 *
 *  @param transitionClass Custom transition class.
 *  @param transitionStyle The transition style to use when presenting the receiver.
 */
+ (void)registerTransitionClass:(Class)transitionClass forTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

+ (Class)classForTransitionStyle:(MZFormSheetTransitionStyle)transitionStyle;

@protocol MZFormSheetControllerTransition <NSObject>
@required
/**
 Subclasses must implement to add custom transition animation.
 When animation is finished you must call super method or completionHandler to keep view life cycle.
 */
- (void)entryFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;
- (void)exitFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;

@end

@interface MZCustomTransition : MZTransition <MZFormSheetControllerTransition>
@end

- (void)entryFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler
{
    // It is very important to use self.view.bounds not self.view.frame !!!
    // When you rotate your device, the device is not changing its screen size.
    // It is staying the same, however the view is changing. So this is why you would want to use bounds.

    CGRect formSheetRect = self.presentedFSViewController.view.frame;
    CGRect originalFormSheetRect = formSheetRect;
    originalFormSheetRect.origin.x = self.view.bounds.size.width - formSheetRect.size.width - 10;
    formSheetRect.origin.x = self.view.bounds.size.width;
    self.presentedFSViewController.view.frame = formSheetRect;
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                     animations:^{
                         self.presentedFSViewController.view.frame = originalFormSheetRect;
                     }
                     completion:^(BOOL finished) {
                         if (completionHandler) {
                             completionHandler();
                         }
                     }];
}
- (void)exitFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler
{
    CGRect formSheetRect = self.presentedFSViewController.view.frame;
    formSheetRect.origin.x = self.view.bounds.size.width;
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.presentedFSViewController.view.frame = formSheetRect;
                     }
                     completion:^(BOOL finished) {
                         if (completionHandler) {
                             completionHandler();
                         }
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MZFormSheetController registerTransitionClass:[MZCustomTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];

    self.transitionStyle = MZFormSheetTransitionStyleCustom;
    self.presentedFSViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

```

## Full screen modal view controllers

It is possible to full screen present modal view controllers over the form sheet.

``` objective-c
UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
UIViewController *modal = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];

[self mz_presentFormSheetWithViewController:vc animated:YES transitionStyle:MZFormSheetTransitionStyleSlideAndBounceFromLeft completionHandler:^(MZFormSheetController *formSheetController) {

    [formSheetController presentViewController:modal animated:YES completion:^{

    }];

}];

```

## Custom compose view controllers

You can easly create your own custom compose view controllers on storyboard, and present it.

``` objective-c
UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"facebook"];

MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
formSheet.shouldDismissOnBackgroundViewTap = YES;
formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
formSheet.cornerRadius = 8.0;
formSheet.portraitTopInset = 6.0;
formSheet.landscapeTopInset = 6.0;
formSheet.presentedFormSheetSize = CGSizeMake(320, 200);


formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
    presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
};

[formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {

}];

or

[self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

}];

```

## Appearance

MZFormSheetController supports appearance proxy.

``` objective-c
id appearance = [MZFormSheetController appearance];

[appearance setBackgroundOpacity:0.2];
[appearance setCornerRadius:4];
[appearance setShadowOpacity:0.4];
```

``` objective-c
@interface MZFormSheetBackgroundWindow : UIWindow <MZAppearance>

/**
 The background color of the background view.
 After last form sheet dismiss, backgroundColor will change to default.
 If you want to set it permanently to another color use appearance proxy on MZFormSheetBackgroundWindow.
 By default, this is a black at with a 0.5 alpha component
 */
@property (nonatomic, strong) UIColor *backgroundColor MZ_APPEARANCE_SELECTOR;

/**
 The background image of the background view, it is setter for backgroundImageView and can be set by MZAppearance proxy.
 After last form sheet dismiss, backgroundImage will change to default.
 If you want to set it permanently to another color use appearance proxy on MZFormSheetBackgroundWindow.
 By default, this is nil
 */
@property (nonatomic, strong) UIImage *backgroundImage MZ_APPEARANCE_SELECTOR;

/**
 The background image view, if you want to set backgroundImage use backgroundImage property.
 */
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

/*
 Apply background blur effect
 By default, this is NO
 */
@property (nonatomic, assign) BOOL backgroundBlurEffect MZ_APPEARANCE_SELECTOR;

/*
 Specifies the blur radius used to render the blur background view
 By default, this is 2.0
 */
@property (nonatomic, assign) CGFloat blurRadius MZ_APPEARANCE_SELECTOR;

/*
 Specifies the blur tint color used to render the blur background view
 By default, this is nil
 */
@property (nonatomic, strong) UIColor *blurTintColor MZ_APPEARANCE_SELECTOR;

/*
 Specifies the blur saturation used to render the blur background view
 By default, this is 1.0
 */
@property (nonatomic, assign) CGFloat blurSaturation MZ_APPEARANCE_SELECTOR;

/*
 Specifies the blur mask image used to render the blur background view
 By default, this is nil
 */
@property (nonatomic, strong) UIImage *blurMaskImage MZ_APPEARANCE_SELECTOR;

/*
 Asynchronously recompute the display of background blur.
 Recommended to use if you expect interface orientation or some dynamic animations belof form sheet
 */
@property (nonatomic, assign) BOOL dynamicBlur MZ_APPEARANCE_SELECTOR;

/*
 Specifies how often the blur background refresh.
 Works only if dynamicBlur is set to YES.
 By default, this is 0
 */
@property (nonatomic, assign) CGFloat dynamicBlurInterval MZ_APPEARANCE_SELECTOR;

/*
 All of the interface orientations that the background image view supports.
 By default, this is UIInterfaceOrientationMaskAll
 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations MZ_APPEARANCE_SELECTOR;
@end
```

``` objective-c
typedef NS_ENUM(NSInteger, MZFormSheetWhenKeyboardAppears) {
  MZFormSheetWhenKeyboardAppearsDoNothing = 0,
  MZFormSheetWhenKeyboardAppearsCenterVertically,
  MZFormSheetWhenKeyboardAppearsMoveToTop,
  MZFormSheetWhenKeyboardAppearsMoveToTopInset,
};

/**
 Returns the window that is displayed below form sheet controller
 */
+ (MZFormSheetBackgroundWindow *)sharedBackgroundWindow;

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
 The movement style to use when the keyboard appears.
 By default, this is MZFormSheetWhenKeyboardAppearsMoveToTop.
 */
@property (nonatomic, assign) MZFormSheetWhenKeyboardAppears movementWhenKeyboardAppears MZ_APPEARANCE_SELECTOR;

```

## Completion Blocks

``` objective-c
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
```

## Notifications

``` objective-c
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
```

## Supported interface orientations

MZFormSheetController support all interface orientations.
If you want to resize form sheet controller during orientation change you can use autoresizeMask property.

You can manipulate interface orientation using this code:

``` objective-c
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSUInteger orientations = UIInterfaceOrientationMaskAll;

    if ([MZFormSheetController formSheetControllersStack] > 0) {
        MZFormSheetController *viewController = [[MZFormSheetController formSheetControllersStack] lastObject];
        return [viewController.presentedFSViewController supportedInterfaceOrientations];
    }

    return orientations;
}
```

## PreferredStatusBarStyle (iOS7)

Presented view controller or UINavigationController topViewController is used
for determining status bar style. If you don't want this behavior subclass MZFormSheetController.

``` objective-c
- (UIViewController *)childViewControllerForStatusBarStyle
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return [navigationController.topViewController mz_childTargetViewControllerForStatusBarStyle];
    }

    return [self.presentedFSViewController mz_childTargetViewControllerForStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    if ([self.presentedFSViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.presentedFSViewController;
        return [navigationController.topViewController mz_childTargetViewControllerForStatusBarStyle];
    }
    return [self.presentedFSViewController mz_childTargetViewControllerForStatusBarStyle];
}
```

## Others

``` objective-c
/**
 Returns whether the form sheet controller should dismiss after background view tap.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap UI_APPEARANCE_SELECTOR;

/**
 The handler to call when user tap on background view
 */
@property (nonatomic, copy) MZFormSheetBackgroundViewTapCompletionHandler didTapOnBackgroundViewCompletionHandler;
```

## MZFormSheetController+SVProgressHUD

* If you want to SVProgressHUD to work with MZFormSheetController all you need is import #import "MZFormSheetController+SVProgressHUD.h"
from MZFormSheetController+SVProgressHUD directory.

## Known Issues

* There is not possible to set blurred UINavigationBar when view controller is
presented from MZFormSheetController.<br />If you don't want to have UINavigationBar
inner white shadow in iOS7, you should set UINavigationBar translucent property to NO.

* If you are using blurred background, you will have huge delay on iPad 3 Retina.<br />
I recommend you to turn off background blur for iPad 3 Retina.

* If you want to present modal view controller on top of MZFormSheetController you have to present it from formSheetController, for example:

```objective-c
// Easiest way:
[[[MZFormSheetController formSheetControllersStack] lastObject] presentViewController:navHistorico animated:YES completion:^{

}];

// Navigation Controller as a root of presentedFormSheetController:
[self.navigationController.formSheetController presentViewController:vc animated:YES completion:^{

}];

// View Controller as a root of presentedFormSheetController:
[self.formSheetController presentViewController:vc animated:YES completion:^{

}];
```

## Autolayout

MZFormSheetController supports autolayout.

## Requirements

MZFormSheetController requires either iOS 5.x and above.

Frameworks: 'QuartzCore', 'Accelerate'

## Special thanks

I'd love a thank you tweet if you find this useful.

Special thanks to Kevin Cao who wrote some of transition code and concept of new key window used when form sheet is presenting on MZFormSheetController.

I would like also thanks to Daryl Ginn who inspired me with his [settings popup menu](http://dribbble.com/shots/851732-Settings)

## Storyboard

MZFormSheetController supports storyboard.

MZFormSheetSegue is a custom storyboard segue which use default MZFormSheetController settings.

## ARC

MZFormSheetController uses ARC.

## Contact

[Michal Zaborowski](http://github.com/m1entus)

[Twitter](https://twitter.com/iMientus)


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/m1entus/mzformsheetcontroller/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
