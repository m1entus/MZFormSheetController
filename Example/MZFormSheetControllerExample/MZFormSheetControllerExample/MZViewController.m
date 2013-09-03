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
    
    [[MZFormSheetController appearance] setCornerRadius:20.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    // [[MZFormSheetBackgroundWindow appearance] setShouldBackgroundImageOverlapStatusBar:YES];
}

- (void)transitionFromTop
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    
    // present form sheet with view controller
    [self presentFormSheetWithViewController:vc animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
       //do sth
    }];
}

- (void)transitionFromBottom
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.centerFormSheetVertically = YES;
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)transitionDropDown
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)transitionCustom
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZCustomFormSheetController *customFormSheet = [[MZCustomFormSheetController alloc] initWithViewController:vc];
    [self presentFormSheetController:customFormSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

    }];
    
}

- (void)backgroundTapToDismiss
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
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
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)formSheetTopInset
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.landscapeTopInset = 0;
    formSheet.portraitTopInset = 0;
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)formSheetNavigationController
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentAnimated:YES completionHandler:nil];
}

- (void)formSheetTabBarController
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tab"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)presentModalOnTopOfSheet
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    UIViewController *modal = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];
    
    [self presentFormSheetWithViewController:vc animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

        [formSheetController presentViewController:modal animated:YES completion:^{

        }];
        
    }];
}

- (void)presentFacebookCompose
{
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
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)fromRightAndBounce
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    formSheet.cornerRadius = 8.0;
    formSheet.portraitTopInset = 54.0;
    formSheet.presentedFormSheetSize = CGSizeMake(280, 180);
    
    [formSheet presentAnimated:YES completionHandler:nil];
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
        case 9: [self presentModalOnTopOfSheet]; break;
        case 10: [self presentFacebookCompose]; break;
        case 11: [self fromRightAndBounce]; break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
