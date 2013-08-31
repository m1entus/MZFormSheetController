//
//  MZFormSheetBackgroundWindow.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 31.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZFormSheetBackgroundWindow.h"

CGFloat const MZFormSheetControllerDefaultBackgroundOpacity = 0.5;

UIWindowLevel const UIWindowLevelFormSheetBackground = 1990.0; // below the alert window

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


@interface MZFormSheetBackgroundWindow()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation MZFormSheetBackgroundWindow
@synthesize backgroundColor = _backgroundColor;

+ (void)initialize
{
    if (self == [MZFormSheetBackgroundWindow class]) {
        [[self appearance] setBackgroundColor:[UIColor colorWithWhite:0 alpha:MZFormSheetControllerDefaultBackgroundOpacity]];
    }
}

+ (CGFloat)statusBarHeight
{
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    _supportedInterfaceOrientations = supportedInterfaceOrientations;

    [self rotateWindow];
}

- (void)setShouldBackgroundImageOverlapStatusBar:(BOOL)shouldBackgroundImageOverlapStatusBar
{
    _shouldBackgroundImageOverlapStatusBar = shouldBackgroundImageOverlapStatusBar;

    [self rotateWindow];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (UIColor *)backgroundColor
{
    return _backgroundColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.windowLevel = UIWindowLevelFormSheetBackground;

        _supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

        _backgroundImageView.image = _backgroundImage = [[[self class] appearance] backgroundImage];

        [self addSubview:_backgroundImageView];

        [self rotateWindow];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarHandler:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarHandler:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)didChangeStatusBarHandler:(NSNotification *)notification
{
    // This notification is inside an animation block
    [self rotateWindow];
}

- (void)rotateWindow
{
    CGFloat angle = UIInterfaceOrientationAngleOfOrientation([self windowOrientation]);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);

    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect windowRect = [self windowRectForStatusBarOrientation:statusBarOrientation];

    if (self.shouldBackgroundImageOverlapStatusBar) 
        windowRect = self.bounds;
    
    [self makeTransform:transform forView:self.backgroundImageView inFrame:windowRect];
}

- (CGRect)windowRectForStatusBarOrientation:(UIInterfaceOrientation)statusBarOrientation
{
    CGFloat statusBarHeight = [MZFormSheetBackgroundWindow statusBarHeight];
    
    CGRect frame = self.bounds;
    frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
    frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
    frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
    frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
    return frame;
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

@end
