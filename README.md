MZFormSheetController
===========

MZFormSheetController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup controller size and feel form sheet. 


[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen2.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen2.png)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen3.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen3.png)

## How To Use

Let's start with a simple example

``` objective-c
UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];

// present form sheet with view controller
[self presentFormSheetWithViewController:vc completionHandler:^(MZFormSheetController *formSheetController) {
    //Do something in completionHandler
}];
```

This will display view controller inside form sheet container. 

If you want to dismiss form sheet controller, you can use category on UIViewController to provide access to the formSheetController.

``` objective-c
[self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
    //do sth
}];
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

You can create your own transition by subclassing MZFormSheetController.

``` objective-c
/**
 Subclasses may override to add custom transition animation.
 You need to setup transitionStyle to MZFormSheetTransitionStyleCustom to call this method.
 When animation is finished you should must call super method or completionBlock to keep view life cycle.
 */
- (void)customTransitionEntryWithCompletionBlock:(void(^)())completionBlock;
- (void)customTransitionOutWithCompletionBlock:(void(^)())completionBlock;

For example, transition from right side

- (void)customTransitionEntryWithCompletionBlock:(void(^)())completionBlock
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
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}
- (void)customTransitionOutWithCompletionBlock:(void(^)())completionBlock
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
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.transitionStyle = MZFormSheetTransitionStyleCustom;
    self.presentedFSViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

```

## Full screen modal view controllers

It is possible to full screen present modal view controllers over the form sheet.

``` objective-c
UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
UIViewController *modal = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];

[self presentFormSheetWithViewController:vc completionHandler:^(MZFormSheetController *formSheetController) {

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

[formSheet presentWithCompletionHandler:nil];
```

## Appearance

``` objective-c
typedef NS_ENUM(NSInteger, MZFormSheetBackgroundStyle) {
    MZFormSheetBackgroundStyleTransparent = 0,
    MZFormSheetBackgroundStyleSolid,
};

/**
 Background view style.
 By default, this is MZFormSheetBackgroundStyleSolid.
 */
@property (nonatomic, assign) MZFormSheetBackgroundStyle backgroundStyle; 

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

# Supported interface orientations

MZFormSheetController support all interface orientations.
If you want to resize form sheet controller during orientation change you can use autoresizeMask property. 

# Others

``` objective-c
/**
 Returns whether the form sheet controller should dismiss after background view tap.
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundViewTap;

/**
 The handler to call when user tap on background view
 */
@property (nonatomic, copy) MZFormSheetBackgroundViewTapCompletionHandler didTapOnBackgroundViewCompletionHandler;
```

## Autolayout

MZFormSheetController supports autolayout.

## Requirements

MZFormSheetController requires either iOS 5.x and above.

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

