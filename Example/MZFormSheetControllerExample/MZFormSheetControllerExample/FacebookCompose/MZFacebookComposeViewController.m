//
//  MZFacebookComposeViewController.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 10.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZFacebookComposeViewController.h"
#import "MZFormSheetController.h"

@interface MZFacebookComposeViewController ()

@end

@implementation MZFacebookComposeViewController

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
    UIImage *img = [[UIImage imageNamed:@"DEFacebookSendButtonPortrait"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [self.cancelButton setBackgroundImage:img forState:UIControlStateNormal];
    [self.postButton setBackgroundImage:img forState:UIControlStateNormal];
    
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCancelButton:nil];
    [self setPostButton:nil];
    [super viewDidUnload];
}
- (IBAction)close:(id)sender {
    [self dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}
@end
