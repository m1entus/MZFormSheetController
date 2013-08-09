//
//  MZSampleViewController.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 09.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZSampleViewController.h"
#import "MZFormSheetController.h"

@interface MZSampleViewController ()

@end

@implementation MZSampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)modal:(id)sender {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"modal"] animated:YES completion:nil];
}
- (IBAction)close:(id)sender
{
    [self dismissFormSheetControllerWithCompletionHandler:^(MZFormSheetController *formSheetController) {
       //do sth
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
