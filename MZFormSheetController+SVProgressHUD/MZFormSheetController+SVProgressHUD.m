//
//  SVProgressHUD+MZFormSheetController.m
//  BookWhiz
//
//  Created by Michał Zaborowski on 25.07.2014.
//  Copyright (c) 2014 Railwaymen. All rights reserved.
//

#import "MZFormSheetController+SVProgressHUD.h"
#import <SVProgressHUD.h>

@interface SVProgressHUD ()
+ (SVProgressHUD*)sharedView;
- (UIControl *)overlayView;
@end

@interface MZProgressHUDObserver : NSObject
@end

@implementation MZProgressHUDObserver

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:SVProgressHUDWillAppearNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            
            for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
                if(![[window class] isEqual:[MZFormSheetBackgroundWindow class]]) {
                    
                    MZFormSheetController *formSheet = [[MZFormSheetController formSheetControllersStack] lastObject];
                    if(formSheet){
                        [[SVProgressHUD sharedView].overlayView removeFromSuperview];
                        [formSheet.formSheetWindow addSubview:[SVProgressHUD sharedView].overlayView];
                    }
                    break;
                    
                }
            }
        }];
    }
    return self;
}

@end

@implementation MZFormSheetController (SVProgressHUD)

+ (void)load
{
    [self sharedHUDObserver];
}

+ (MZProgressHUDObserver *)sharedHUDObserver {
    static MZProgressHUDObserver *_sharedHUDObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHUDObserver = [[MZProgressHUDObserver alloc] init];
    });
    
    return _sharedHUDObserver;
}


@end
