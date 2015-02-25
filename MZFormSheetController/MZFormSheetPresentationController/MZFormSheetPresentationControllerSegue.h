//
//  MZFormSheetPresentationControllerSegue.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 25.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetPresentationController.h"

@interface MZFormSheetPresentationControllerSegue : UIStoryboardSegue
@property (nonatomic, strong) MZFormSheetPresentationController *formSheetPresentationController;
@end
