//
//  MZFormSheetBackgroundWindow.h
//  MZFormSheetController
//
//  Created by Michał Zaborowski on 31.08.2013.
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
#import "MZAppearance.h"

extern UIWindowLevel const MZFormSheetBackgroundWindowLevelAboveStatusBar;
extern UIWindowLevel const MZFormSheetBackgroundWindowLevelBelowStatusBar;

@class MZFormSheetBackgroundWindow;

@protocol MZFormSheetBackgroundWindowDelegate <NSObject>
@optional
/**
 *  Called when the orientation of the device changes.
 *
 *  @param formSheetBackgroundWindow Form sheet background window.
 *  @param orientation Returns the physical orientation of the device.
 */
- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didRotateToOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated;

/**
 *  Called when the frame of the status bar changes.
 *
 *  @param formSheetBackgroundWindow Form sheet background window.
 *  @param newStatusBarFrame         Expressing the location and size of the new status bar frame.
 */
- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didChangeStatusBarFrame:(CGRect)newStatusBarFrame;

/**
 *  Called when the orientation of the application's user interface changes.
 *  This method is called inside an animation block.
 *
 *  @param formSheetBackgroundWindow Form sheet background window.
 *  @param orientation               The orientation of the application's user interface.
 */
- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didChangeStatusBarToOrientation:(UIInterfaceOrientation)orientation;
@end

@interface MZFormSheetBackgroundWindow : UIWindow <MZAppearance>

/**
 *  The object that acts as the delegate of the receiving form sheet background window.
 */
@property (nonatomic, weak) id <MZFormSheetBackgroundWindowDelegate> formSheetBackgroundWindowDelegate;

/**
 The positioning of windows relative to each other.
 If you want to cover status bar when a dialog is presented use MZFormSheetBackgroundWindowLevelAboveStatusBar
 (recomended for UIStatusBarStyleLightContent or if you don't use blur)

 extern UIWindowLevel const MZFormSheetBackgroundWindowLevelAboveStatusBar;
 extern UIWindowLevel const MZFormSheetBackgroundWindowLevelBelowStatusBar;
 
 By default, this is MZFormSheetBackgroundWindowLevelBelowStatusBar;
 */
@property (nonatomic, readwrite) UIWindowLevel windowLevel MZ_APPEARANCE_SELECTOR;

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
 The background image view.
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
 By default, this is NO
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
