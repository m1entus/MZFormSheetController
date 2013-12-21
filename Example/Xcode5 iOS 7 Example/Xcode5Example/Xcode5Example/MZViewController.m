//
//  MZViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 13.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomTransition.h"

@interface MZViewController () <MZFormSheetBackgroundWindowDelegate>

@end

@implementation MZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];

    [MZFormSheetController registerTransitionClass:[MZCustomTransition class] forTransitionStyle:MZFormSheetTransitionStyleCustom];
}

- (IBAction)showFormSheet:(UIButton *)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
//    formSheet.shouldMoveToTopWhenKeyboardAppears = NO;

    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"PASSING DATA";
    };
    formSheet.transitionStyle = MZFormSheetTransitionStyleCustom;

    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;

    [self presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

    }];
}

- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didChangeStatusBarToOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)formSheetBackgroundWindow:(MZFormSheetBackgroundWindow *)formSheetBackgroundWindow didRotateToOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated
{
   NSLog(@"%@",NSStringFromSelector(_cmd)); 
}

@end
