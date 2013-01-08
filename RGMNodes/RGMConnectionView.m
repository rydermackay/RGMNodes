//
//  RGMConnectionView.m
//  Node
//
//  Created by Ryder Mackay on 2013-01-05.
//  Copyright (c) 2013 Ryder Mackay. All rights reserved.
//

#import "RGMConnectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "RGMGeometry.h"
#import "RGMConnection.h"

@implementation RGMConnectionView

- (id)initWithConnection:(RGMConnection *)connection
{
    if (self = [super initWithFrame:CGRectZero]) {
        _connection = connection;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.opaque = NO;
    self.clipsToBounds = YES;
    self.clearsContextBeforeDrawing = YES;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setStartPoint:(CGPoint)startPoint
{
    if (CGPointEqualToPoint(_startPoint, startPoint)) {
        return;
    }
    
    _startPoint = startPoint;
    
    [self setNeedsDisplay];
}

- (void)setEndPoint:(CGPoint)endPoint
{
    if (CGPointEqualToPoint(_endPoint, endPoint)) {
        return;
    }
    
    _endPoint = endPoint;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat shadowOffsetY = [[UIScreen mainScreen] scale] * 1;
    CGContextSetShadowWithColor(context, CGSizeMake(0, shadowOffsetY), 0, [UIColor colorWithWhite:0 alpha:1].CGColor);
    
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint startPoint = self.startPoint;
    CGPoint endPoint = self.endPoint;
    CGPoint midpoint = CGPointMidPoint(startPoint, endPoint);
    
    static CGFloat offset = 5;
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:CGPointByApplyingTranslation(startPoint, CGPointMake(offset, 0))];
    [path addCurveToPoint:CGPointByApplyingTranslation(endPoint, CGPointMake(-offset, 0))
            controlPoint1:CGPointMake(midpoint.x, startPoint.y)
            controlPoint2:CGPointMake(midpoint.x, endPoint.y)];
    [path addLineToPoint:endPoint];
    
    [[UIColor yellowColor] setStroke];
    [path setLineWidth:[[UIScreen mainScreen] scale] * 3];
    [path setLineJoinStyle:kCGLineJoinRound];
    [path setLineCapStyle:kCGLineCapRound];
    [path strokeWithBlendMode:kCGBlendModeCopy alpha:1];
}


@end
