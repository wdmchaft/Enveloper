//
//  DetailViewController.h
//  Enveloper
//
//  Created by Christopher Latina on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>
#include <mach/mach.h>
#include <mach/mach_time.h>


@class PGMidi;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    UILabel    *countLabel;
    UITextView *textView;
    Boolean playing;
    Boolean looping;

    NSInteger tempo;
    NSInteger channel;
    NSInteger LSB;
    NSInteger MSB;
    NSInteger loadCount;
    NSInteger timeCounter;
    NSInteger beat;
    NSInteger measure;
    
    PaintView * paint;
    
    PGMidi *midi;
}

// Core data stuff
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext; // "Bridge" or connection between your code and the data store

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel; // Contains your schema; contains methods for deleting/adding data to data store

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator; // "Bridge" or connection between your application and physical files
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

#if ! __has_feature(objc_arc)

@property (nonatomic,retain) IBOutlet UILabel    *countLabel;
@property (nonatomic,retain) IBOutlet UITextView *textView;

@property (nonatomic,assign) PGMidi *midi;

#else

@property (nonatomic,strong) IBOutlet UILabel    *countLabel;
@property (nonatomic,strong) IBOutlet UITextView *textView;

@property (nonatomic,strong) PGMidi *midi;

#endif

- (IBAction) clearTextView;
- (IBAction) listAllInterfaces;
- (IBAction) sendMidiData;
- (IBAction) setTempo:(id)sender;

- (const char *) ToStringFromBool:(BOOL) b;
- (NSString*) ToString:(PGMidiConnection*) connection;
- (NSString *)StringFromPacket:(const MIDIPacket *)packet;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIView *graph;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UISlider *slidr;
@property (strong, nonatomic) IBOutlet UIStepper *tempoStepper;
@property (strong, nonatomic) IBOutlet UILabel *tempoLabel;
@property (strong, nonatomic) IBOutlet UIStepper *channelStepper;
@property (strong, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutlet UIStepper *LSBStepper;
@property (strong, nonatomic) IBOutlet UILabel *LSBLabel;
@property (strong, nonatomic) IBOutlet UIStepper *MSBStepper;
@property (strong, nonatomic) IBOutlet UILabel *MSBLabel;
@property (strong, nonatomic) IBOutlet UIStepper *BeatStepper;
@property (strong, nonatomic) IBOutlet UILabel *BeatLabel;
@property (strong, nonatomic) IBOutlet UIStepper *MeasureStepper;
@property (strong, nonatomic) IBOutlet UILabel *MeasureLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *holdSwitch;
@property (strong, nonatomic) NSTimer * clockTimer;
@property (strong, nonatomic) NSTimer * loopTimer;
@property (strong, nonatomic) NSThread * loopThread;


- (IBAction) sliderChanged : (id)sender;
- (IBAction) sendMidiDataFromSlider: (NSInteger)sliderVal;
- (IBAction) changeChannel : (id)sender;
- (IBAction) changeLSB:(id)sender;
- (IBAction) changeMSB:(id)sender;
- (IBAction) changeBeat:(id)sender;
- (IBAction) changeMeasure:(id)sender;

- (void)     sendClockTick;
- (void)     sendMidiClockInBG;
@end