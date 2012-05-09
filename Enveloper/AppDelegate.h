//
//  AppDelegate.h
//  Enveloper
//
//  Created by Christopher Latina on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>

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
    NSMutableArray            *dvcArray;
    
    PGMidiSource              *currmidi;
    const MIDIPacketList * currpacketList;
    
}

@property (strong, nonatomic) NSDate *currentTimeStamp;


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet MasterViewController *masterViewController;

@property (nonatomic,strong) PGMidi *midi;
@property (nonatomic,strong) NSMutableArray *dvcArray;

- (void) midiWrapper: (NSDictionary *)args;

- (Boolean) addTodvcArray: (DetailViewController *) dvc;
- (void) removefromdvcArray: (DetailViewController *) dvc atIndex: (NSInteger) i;
- (NSInteger) getdvcArrayCount;
- (Boolean) isdvc : (DetailViewController *) dvc inArrayAtIndex: (NSInteger) index;
- (DetailViewController *) getdvcAtIndex: (NSInteger) i;
- (DetailViewController *) getCurrentdvc;

- (const char *) ToStringFromBool:(BOOL) b;
- (NSString*) ToString:(PGMidiConnection*) connection;
- (NSString *)StringFromPacket:(const MIDIPacket *)packet;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
- (PGMidi *)getMidi;
- (NSURL *)applicationDocumentsDirectory;

@end
