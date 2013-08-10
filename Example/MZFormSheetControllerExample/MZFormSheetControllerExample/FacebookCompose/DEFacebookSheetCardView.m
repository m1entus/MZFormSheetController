//
//  DEFacebookSheetCardView.m
//  DEFacebooker
//
//  Copyright (c) 2011 Double Encore, Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
//  in the documentation and/or other materials provided with the distribution. Neither the name of the Double Encore Inc. nor the names of its 
//  contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "DEFacebookSheetCardView.h"
#import <QuartzCore/QuartzCore.h>


@interface DEFacebookSheetCardView ()

@property (nonatomic, retain) UIView *backgroundView;

- (void)tweetSheetCardViewInit;

@end


@implementation DEFacebookSheetCardView

@synthesize backgroundView = _backgroundView;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self tweetSheetCardViewInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetSheetCardViewInit];
    }
    return self;
}


- (void)tweetSheetCardViewInit
{
    self.backgroundColor = [UIColor clearColor];  // So we can use any color in IB.
    
        // Add a border and a shadow.
//    self.layer.cornerRadius = 12.0f;
//    self.layer.borderWidth = 1.0f;
//    self.layer.borderColor = [UIColor colorWithWhite:0.17f alpha:1.0f].CGColor;
//    self.layer.shadowOpacity = 1.0f;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
//    self.layer.shadowRadius = 5.0f;
//    [self.layer needsDisplayOnBoundsChange:YES];
        // Add the background image.
        // We can't put the image on the root view because we need to clip the
        // edges, which we can't do if we want the shadow.
    self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
//    self.backgroundView.layer.masksToBounds = YES;
//    self.backgroundView.layer.cornerRadius = self.layer.cornerRadius + 1.0f;
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"DEFacebookCardBackground"]];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.backgroundView atIndex:0];
}


- (void)dealloc
{
    [_backgroundView release], _backgroundView = nil;
    
    [super dealloc];
}


#pragma mark - Superclass Overrides

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.backgroundView.frame = self.bounds;    
}


@end
