//
//  NSInvocation+Copy.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 17.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "NSInvocation+Copy.h"

@implementation NSInvocation (Copy)

// http://stackoverflow.com/questions/15732885/uiappearance-proxy-for-custom-objects

- (id)copy
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self.methodSignature];
    NSUInteger numberOfArguments = [[self methodSignature] numberOfArguments];
    
    [invocation setTarget:self.target];
    [invocation setSelector:self.selector];
    
    if (numberOfArguments > 2) {
        for (int i = 0; i < (numberOfArguments - 2); i++) {
            NSInteger index = i+2;
            
            const char *argumentType = [self.methodSignature getArgumentTypeAtIndex:index];
            
            NSUInteger argumentLength;
            NSGetSizeAndAlignment(argumentType, &argumentLength, NULL);
            
            void *buffer = malloc(argumentLength);
            
            [self getArgument:buffer atIndex:index];
            [invocation setArgument:buffer atIndex:index];
            
            free(buffer);
        }
    }
    
    return invocation;
}

@end
