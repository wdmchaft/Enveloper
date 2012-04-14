//
//  PaintView.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import "Event.h"
#import "MidiControl.h"

@implementation PaintView


@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hue = 0.0;
        [self initContext:frame.size];
        
        nodes = [[NSMutableArray alloc] init];
        CGPoint pointStart = CGPointMake(0.0f,0.0f);
        [nodes addObject:[NSValue valueWithCGPoint:pointStart]];
        
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
    point0 = CGPointMake(-1, -1);
    point1 = CGPointMake(-1, -1); // previous previous point
    point2 = CGPointMake(-1, -1); // previous touch point
    point3 = [touch locationInView:self]; // current touch point
    

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self];

    if(point3.x < 0)
        point3.x = 0;
    if(point3.y < 0)
        point3.y=0;
    if(point3.y > 127)
        point3.y=127;
        
    //[self drawToCache];
    [self setNeedsDisplay];    
}

- (void) drawToCache {
    if(point1.x > -1){
        
        /*

        //hue += 0.005;
        if(hue > 1.0) hue = 0.0;
        UIColor *color = [UIColor colorWithHue:hue saturation:0.3 brightness:1.0 alpha:1.0];
        
        
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
        CGContextSetLineWidth(cacheContext, 3);
        
        
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        CGContextStrokePath(cacheContext);
        
        CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
        [self seNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
         */
    }
    
    
;}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    
    for(NSValue *node in nodes){
        CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 1.0);
        CGContextFillEllipseInRect(context, CGRectMake(10.0,30.0,30.0,30.0));
    }
    
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    // Draw a bezier curve with end points s,e and control points cp1,cp2
    CGPoint s = CGPointMake(0.0, point3.y);
    CGPoint e = CGPointMake(rect.size.width, 120.0);
    CGPoint cp1 = CGPointMake(120.0, 30.0);
    CGPoint cp2 = CGPointMake(210.0, 210.0);
    CGContextMoveToPoint(context, s.x, s.y);
    CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
    CGContextStrokePath(context);
    
    
    CGImageRelease(cacheImage);
}

- (NSInteger) getStartNode{
    return point3.y;
}

#pragma mark - Core Data stack

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Instance" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Instance.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

@end
