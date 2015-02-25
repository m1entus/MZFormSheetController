//
//  MZFormSheetPresentationControllerSegue.m
//  Xcode5Example
//
//  Created by Michał Zaborowski on 25.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import "MZFormSheetPresentationControllerSegue.h"

@implementation MZFormSheetPresentationControllerSegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if (self = [super initWithIdentifier:identifier source:source destination:destination]) {
        _formSheetPresentationController = [[MZFormSheetPresentationController alloc] initWithContentViewController:destination];
    }
    return self;
}

- (void)perform
{
    UIViewController *sourceViewController = [self sourceViewController];

    [sourceViewController presentViewController:self.formSheetPresentationController animated:YES completion:nil];
}

@end
