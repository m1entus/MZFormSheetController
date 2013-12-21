//
//  MZCustomTransition.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 21.12.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZTransition.h"
#import "MZFormSheetController.h"

@interface MZCustomTransition : MZTransition
- (void)entryFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;
- (void)exitFormSheetControllerTransition:(MZFormSheetController *)formSheetController completionHandler:(MZTransitionCompletionHandler)completionHandler;
@end
