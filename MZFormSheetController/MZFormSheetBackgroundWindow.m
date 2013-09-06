//
//  MZFormSheetBackgroundWindow.m
//  MZFormSheetControllerExample
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

CGFloat const MZFormSheetControllerDefaultBackgroundOpacity = 0.5;
CGFloat const MZFormSheetControllerDefaultBackgroundBlurRadius = 2.0;
CGFloat const MZFormSheetControllerDefaultBackgroundBlurSaturation = 1.0;

UIWindowLevel const UIWindowLevelFormSheetBackground = 2;

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
@end

@implementation MZFormSheetBackgroundWindow
@synthesize backgroundColor = _backgroundColor;

#pragma mark - Class methods

+ (void)initialize
{
    if (self == [MZFormSheetBackgroundWindow class]) {
        [[self appearance] setBackgroundColor:[UIColor colorWithWhite:0 alpha:MZFormSheetControllerDefaultBackgroundOpacity]];
        [[self appearance] setBackgroundBlurEffect:NO];
        [[self appearance] setBlurRadius:MZFormSheetControllerDefaultBackgroundBlurRadius];
        [[self appearance] setBlurSaturation:MZFormSheetControllerDefaultBackgroundBlurSaturation];
        [[self appearance] setDynamicBlur:NO];
        [[self appearance] setDynamicBlurInterval:0.0f];
    }
}

+ (id)appearance
{
    return [MZAppearance appearanceForClass:[self class]];
}

+ (UIImage *)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if ((![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) && window.tag != MZFormSheetControllerWindowTag && ![window isKindOfClass:[MZFormSheetBackgroundWindow class]])
        {
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

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

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
    if (_backgroundBlurEffect && !backgroundBlurEffect) {
        self.backgroundImageView.image = [[UIImage alloc] init];
    }

    _backgroundBlurEffect = backgroundBlurEffect;

    if (backgroundBlurEffect) {
        [self updateBlur];
    }
    if (self.dynamicBlur) {
        [self updateBlurAsynchronously];
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

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelFormSheetBackground;

        _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

        id appearance = [[self class] appearance];
        [appearance applyInvocationTo:self];

        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        _backgroundImageView.image = _backgroundImage;

        [self addSubview:_backgroundImageView];

        [_backgroundImageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];

        [self rotateWindow];

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarNotificationHandler:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarNotificationHandler:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didOrientationChangeNotificationHandler:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];

    }
    return self;
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
}

- (void)didChangeStatusBarNotificationHandler:(NSNotification *)notification
{
    // This notification is inside an animation block
    [self rotateWindow];
}

#pragma mark - Blur

- (UIImage *)rotateImageToStatusBarOrientation:(UIImage *)image
{
    if ([self windowOrientation] == UIInterfaceOrientationLandscapeLeft) {
        return [image imageRotatedByDegrees:90];
    } else if ([self windowOrientation] == UIInterfaceOrientationLandscapeRight) {
        return [image imageRotatedByDegrees:-90];
    } else if ([self windowOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
        return [image imageRotatedByDegrees:180];
    }
    return image;
}

- (void)updateBlur
{
    UIImage *blurredImage = [[MZFormSheetBackgroundWindow screenshot] blurredImageWithRadius:self.blurRadius tintColor:self.blurTintColor saturationDeltaFactor:self.blurSaturation maskImage:self.blurMaskImage];

    self.backgroundImageView.image = [self rotateImageToStatusBarOrientation:blurredImage];
}


- (void)updateBlurAsynchronously
{
    if (self.dynamicBlur && !self.isUpdatingBlur && self.backgroundBlurEffect)
    {
        UIImage *snapshot = [self rotateImageToStatusBarOrientation:[MZFormSheetBackgroundWindow screenshot]];

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
    if (self.backgroundBlurEffect) {
        [self updateBlur];
    }

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

@end
