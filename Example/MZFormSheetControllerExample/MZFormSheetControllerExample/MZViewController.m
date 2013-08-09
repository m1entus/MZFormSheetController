//
//  MZViewController.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 09.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZViewController.h"
#import "MZFormSheetController.h"
#import "MZCustomFormSheetController.h"

@interface MZViewController ()

@end

@implementation MZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
}

- (void)transitionFromTop
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    
    // present form sheet with view controller
    [self presentFormSheetWithViewController:vc completionHandler:^(MZFormSheetController *formSheetController) {
        //Do something in completionHandler
    }];
}

- (void)transitionFromBottom
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    [formSheet presentWithCompletionHandler:^{
       //do sth
    }];
}

- (void)transitionDropDown
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
}

- (void)transitionCustom
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZCustomFormSheetController *customFormSheet = [[MZCustomFormSheetController alloc] initWithViewController:vc];
    [customFormSheet presentWithCompletionHandler:^{
        
    }];
}

- (void)backgroundTapToDismiss
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
    
    formSheet.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location)
    {
        
    };
}

- (void)formSheetWidth
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(320, 220) viewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
}

- (void)formSheetTopInset
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.landscapeTopInset = 0;
    formSheet.portraitTopInset = 0;
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
}

- (void)formSheetNavigationController
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
}

- (void)formSheetTabBarController
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tab"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentWithCompletionHandler:^{
        //do sth
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: [self transitionFromTop]; break;
        case 1: [self transitionFromBottom]; break;
        case 2: [self transitionDropDown]; break;
        case 3: [self transitionCustom]; break;
        case 4: [self backgroundTapToDismiss]; break;
        case 5: [self formSheetWidth]; break;
        case 6: [self formSheetTopInset]; break;
        case 7: [self formSheetNavigationController]; break;
        case 8: [self formSheetTabBarController]; break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
