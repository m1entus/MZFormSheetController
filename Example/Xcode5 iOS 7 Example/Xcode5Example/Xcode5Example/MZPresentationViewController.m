//
//  MZPresentationViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import "MZPresentationViewController.h"
#import "MZFormSheetPresentationController.h"
#import "MZFormSheetPresentationControllerSegue.h"

@interface MZPresentationViewController ()

@end

@implementation MZPresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)action:(id)sender {
    UIViewController *modal = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];
    MZFormSheetPresentationController *controller = [[MZFormSheetPresentationController alloc] initWithContentViewController:modal];
    controller.contentViewControllerTransitionStyle = MZFormSheetTransitionStyleDropDown;
    controller.shouldCenterVertically = YES;
    controller.shouldDismissOnBackgroundViewTap = YES;
    controller.movementActionWhenKeyboardAppears = MZFormSheetActionWhenKeyboardAppearsMoveToTop;
    controller.shouldApplyBackgroundBlurEffect = YES;

    controller.didDismissContentViewControllerHandler = ^(UIViewController *content) {
        NSLog(@"DID DISMISS");
    };

    controller.willDismissContentViewControllerHandler = ^(UIViewController *content) {
        NSLog(@"WILL DISMISS");
    };

    controller.didPresentContentViewControllerHandler = ^(UIViewController *content) {
        NSLog(@"DID PRESENT");
        [self setNeedsStatusBarAppearanceUpdate];
    };

    controller.willPresentContentViewControllerHandler = ^(UIViewController *content) {
        NSLog(@"WILL PRESENT");
    };
//    controller.blurEffectStyle = UIBlurEffectStyleDark;

    UINavigationController *navController = (UINavigationController *)modal;
    navController.topViewController.title = @"PASSING DATA";


    [self presentViewController:controller animated:YES completion:^{

    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"formSheet"]) {
        MZFormSheetPresentationControllerSegue *formSheetSegue = (MZFormSheetPresentationControllerSegue *)segue;
        MZFormSheetPresentationController *formSheet = formSheetSegue.formSheetPresentationController;
        formSheet.contentViewControllerTransitionStyle = MZFormSheetTransitionStyleBounce;
        formSheet.portraitTopInset = 0;
        formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];

        };
        UINavigationController *navController = (UINavigationController *)formSheet.contentViewController;
        navController.topViewController.title = @"PASSING DATA";

        formSheet.shouldDismissOnBackgroundViewTap = NO;

        formSheet.didPresentContentViewControllerHandler = ^(UIViewController *presentedFSViewController) {
            NSLog(@"DID PRESENT");
            [self setNeedsStatusBarAppearanceUpdate];
        };
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.presentedViewController ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent; // your own style
}

- (BOOL)prefersStatusBarHidden {
    return NO; // your own visibility code
}


@end
