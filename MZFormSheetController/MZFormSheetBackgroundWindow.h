//
//  MZFormSheetBackgroundWindow.h
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 31.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZFormSheetBackgroundWindow : UIWindow

/**
 The background color of the background view.
 After last form sheet dismiss, backgroundColor will change to default.
 If you want to set it permanently to another color use appearance proxy on MZFormSheetBackgroundWindow.
 By default, this is a black at with a 0.5 alpha component
 */
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 The background image of the background view, it is setter for backgroundImageView and can be set by MZAppearance proxy.
 After last form sheet dismiss, backgroundImage will change to default.
 If you want to set it permanently to another color use appearance proxy on MZFormSheetBackgroundWindow.
 By default, this is nil
 */
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

/**
 The background image view, if you want to set backgroundImage use backgroundImage property.
 */
@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

/*
 If background image is displayed, status bar will be overlaped
 By default, this is NO
 */
@property (nonatomic, assign) BOOL shouldBackgroundImageOverlapStatusBar UI_APPEARANCE_SELECTOR;

/*
 All of the interface orientations that the background image view supports.
 By default, this is UIInterfaceOrientationMaskAll
 */
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations;
@end
