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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent; // your own style
//}

//- (BOOL)prefersStatusBarHidden {
//    return YES; // your own visibility code
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

@end
