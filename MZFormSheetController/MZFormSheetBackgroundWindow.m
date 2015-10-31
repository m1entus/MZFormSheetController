//
//  MZFormSheetBackgroundWindow.m
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

#import "MZFormSheetBackgroundWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additional.h"
#import "MZMacro.h"

CGFloat const MZFormSheetControllerDefaultBackgroundOpacity = 0.5;
CGFloat const MZFormSheetControllerDefaultBackgroundBlurRadius = 2.0;
CGFloat const MZFormSheetControllerDefaultBackgroundBlurSaturation = 1.0;

UIWindowLevel const MZFormSheetBackgroundWindowLevelAboveStatusBar = 1002;
UIWindowLevel const MZFormSheetBackgroundWindowLevelBelowStatusBar = 2;

extern CGFloat MZFormSheetControllerWindowTag;

static CGFloat const UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown: return M_PI;
        case UIInterfaceOrientationLandscapeLeft: return -M_PI_2;
        case UIInterfaceOrientationLandscapeRight: return M_PI_2;
        default: return 0.0f;
    }
}

static UIInterfaceOrientationMask const UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
    return 1 << orientation;
}

#pragma mark - MZFormSheetBackgroundWindow

@interface MZFormSheetBackgroundWindow()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign, getter = isUpdatingBlur) BOOL updatingBlur;
@property (nonatomic, assign) UIInterfaceOrientation lastWindowOrientation;
@property (nonatomic, strong) UIVisualEffectView *blurBackgroundView;
@end

@implementation MZFormSheetBackgroundWindow
@synthesize backgroundColor = _backgroundColor;
@synthesize windowLevel;

#pragma mark - Class methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wwarning-flag"

+ (void)initialize
{
    if (self == [MZFormSheetBackgroundWindow class]) {
        [[self appearance] setBackgroundColor:[UIColor colorWithWhite:0 alpha:MZFormSheetControllerDefaultBackgroundOpacity]];
        [[self appearance] setBlurRadius:MZFormSheetControllerDefaultBackgroundBlurRadius];
        [[self appearance] setBlurSaturation:MZFormSheetControllerDefaultBackgroundBlurSaturation];
        [[self appearance] setWindowLevel:MZFormSheetBackgroundWindowLevelBelowStatusBar];
        [[self appearance] setShouldUseNativeBlurEffect:YES];
        if (MZSystemVersionGreaterThanOrEqualTo_iOS8()) {
            [[self appearance] setBlurEffectStyle:UIBlurEffectStyleLight];
        }
        [[self appearance] setDynamicBlur:NO];
        [[self appearance] setDynamicBlurInterval:0.0f];
    }
}

#pragma clang diagnostic pop

+ (instancetype)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

+ (UIImage *)screenshotUsingContext:(BOOL)useContext
{
    // Create a graphics context with the target size
    UIGraphicsBeginImageContextWithOptions([[UIScreen mainScreen] bounds].size, NO, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ((![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) && window.tag != MZFormSheetControllerWindowTag && ![window isKindOfClass:[MZFormSheetBackgroundWindow class]])
        {
            if (CGRectEqualToRect(window.bounds, CGRectZero)){
                continue;
            }
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);

            if (useContext) {
                // Render the layer hierarchy to the current context
                [[window layer] renderInContext:context];
            } else {
                if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
                    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
                } else {
                    [[window layer] renderInContext:context];
                }
            }


            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Setters

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    _supportedInterfaceOrientations = supportedInterfaceOrientations;

    [self rotateWindow];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (void)setShouldUseNativeBlurEffect:(BOOL)shouldUseNativeBlurEffect {
    if (_shouldUseNativeBlurEffect != shouldUseNativeBlurEffect) {
        if (MZSystemVersionGreaterThanOrEqualTo_iOS8()) {
            _shouldUseNativeBlurEffect = shouldUseNativeBlurEffect;
        } else {
            _shouldUseNativeBlurEffect = NO;
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (self.backgroundImageView) {
        self.backgroundImageView.image = backgroundImage;
    } else {
        _backgroundImage = backgroundImage;
    }
    
}

- (void)setBackgroundBlurEffect:(BOOL)backgroundBlurEffect
{
    if (_backgroundBlurEffect != backgroundBlurEffect) {
        if (_backgroundBlurEffect && !backgroundBlurEffect) {
            self.backgroundImageView.image = [[UIImage alloc] init];
        }

        _backgroundBlurEffect = backgroundBlurEffect;

        if (self.dynamicBlur) {
            [self updateBlurAsynchronously];
        }
    }
}

- (void)setDynamicBlur:(BOOL)dynamicBlur
{
    if (_dynamicBlur != dynamicBlur) {
        _dynamicBlur = dynamicBlur;
        if (dynamicBlur)
        {
            [self updateBlurAsynchronously];
        }
    }
}

#pragma mark - Getters

- (UIColor *)backgroundColor
{
    return _backgroundColor;
}

#pragma mark - Initializers

- (void)makeKeyAndVisible
{
    [super makeKeyAndVisible];

    if (self.backgroundBlurEffect) {
        [self updateBlurUsingContext:NO];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;

        id appearance = [[self class] appearance];
        [appearance applyInvocationTo:self];

        _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _backgroundImageView.image = _backgroundImage;

        [self addSubview:_backgroundImageView];

        [_backgroundImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];

        [self rotateWindow];

        self.lastWindowOrientation = [self windowOrientation];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientationNotificationHandler:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarFrameNotificationHandler:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didOrientationChangeNotificationHandler:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForegroundNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];

    }
    return self;
}

- (void)willEnterForegroundNotification:(NSNotification *)notification {
    if (self.shouldUseNativeBlurEffect) {
        self.hidden = YES;
        [self makeKeyAndVisible];
    }
}

#pragma mark - Notification handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.backgroundImageView] && [keyPath isEqualToString:@"image"])
    {
        _backgroundImage = change[@"new"];
    }
}

- (void)didOrientationChangeNotificationHandler:(NSNotification *)notification
{
    [self rotateWindow];

    UIInterfaceOrientation windowOrientation = [self windowOrientation];
    if (self.backgroundBlurEffect && windowOrientation != self.lastWindowOrientation) {
        self.lastWindowOrientation = windowOrientation;
        [self updateBlurUsingContext:YES];
    }

    if ([self.formSheetBackgroundWindowDelegate respondsToSelector:@selector(formSheetBackgroundWindow:didRotateToOrientation:animated:)]) {
        BOOL animated = [notification.userInfo[@"UIDeviceOrientationRotateAnimatedUserInfoKey"] boolValue];
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];

        [self.formSheetBackgroundWindowDelegate formSheetBackgroundWindow:self didRotateToOrientation:deviceOrientation animated:animated];
    }
}

- (void)didChangeStatusBarOrientationNotificationHandler:(NSNotification *)notification
{
    [self rotateWindow];

    if ([self.formSheetBackgroundWindowDelegate respondsToSelector:@selector(formSheetBackgroundWindow:didChangeStatusBarToOrientation:)]) {
        NSNumber *orientation = notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
        [self.formSheetBackgroundWindowDelegate formSheetBackgroundWindow:self didChangeStatusBarToOrientation:[orientation integerValue]];
    }
}

- (void)didChangeStatusBarFrameNotificationHandler:(NSNotification *)notification
{
    // This notification is inside an animation block
    [self rotateWindow];

    if ([self.formSheetBackgroundWindowDelegate respondsToSelector:@selector(formSheetBackgroundWindow:didChangeStatusBarFrame:)]) {
        NSValue *statusBarFrame = notification.userInfo[UIApplicationStatusBarFrameUserInfoKey];
        [self.formSheetBackgroundWindowDelegate formSheetBackgroundWindow:self didChangeStatusBarFrame:[statusBarFrame CGRectValue]];
    }
}

#pragma mark - Blur

- (void)setupNativeBackgroundBlurView {
    [self.blurBackgroundView removeFromSuperview];
    self.blurBackgroundView = nil;

    if (self.shouldUseNativeBlurEffect) {

        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        self.blurBackgroundView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];

        self.blurBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

        self.blurBackgroundView.frame = self.bounds;
        self.blurBackgroundView.translatesAutoresizingMaskIntoConstraints = YES;
        self.blurBackgroundView.userInteractionEnabled = NO;

        super.backgroundColor = [UIColor clearColor];
        self.backgroundImageView.hidden = YES;
        [self insertSubview:self.blurBackgroundView atIndex:0];
    } else {
        self.backgroundImageView.hidden = NO;
        super.backgroundColor = self.backgroundColor;
    }
}

- (UIImage *)rotateImageToStatusBarOrientation:(UIImage *)image
{
    if (MZSystemVersionLessThan_iOS8()) {
        if ([self windowOrientation] == UIInterfaceOrientationLandscapeLeft) {
            return [image imageRotatedByDegrees:90];
        } else if ([self windowOrientation] == UIInterfaceOrientationLandscapeRight) {
            return [image imageRotatedByDegrees:-90];
        } else if ([self windowOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
            return [image imageRotatedByDegrees:180];
        }
    }
    
    return image;
}

- (void)updateBlurUsingContext:(BOOL)useContext
{
    if (self.shouldUseNativeBlurEffect) {
        if (!self.blurBackgroundView) {
            [self setupNativeBackgroundBlurView];
        }
    } else {
        UIImage *blurredImage = [[MZFormSheetBackgroundWindow screenshotUsingContext:useContext] blurredImageWithRadius:self.blurRadius tintColor:self.blurTintColor saturationDeltaFactor:self.blurSaturation maskImage:self.blurMaskImage];

        self.backgroundImageView.image = [self rotateImageToStatusBarOrientation:blurredImage];
    }
}


- (void)updateBlurAsynchronously
{
    if (self.dynamicBlur && !self.isUpdatingBlur && self.backgroundBlurEffect && !self.shouldUseNativeBlurEffect)
    {
        UIImage *snapshot = [self rotateImageToStatusBarOrientation:[MZFormSheetBackgroundWindow screenshotUsingContext:YES]];

        self.updatingBlur = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

            UIImage *blurredImage = [snapshot blurredImageWithRadius:self.blurRadius tintColor:self.blurTintColor saturationDeltaFactor:self.blurSaturation maskImage:self.blurMaskImage];

            dispatch_sync(dispatch_get_main_queue(), ^{

                self.updatingBlur = NO;
                if (self.dynamicBlur)
                {
                    self.backgroundImageView.image = blurredImage;
                    if (self.dynamicBlurInterval)
                    {
                        [self performSelector:@selector(updateBlurAsynchronously) withObject:nil
                                   afterDelay:self.dynamicBlurInterval inModes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];
                    }
                    else
                    {
                        [self performSelectorOnMainThread:@selector(updateBlurAsynchronously) withObject:nil
                                            waitUntilDone:NO modes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];
                    }
                }
            });
        });
    }
}

#pragma mark - Window rotations

- (void)rotateWindow
{
    CGFloat angle = UIInterfaceOrientationAngleOfOrientation([self windowOrientation]);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
    [self makeTransform:transform forView:self.backgroundImageView inFrame:self.bounds];
}

- (void)makeTransform:(CGAffineTransform)transform forView:(UIView *)view inFrame:(CGRect)frame
{
    if(!CGAffineTransformEqualToTransform(view.transform, transform)) {
        view.transform = transform;
    }

    if(!CGRectEqualToRect(view.frame, frame)) {
        view.frame = frame;
    }
}

- (UIInterfaceOrientation)windowOrientation
{
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);

    if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
        return statusBarOrientation;
        
    } else {
        if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
            return UIInterfaceOrientationPortrait;
            
        } else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
            return UIInterfaceOrientationLandscapeLeft;
            
        } else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
            return UIInterfaceOrientationLandscapeRight;
            
        } else {
            return UIInterfaceOrientationPortraitUpsideDown;
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self.backgroundImageView removeObserver:self forKeyPath:@"image"];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

@end
