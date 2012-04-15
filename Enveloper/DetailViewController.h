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
    
    PaintView * paint;
    
    PGMidi *midi;
}
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
@property (strong, nonatomic) IBOutlet UISwitch *holdSwitch;
@property (strong, nonatomic) NSTimer * clockTimer;
@property (strong, nonatomic) NSTimer * loopTimer;


- (IBAction) sliderChanged : (id)sender;
- (IBAction) sendMidiDataFromSlider: (NSInteger)sliderVal;
- (IBAction) changeChannel : (id)sender;
-(IBAction) changeLSB:(id)sender;
-(IBAction) changeMSB:(id)sender;
- (void)sendClockTick;
- (void) sendMidiClockInBG;
@end