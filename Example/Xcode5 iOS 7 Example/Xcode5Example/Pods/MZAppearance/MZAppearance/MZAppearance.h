//
//  MZApperance.h
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

#import <Foundation/Foundation.h>

#define MZ_APPEARANCE_SELECTOR UI_APPEARANCE_SELECTOR

@protocol MZAppearance <NSObject>

/** 
 To customize the appearance of all instances of a class, send the relevant appearance modification messages to the appearance proxy for the class.
 */
+ (instancetype)appearance;
@end

@interface MZAppearance : NSObject

/** 
 Applies the appearance of all instances to the object. 
 */
- (void)applyInvocationTo:(id)target;

/**
 Applies the appearance of all instances to the object starting from the superclass 
 */
- (void)applyInvocationRecursivelyTo:(id)target upToSuperClass:(Class)superClass;

/** 
 Returns appearance for class 
 */
+ (id)appearanceForClass:(Class)aClass;

@end
