//
//  MZPresentationViewController.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import "MZPresentationViewController.h"
#import "MZFormSheetPresentationController.h"

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
    controller.transitionStyle = MZFormSheetTransitionStyleBounce;
    [self presentViewController:controller animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
