//
//  MZApperance.m
//  MZAppearance
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

#import "MZAppearance.h"

static NSMutableDictionary *instanceOfClassesDictionary = nil;

@interface MZAppearance ()
@property (strong, nonatomic) Class mainClass;
@property (strong, nonatomic) NSMutableArray *invocations;
@end

@implementation MZAppearance

- (id)initWithClass:(Class)thisClass
{
    _mainClass = thisClass;
    _invocations = [NSMutableArray array];
    
    return self;
}

- (void)applyInvocationTo:(id)target
{
    for (NSInvocation *invocation in self.invocations) {
        
        // Create a new copy of the stored invocation,
        // otherwise setting the new target, this will never be released
        // because the invocation in the array is still alive after the call
        
        NSInvocation *targetInvocation = [invocation copy];
        [targetInvocation setTarget:target];
        [targetInvocation invoke];
        targetInvocation = nil;
    }
}

- (void)applyInvocationRecursivelyTo:(id)target upToSuperClass:(Class)superClass
{
    NSMutableArray *classes = [NSMutableArray array];
    
    // We now need to first set the properties of the superclass
    for (Class class = [target class];
         [class isSubclassOfClass:superClass] || class == superClass;
         class = [class superclass]) {
        [classes addObject:class];
    }
    
    NSEnumerator *reverseClasses = [classes reverseObjectEnumerator];
    
    for (Class class in reverseClasses) {
        [[MZAppearance appearanceForClass:class] applyInvocationTo:target];
    }
}

+ (id)appearanceForClass:(Class)aClass
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instanceOfClassesDictionary = [[NSMutableDictionary alloc] init];
    });
    
    if (![instanceOfClassesDictionary objectForKey:NSStringFromClass(aClass)])
    {
        id appearance = [[self alloc] initWithClass:aClass];
        [instanceOfClassesDictionary setObject:appearance forKey:NSStringFromClass(aClass)];
        return appearance;
    }
    else {
        return [instanceOfClassesDictionary objectForKey:NSStringFromClass(aClass)];
    }
        
}

- (void)forwardInvocation:(NSInvocation *)anInvocation;
{
    [anInvocation setTarget:nil];
    [anInvocation retainArguments];
    
    [self.invocations addObject:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [self.mainClass instanceMethodSignatureForSelector:aSelector];
}

@end
