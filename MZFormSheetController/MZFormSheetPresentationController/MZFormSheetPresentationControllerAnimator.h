//
//  MZFormSheetPresentationControllerAnimator.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 24.02.2015.
//  Copyright (c) 2015 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZFormSheetPresentationControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign, getter=isPresenting) BOOL presenting;
@end
