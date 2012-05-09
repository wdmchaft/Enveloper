//
//  PaintView.h
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaintView : UIView {
    void *cacheBitmap;
    CGContextRef cacheContext;
    float hue;
    
    CGPoint startNode;
    CGPoint cp1;
    CGPoint cp2;
    CGPoint endNode;
        
    double nodeSize;
    
    CGRect indicatorPoint;
    CGRect indicatorPoint2;

            
    NSMutableArray * nodes;
}

- (BOOL) initContext:(CGSize)size;
- (void) drawToCache;
- (NSInteger) getStartNode;
- (NSInteger) getcp1;
- (NSInteger) getcp2;
- (NSInteger) getEndNode;
- (double) getStartNodeX;
- (double) getcp1X;
- (double) getcp2X;
- (double) getEndNodeX;

- (CGPoint) getfullcp1;
- (CGPoint) getfullcp2;
- (CGPoint) getfullstartNode;
- (CGPoint) getfullendNode;
- (void) setfullstartNode: (CGPoint) point;
- (void) setfullendNode: (CGPoint) point;
- (void) setfullcp1: (CGPoint) point;
- (void) setfullcp2: (CGPoint) point;

- (void) setIndicatorPoint: (CGRect) indic;
- (void) setIndicatorPoint2: (CGRect) indic;

- (bool) isInControlPoint: (CGPoint) cp atTouch: (CGPoint) touchPoint;

@end
