MZFormSheetController
===========

MZFormSheetController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup controller size and feel form sheet. 


[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/screen1.png)
[![](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)](https://raw.github.com/m1entus/MZFormSheetController/master/Screens/animation.gif)

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

## Transitions

MZFormSheetController has predefined couple transitions.

``` objective-c
typedef NS_ENUM(NSInteger, MZFormSheetTransitionStyle) {
    MZFormSheetTransitionStyleSlideFromTop = 0,
    MZFormSheetTransitionStyleSlideFromBottom,
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
- (void)customTransitionEntryWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock;
- (void)customTransitionOutWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock;

```

## Appearance

``` objective-c
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

## Requirements

MZFormSheetController requires either iOS 5.x and above.

## Special thanks

I'd love a thank you tweet if you find this useful.

Special thanks to Kevin Cao who wrote some of transition code and concept of new key window used when form sheet is presenting on MZFormSheetController.

I would like also thanks to Daryl Ginn who inspired me with his [settings popup menu](http://dribbble.com/shots/851732-Settings)

## Storyboard

MZFormSheetController supports storyboard.

## ARC

MZFormSheetController uses ARC.

## Contact

[Michal Zaborowski](http://github.com/m1entus) 

