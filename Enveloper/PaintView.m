//
//  PaintView.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"

@implementation PaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hue = 0.0;
        [self initContext:frame.size];
        
        nodeSize = frame.size.width/25.0;
        nodes = [[NSMutableArray alloc] init];

        
        startNode = CGPointMake(0.0f,0.0f);
        endNode = CGPointMake(frame.size.width, frame.size.height);
        cp1 = CGPointMake(frame.size.width/4.0, frame.size.height/4.0);
        cp2 = CGPointMake(frame.size.width*3.0/4.0, frame.size.height*3.0/4.0);
        [nodes addObject:[NSValue valueWithCGPoint:startNode]];
        [nodes addObject:[NSValue valueWithCGPoint:endNode]];
        [nodes addObject:[NSValue valueWithCGPoint:cp1]];
        [nodes addObject:[NSValue valueWithCGPoint:cp2]];
        
        //[self drawToCache];
    }
    return self;
}

- (BOOL) initContext:(CGSize)size {
	
	int bitmapByteCount;
	int	bitmapBytesPerRow;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow = (size.width * 4);
	bitmapByteCount = (bitmapBytesPerRow * size.height);
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	cacheBitmap = malloc( bitmapByteCount );
	if (cacheBitmap == NULL){
		return NO;
	}
	cacheContext = CGBitmapContextCreate (cacheBitmap, size.width, size.height, 8, bitmapBytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
	return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if([self isInControlPoint:startNode atTouch:[touch locationInView:self]]){
        startNode = [touch locationInView:self];
        
        if(startNode.x < 0)
            startNode.x = 0;
        if(startNode.x > 0)
            startNode.x = 0;
        if(startNode.y < 0)
            startNode.y=0;
        if(startNode.y > self.frame.size.height)
            startNode.y= self.frame.size.height;
    } else if([self isInControlPoint:cp1 atTouch:[touch locationInView:self]]){
        cp1 = [touch locationInView:self];
        
        if(cp1.x < 0)
            cp1.x = 0;
        if(cp1.x > self.frame.size.width)
            cp1.x = self.frame.size.width;
        if(cp1.y < 0)
            cp1.y=0;
        if(cp1.y > self.frame.size.height)
            cp1.y= self.frame.size.height;
    } else if([self isInControlPoint:cp2 atTouch:[touch locationInView:self]]){
        cp2 = [touch locationInView:self];
        
        if(cp2.x < 0)
            cp2.x = 0;
        if(cp2.x > self.frame.size.width)
            cp2.x = self.frame.size.width;
        if(cp2.y < 0)
            cp2.y=0;
        if(cp2.y > self.frame.size.height)
            cp2.y= self.frame.size.height;
    } else if([self isInControlPoint:endNode atTouch:[touch locationInView:self]]){
        endNode = [touch locationInView:self];
        
        if(endNode.x < self.frame.size.width)
            endNode.x = self.frame.size.width;
        if(endNode.x > self.frame.size.width)
            endNode.x = self.frame.size.width;
        if(endNode.y < 0)
            endNode.y=0;
        if(endNode.y > self.frame.size.height)
            endNode.y= self.frame.size.height;
    }
    
    [self setNeedsDisplay];
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesBegan:touches withEvent:event]; 
 
}

- (bool) isInControlPoint: (CGPoint) cp atTouch: (CGPoint) touchPoint
{
    double nodeRange = nodeSize*2;
    if(touchPoint.x < cp.x + nodeRange && touchPoint.x > cp.x - nodeRange && touchPoint.y < cp.y + nodeRange && touchPoint.y > cp.y - nodeRange)
       return true;
    else 
        return false;
}

- (void) drawControlPoint:(CGPoint)point{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
    CGContextFillEllipseInRect(context, CGRectMake(point.x-nodeSize/2.0f,point.y-nodeSize/2.0f,nodeSize,nodeSize));

}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);

    
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    // Draw a bezier curve with end points s,e and control points cp1,cp2
    CGContextMoveToPoint(context, startNode.x, startNode.y);
    CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, endNode.x, endNode.y);
    CGContextStrokePath(context);
    
    [self drawControlPoint:startNode];
    [self drawControlPoint:cp1];
    [self drawControlPoint:cp2];
    [self drawControlPoint:endNode];
    
    
    CGImageRelease(cacheImage);
}

- (NSInteger) getStartNode{
    return startNode.y/self.frame.size.height* 127;
}

- (NSInteger) getcp1{
    return cp1.y/self.frame.size.height* 127;
}

- (NSInteger) getcp2{
    return cp2.y/self.frame.size.height* 127;
}

- (NSInteger) getEndNode{
    return endNode.y/self.frame.size.height* 127;
}

@end
