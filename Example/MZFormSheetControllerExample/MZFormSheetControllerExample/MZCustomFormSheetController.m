//
//  MZCustomForhSheetController.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 09.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZCustomFormSheetController.h"

@interface MZCustomFormSheetController ()

@end

@implementation MZCustomFormSheetController

- (void)customTransitionEntryWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock
{
    CGRect formSheetRect = self.presentedFSViewController.view.frame;
    CGRect originalFormSheetRect = formSheetRect;
    formSheetRect.origin.x = self.view.bounds.size.width;
    self.presentedFSViewController.view.frame = formSheetRect;
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                     animations:^{
                         self.presentedFSViewController.view.frame = originalFormSheetRect;
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}
- (void)customTransitionOutWithCompletionBlock:(MZFormSheetCompletionHandler)completionBlock
{
    CGRect formSheetRect = self.presentedFSViewController.view.frame;
    formSheetRect.origin.x = self.view.bounds.size.width;
    [UIView animateWithDuration:MZFormSheetControllerDefaultAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.presentedFSViewController.view.frame = formSheetRect;
                     }
                     completion:^(BOOL finished) {
                         if (completionBlock) {
                             completionBlock();
                         }
                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.transitionStyle = MZFormSheetTransitionStyleCustom;
}


@end
