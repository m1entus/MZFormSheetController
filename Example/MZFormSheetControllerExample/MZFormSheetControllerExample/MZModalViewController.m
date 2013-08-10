//
//  MZModalViewController.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 10.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZModalViewController.h"
#import "MZFormSheetController.h"

@interface MZModalViewController ()

@end

@implementation MZModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)modal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
