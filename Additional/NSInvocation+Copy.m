//
//  NSInvocation+Copy.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 17.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "NSInvocation+Copy.h"

@implementation NSInvocation (Copy)

// http://stackoverflow.com/questions/15732885/uiappearance-proxy-for-custom-objects

- (id)copy
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
    NSUInteger numberOfArguments = [[self methodSignature] numberOfArguments];
    
    [invocation setTarget:self.target];
    [invocation setSelector:self.selector];
    
    if (numberOfArguments > 2) {
        for (int i = 0; i < (numberOfArguments - 2); i++) {
            char buffer[sizeof(intmax_t)];
            [self getArgument:(void *)&buffer atIndex:i + 2];
            [invocation setArgument:(void *)&buffer atIndex:i + 2];
        }
    }
    
    return invocation;
}

@end
