//
//  NSInvocation+Copy.m
//  MZFormSheetControllerExample
//
//  Created by Michał Zaborowski on 17.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//
// Code also pulled from https://github.com/jorbsd/JBBContinuations/blob/master/Classes/JBBObjectProxy.m

#import "NSInvocation+Copy.h"
#import <string.h>

BOOL jbb_strStartsWith(const char *aString, const char *aPrefix) {
    return strncmp(aPrefix, aString, strlen(aPrefix)) == 0;
}

BOOL jbb_strCaseStartsWith(const char *aString, const char *aPrefix) {
    return strncasecmp(aPrefix, aString, strlen(aPrefix)) == 0;
}

const char* jbb_removeObjCTypeQualifiers(const char *aType) {
    // get rid of the following ObjC Type Encoding qualifiers:
    // r, n, N, o, O, R, V
    //
    // although it would be better not to hard code them they are
    // discarded by @encode(), but present in -[NSMethodSignature methodReturnType]
    // and -[NSMethodSignaure getArgumentTypeAtIndex:]

    if (jbb_strCaseStartsWith(aType, "r") || jbb_strCaseStartsWith(aType, "n") || jbb_strCaseStartsWith(aType, "o") || jbb_strStartsWith(aType, "V")) {
        char *newString = (char *)malloc(sizeof(aType) - 1);
        strncpy(newString, aType + 1, sizeof(aType) - 1);
        const char *returnString = jbb_removeObjCTypeQualifiers(newString);
        free(newString);
        return returnString;
    } else {
        return aType;
    }
}

BOOL jbb_ObjCTypeStartsWith(const char *objCType, const char *targetChar) {
    const char *newObjCType = jbb_removeObjCTypeQualifiers(objCType);

    return strncmp(newObjCType, targetChar, 1);
}

BOOL jbb_areObjCTypesEqual(const char *lhs, const char *rhs) {
    const char *newLhs = jbb_removeObjCTypeQualifiers(lhs);
    const char *newRhs = jbb_removeObjCTypeQualifiers(rhs);

    return strcmp(newLhs, newRhs) == 0;
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

            const char *typeForArg = [self.methodSignature getArgumentTypeAtIndex:index];

            // handle common types
            if (jbb_areObjCTypesEqual(typeForArg, @encode(char))) {
                char arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(unsigned char))) {
                unsigned char arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(short))) {
                short arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(unsigned short))) {
                unsigned short arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(int))) {
                int arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(unsigned int))) {
                unsigned int arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(long))) {
                long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(unsigned long))) {
                unsigned long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(long long))) {
                long long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(unsigned long long))) {
                unsigned long long arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(float))) {
                float arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(double))) {
                double arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(id))) {
                char buffer[sizeof(intmax_t)];
                [self getArgument:(void *)&buffer atIndex:i + 2];
                [invocation setArgument:(void *)&buffer atIndex:i + 2];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(SEL))) {
                SEL arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(Class))) {
                Class arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(char *))) {
                char *arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(NSRange))) {
                NSRange arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(CGPoint))) {
                CGPoint arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(CGSize))) {
                CGSize arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_areObjCTypesEqual(typeForArg, @encode(CGRect))) {
                CGRect arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_ObjCTypeStartsWith(typeForArg, "^")) {
                // generic pointer, including function pointers

                void *arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else if (jbb_ObjCTypeStartsWith(typeForArg, "@")) {
                // most likely a block, handle like a function pointer

                id arg;
                [self getArgument:&arg atIndex:index];
                [invocation setArgument:&arg atIndex:index];
            } else {
                NSAssert1(false, @"Unhandled ObjC Type (%s)", typeForArg);
            }

        }
    }
    
    return invocation;
}

@end
