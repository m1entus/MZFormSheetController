//
//  MZApperance.h
//  MZAppearance
//
//  Created by Michał Zaborowski on 17.08.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MZ_APPEARANCE_SELECTOR UI_APPEARANCE_SELECTOR

@protocol MZAppearance <NSObject>

/** 
 To customize the appearance of all instances of a class, send the relevant appearance modification messages to the appearance proxy for the class.
 */
+ (id)appearance;
@end

@interface MZAppearance : NSProxy

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
