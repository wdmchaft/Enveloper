//
//  AppDelegate.h
//  Enveloper
//
//  Created by Christopher Latina on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterViewController;
@class DetailViewController;
@class PGMidi; 

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow                  *window;
    DetailViewController      *detailViewController;
    MasterViewController      *masterViewController;
    PGMidi                    *midi;
    NSDate                    *currentTimeStamp;
}

@property (strong, nonatomic) NSDate *currentTimeStamp;


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet MasterViewController *masterViewController;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
