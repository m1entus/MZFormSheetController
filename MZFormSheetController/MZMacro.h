//
//  MZMacro.h
//  Xcode5Example
//
//  Created by Michał Zaborowski on 28.08.2014.
//  Copyright (c) 2014 Michał Zaborowski. All rights reserved.
//

#if defined(__GNUC__) && ((__GNUC__ >= 4) || ((__GNUC__ == 3) && (__GNUC_MINOR__ >= 1)))
#define MZ_DEPRECATED_ATTRIBUTE(message) __attribute__((deprecated(message)))
#else
#define MZ_DEPRECATED_ATTRIBUTE(message)
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.2
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1129.15
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_2
#define kCFCoreFoundationVersionNumber_iOS_8_2 1142.16
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.1
#endif

#define MZSystemVersionGreaterThanOrEqualTo_iOS7() (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define MZSystemVersionGreaterThanOrEqualTo_iOS8() (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0)
#define MZSystemVersionGreaterThanOrEqualTo_iOS9() (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_8_2)
#define MZSystemVersionLessThan_iOS8() !MZSystemVersionGreaterThanOrEqualTo_iOS8()
