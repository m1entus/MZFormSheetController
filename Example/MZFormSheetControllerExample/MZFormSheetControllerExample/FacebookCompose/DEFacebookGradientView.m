//
//  DETwitterGradientView.m
//  DETwitter
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

//  RENAMED to
//  DEFacebookGradientView.m
//  DEFacebook
//
//  Modified by Vladmir on 03/09/2012.
//  www.developers-life.com

#import "DEFacebookGradientView.h"


@interface DEFacebookGradientView ()

- (void)tweetGradientViewInit;

@end


@implementation DEFacebookGradientView

@synthesize centerOffset = _centerOffset;


#pragma mark - Setup & Teardown

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self tweetGradientViewInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tweetGradientViewInit];
    }
    return self;
}


- (void)tweetGradientViewInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}


#pragma mark - Superclass Overrides

- (void)drawRect:(CGRect)rect 
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (CGSizeEqualToSize(self.centerOffset, CGSizeZero) == NO) {
        center.x += self.centerOffset.width;
        center.y += self.centerOffset.height;
    }
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.0, 0.0, 0.0, 0.5,   // Start color
                              0.0, 0.0, 0.0, 0.7 }; // End color
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGFloat endRadius = [UIApplication sharedApplication].keyWindow.bounds.size.height / 2;
    CGContextDrawRadialGradient(currentContext, gradient, center, 50.0f, center, endRadius, options);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace); 
}


#pragma mark - Accessors

- (void)setCenterOffset:(CGSize)offset
{
    if (CGSizeEqualToSize(_centerOffset, offset) == NO) {
        _centerOffset = offset;
        [self setNeedsDisplay];
    }
}



@end
