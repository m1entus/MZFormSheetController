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

@interface NSString (Encoding)

- (BOOL)mz_isFirstCharacterEqual:(NSString *)string;
- (BOOL)mz_isFirstCharacterCaseInsensitiveEqual:(NSString *)string;
- (NSString *)mz_stringByRemovingMethodEnodingQualifiers;

@end

@implementation NSString (Encoding)

- (BOOL)mz_isFirstCharacterEqual:(NSString *)string
{
    if (self.length < 1 || string.length < 1) {
        return NO;
    }
    return [[self substringToIndex:1] isEqualToString:[string substringToIndex:1]];
}

- (BOOL)mz_isFirstCharacterCaseInsensitiveEqual:(NSString *)string
{
    if (self.length < 1 || string.length < 1) {
        return NO;
    }
    return [[self substringToIndex:1] caseInsensitiveCompare:[string substringToIndex:1]] == NSOrderedSame;
}

- (NSString *)mz_stringByRemovingMethodEnodingQualifiers
{
    if ([self mz_isFirstCharacterCaseInsensitiveEqual:@"r"] ||
        [self mz_isFirstCharacterCaseInsensitiveEqual:@"n"] ||
        [self mz_isFirstCharacterCaseInsensitiveEqual:@"o"] ||
        [self mz_isFirstCharacterEqual:@"V"]) {
        return [self substringFromIndex:1];
    } else {
        return self;
    }
}

@end

BOOL mz_areObjCTypesEqual(NSString *argmuentType, const char *encodingType) {

    NSString *encoding = [NSString stringWithUTF8String:encodingType];
    return [[argmuentType mz_stringByRemovingMethodEnodingQualifiers] isEqualToString:[encoding mz_stringByRemovingMethodEnodingQualifiers]];
}

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

            NSString *argumentType = [NSString stringWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:index]];

            if (mz_areObjCTypesEqual(argumentType, @encode(char))) {
                char arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(unsigned char))) {
                unsigned char arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(bool))) {
                bool arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(short))) {
                short arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(unsigned short))) {
                unsigned short arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(int))) {
                int arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(unsigned int))) {
                unsigned int arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(long))) {
                long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(unsigned long))) {
                unsigned long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(long long))) {
                long long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(unsigned long long))) {
                unsigned long long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(float))) {
                float arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(double))) {
                double arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(id))) {
                char buffer[sizeof(intmax_t)];
                [self getArgument:(void *)&buffer atIndex:i + 2];
                [invocation setArgument:(void *)&buffer atIndex:i + 2];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(SEL))) {
                SEL arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(Class))) {
                Class arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(char *))) {
                char *arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(NSRange))) {
                NSRange arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(CGPoint))) {
                CGPoint arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(CGSize))) {
                CGSize arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (mz_areObjCTypesEqual(argumentType, @encode(CGRect))) {
                CGRect arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if ([argumentType mz_isFirstCharacterEqual:@"^"]) {
                // generic pointer, including function pointers

                void *arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if ([argumentType mz_isFirstCharacterEqual:@"@"]) {
                // most likely a block, handle like a function pointer

                id arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else {
                NSAssert1(false, @"Unhandled ObjC Type (%@)", argumentType);
                return nil;
            }

        }
    }

    return invocation;
}

@end
