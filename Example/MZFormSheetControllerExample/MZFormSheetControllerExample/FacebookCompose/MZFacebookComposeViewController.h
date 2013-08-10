//
//  MZFacebookComposeViewController.h
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 10.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZFacebookComposeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

- (IBAction)close:(id)sender;

@end
