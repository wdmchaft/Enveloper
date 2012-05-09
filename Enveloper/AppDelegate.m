//
//  AppDelegate.m
//  Enveloper
//
//  Created by Christopher Latina on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import "PGArc.h"

@interface AppDelegate ()  <PGMidiDelegate, PGMidiSourceDelegate>

@end

@implementation AppDelegate 

@synthesize currentTimeStamp;

@synthesize window = _window;
@synthesize detailViewController = _detailViewController;
@synthesize masterViewController = _masterViewController;

@synthesize midi, dvcArray;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
     masterViewController = [ MasterViewController alloc];
/*
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
        
        masterViewController = (MasterViewController *)masterNavigationController.topViewController;
        masterViewController.managedObjectContext = self.managedObjectContext;
        
    } else {
 */
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        masterViewController = (MasterViewController *)navigationController.topViewController;
        masterViewController.managedObjectContext = self.managedObjectContext;
    //}
    
    IF_IOS_HAS_COREMIDI
    (
     // We only create a MidiInput object on iOS versions that support CoreMIDI
     midi = [[PGMidi alloc] init];
     [midi enableNetwork:YES];
     self.midi = midi;
     
     )
    
    dvcArray =[[NSMutableArray alloc] initWithObjects:nil];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Enveloper" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Enveloper.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
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

- (PGMidi *)getMidi{
    return midi;
}


- (void) setMidi:(PGMidi*)m
{
    midi.delegate = nil;
    midi = m;
    midi.delegate = self;
    
    [self attachToAllExistingSources];
}

- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

/*

*/

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    source.delegate = self;
    NSLog(@"Source Removed");
    //[self updateCountLabel];
    //[self addString:[NSString stringWithFormat:@"Source added: %@", [self ToString:source]]];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    NSLog(@"Source Removed");
    //[self updateCountLabel];
    //[self addString:[NSString stringWithFormat:@"Source removed: %@", [self ToString:source]]];
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    NSLog(@"destinationAdded");
    //[self updateCountLabel];
    //[self addString:[NSString stringWithFormat:@"Desintation added: %@", [self ToString:destination]]];
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    NSLog(@"destinationRemoved");

    //[self updateCountLabel];
    //[self addString:[NSString stringWithFormat:@"Desintation removed: %@", [self ToString:destination]]];
}

- (void)midiSource:(PGMidiSource*)themidi midiReceived:(const MIDIPacketList *)packetList{
    NSLog(@"\n\nmidiReceived count is %d\n\n", dvcArray.count);
    
    //currmidi = themidi;
    //currpacketList = packetList;
    
    for (int i=0; i<[self getdvcArrayCount]; i++){
        /*
        NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:i], @"iter",
                               nil];
        
        [self performSelectorInBackground:@selector(midiWrapper) withObject:args];
        */
        DetailViewController * current = [dvcArray objectAtIndex:i];
        [current midiSource:themidi midiReceived:packetList];
    }
}
         
- (void) midiWrapper: (NSDictionary *)args{
    DetailViewController * current = [dvcArray objectAtIndex:[[args objectForKey:@"iter"] intValue]];
    [current midiSource:currmidi midiReceived:currpacketList];
}

-(const char *)ToStringFromBool:(BOOL) b { return b ? "yes":"no"; }

-(NSString *)ToString:(PGMidiConnection *) connection
{
    return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
            connection.name, [self ToStringFromBool: connection.isNetworkSession]];
}

-(NSString *)StringFromPacket:(const MIDIPacket *)packet
{
    // Note - this is not an example of MIDI parsing. I'm just dumping
    // some bytes for diagnostics.
    // See comments in PGMidiSourceDelegate for an example of how to
    // interpret the MIDIPacket structure.
    return [NSString stringWithFormat:@"  %u bytes: [%02x,%02x,%02x]",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0
            ];
}

-(NSInteger)IntFromPacket:(const MIDIPacket *)packet withIndex:(NSInteger)index
{
    // Note - this is not an example of MIDI parsing. I'm just dumping
    // some bytes for diagnostics.
    // See comments in PGMidiSourceDelegate for an example of how to
    // interpret the MIDIPacket structure.
    return (packet->length > index) ? packet->data[index] : 0;
}

- (Boolean) addTodvcArray: (DetailViewController *) dvc{
    Boolean exists = false;
    for (int i=0; i<[self getdvcArrayCount]; i++){
        if([self isdvc:dvc inArrayAtIndex: i]){
            exists = true;   
        }
    }
    if(!exists){
        [dvcArray addObject:dvc];
        return true;
    }
    return false;
}

- (DetailViewController *) getdvcAtIndex: (NSInteger) i{
    if(i<[self getdvcArrayCount]){
        return [dvcArray objectAtIndex:i];
    } else
        return NULL;
}


- (void) removefromdvcArray: (DetailViewController *) dvc atIndex: (NSInteger) i{
    if([self isdvc:dvc inArrayAtIndex: i]){
        [dvcArray removeObjectAtIndex: i];
    }
}

- (NSInteger) getdvcArrayCount{
    return dvcArray.count;
}

- (Boolean) isdvc : (DetailViewController *) dvc inArrayAtIndex: (NSInteger) index {
    if(![self getdvcAtIndex:index])
        return false;
    DetailViewController * current = [dvcArray objectAtIndex:index];
    if([current.timeStamp isEqualToString:dvc.timeStamp])
        return true;
    else
        return false;
}

- (DetailViewController *) getCurrentdvc{
    return detailViewController;
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc
{
#if ! PGMIDI_ARC
    [viewController release];
    [window release];
    [super dealloc];
#endif
}

@end
