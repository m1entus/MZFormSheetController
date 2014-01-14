//
//  MZTableViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 03.01.2014.
//  Copyright (c) 2014 Michał Zaborowski. All rights reserved.
//

#import "MZTableViewController.h"
#import "MZFormSheetController.h"

@interface MZTableViewController ()

@end

@implementation MZTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.textField becomeFirstResponder];

    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.formSheetController setNeedsStatusBarAppearanceUpdate];
    }];
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent; // your own style
}

- (BOOL)prefersStatusBarHidden {
    return NO; // your own visibility code
}

@end
