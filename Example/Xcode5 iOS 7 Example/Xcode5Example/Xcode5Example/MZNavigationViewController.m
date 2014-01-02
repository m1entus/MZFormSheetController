//
//  MZNavigationViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 23.10.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZNavigationViewController.h"

@interface MZNavigationViewController ()

@end

@implementation MZNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent; // your own style
//}

//- (BOOL)prefersStatusBarHidden {
//    return YES; // your own visibility code
//}

@end
