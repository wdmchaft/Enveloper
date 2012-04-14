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
    
    CGPoint point0;
    CGPoint point1;
    CGPoint point2;
    CGPoint point3;
        
    NSMutableArray * nodes;
}

// Core data stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // "Bridge" or connection between your code and the data store

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // Contains your schema; contains methods for deleting/adding data to data store

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // "Bridge" or connection between your application and physical files

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL) initContext:(CGSize)size;
- (void) drawToCache;
- (NSInteger) getStartNode;

@end
