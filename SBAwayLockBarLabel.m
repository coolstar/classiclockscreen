//
//  SBAwayLockBarLabel.m
//  ClassicLockScreen
//
//  Created by coolstar on 1/25/14.
//  Copyright (c) 2014 CoolStar. All rights reserved.
//

#import "SBAwayLockBarLabel.h"

static const CGFloat gradientWidth = 0.2;
static const CGFloat gradientDimAlpha = 0.5;
static const int animationFramesPerSec = 16;

@interface SBAwayLockBarLabel () {
    CGFloat gradientLocations[3];
    NSTimer *animationTimer;
}

@end

@implementation SBAwayLockBarLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFont:(UIFont *)font {
    float fontSize = font.pointSize;
    float width = 400;
    while (width > self.bounds.size.width){
        fontSize -= 1;
        width = [self.text sizeWithFont:[UIFont fontWithName:font.fontName size:fontSize]].width;
    }
    [super setFont:[UIFont fontWithName:font.fontName size:fontSize]];
}

- (void) startTimer {
    if (!animationTimer) {
        _animationTimerCount = 0;
        [self setGradientLocations:0];
        animationTimer = [NSTimer
                           scheduledTimerWithTimeInterval:1.0/animationFramesPerSec
                           target:self
                           selector:@selector(animationTimerFired:)
                           userInfo:nil
                           repeats:YES];
    }
}

- (void) stopTimer {
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

- (void)animationTimerFired:(NSTimer*)theTimer {
    if (self.layer.delegate != self)
        self.layer.delegate = self;
    // Let the timer run for 2 * FPS rate before resetting.
    // This gives one second of sliding the highlight off to the right, plus one
    // additional second of uniform dimness
    if (++_animationTimerCount == (2 * animationFramesPerSec)) {
        _animationTimerCount = 0;
    }
    
    // Update the gradient for the next frame
    [self setGradientLocations:((CGFloat)_animationTimerCount/(CGFloat)animationFramesPerSec)];
}

- (void) setGradientLocations:(CGFloat) leftEdge {
    // Subtract the gradient width to start the animation with the brightest
    // part (center) of the gradient at left edge of the label text
    leftEdge -= gradientWidth;
    
    //position the bright segment of the gradient, keeping all segments within the range 0..1
    gradientLocations[0] = leftEdge < 0.0 ? 0.0 : (leftEdge > 1.0 ? 1.0 : leftEdge);
    gradientLocations[1] = MIN(leftEdge + gradientWidth, 1.0);
    gradientLocations[2] = MIN(gradientLocations[1] + gradientWidth, 1.0);
    
    // Re-render the label text
    [self.layer setNeedsDisplay];
}

// label's layer delegate method
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
    if (theContext == nil)
        return;
    // Set the font
    CGSize size = [self.text sizeWithFont:self.font];
    float height = size.height;
    float width = size.width;
    
    // Set Text Matrix
    CGAffineTransform xform = CGAffineTransformMake(1.0,  0.0,
                                                    0.0, -1.0,
                                                    0.0,  0.0);
    CGContextSetTextMatrix(theContext, xform);
    
    // Set Drawing Mode to clipping path, to clip the gradient created below
    CGContextSetTextDrawingMode (theContext, kCGTextClip);
    
    // Draw the label's text
    /*CGContextShowTextAtPoint(
                             theContext,
                             (self.bounds.size.width - width)/2.0,
                             (size_t)self.font.ascender,
                             text,
                             strlen(text));*/
    UIGraphicsPushContext(theContext);
    NSDictionary *textAttributes = @{NSFontAttributeName:self.font};
    [self.text drawAtPoint:CGPointMake((self.bounds.size.width - width)/2.0, ((self.bounds.size.height-height)/2.0)-2) withAttributes:textAttributes];
    UIGraphicsPopContext();
    
    // Calculate text width
    CGPoint textEnd = CGContextGetTextPosition(theContext);
    
    // Get the foreground text color from the UILabel.
    // Note: UIColor color space may be either monochrome or RGB.
    // If monochrome, there are 2 components, including alpha.
    // If RGB, there are 4 components, including alpha.
    CGColorRef textColor = self.textColor.CGColor;
    const CGFloat *components = CGColorGetComponents(textColor);
    size_t numberOfComponents = CGColorGetNumberOfComponents(textColor);
    BOOL isRGB = (numberOfComponents == 4);
    CGFloat red = components[0];
    CGFloat green = isRGB ? components[1] : components[0];
    CGFloat blue = isRGB ? components[2] : components[0];
    CGFloat alpha = isRGB ? components[3] : components[1];
    
    // The gradient has 4 sections, whose relative positions are defined by
    // the "gradientLocations" array:
    // 1) from 0.0 to gradientLocations[0] (dim)
    // 2) from gradientLocations[0] to gradientLocations[1] (increasing brightness)
    // 3) from gradientLocations[1] to gradientLocations[2] (decreasing brightness)
    // 4) from gradientLocations[3] to 1.0 (dim)
    size_t num_locations = 3;
    
    // The gradientComponents array is a 4 x 3 matrix. Each row of the matrix
    // defines the R, G, B, and alpha values to be used by the corresponding
    // element of the gradientLocations array
    CGFloat gradientComponents[12];
    for (int row = 0; row < num_locations; row++) {
        int index = 4 * row;
        gradientComponents[index++] = red;
        gradientComponents[index++] = green;
        gradientComponents[index++] = blue;
        gradientComponents[index] = alpha * gradientDimAlpha;
    }
    
    // If animating, set the center of the gradient to be bright (maximum alpha)
    // Otherwise it stays dim (as set above) leaving the text at uniform
    // dim brightness
    if (animationTimer) {
        gradientComponents[7] = alpha;
    }
    
    // Load RGB Colorspace
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // Create Gradient
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents,
                                                                  gradientLocations, num_locations);
    // Draw the gradient (using label text as the clipping path)
    CGContextDrawLinearGradient (theContext, gradient, self.bounds.origin, textEnd, 0);
    
    // Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [self stopTimer];
}

@end
