//
//  MZViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 13.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZViewController.h"
#import "MZFormSheetController.h"

@interface MZViewController ()

@end

@implementation MZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    

}

- (IBAction)showFormSheet:(UIButton *)sender
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"modal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.landscapeTopInset = 20;
    formSheet.backgroundStyle = MZFormSheetBackgroundStyleSolid;
    formSheet.backgroundOpacity = 0.2;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {

    }];
}

@end
