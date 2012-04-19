//
//  DetailViewController.m
//  Enveloper
//
//  Created by Christopher Latina on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()  <PGMidiDelegate, PGMidiSourceDelegate>
- (void) updateCountLabel;
- (void) addString:(NSString*)string;
- (void) sendMidiDataInBackground;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark PGMidiDelegate
@synthesize countLabel;
@synthesize textView;
@synthesize midi;

@synthesize graph = _graph;
@synthesize holdSwitch = _holdSwitch;
@synthesize tempoLabel = _tempoLabel;
@synthesize tempoStepper;
@synthesize channelLabel = _channelLabel;
@synthesize channelStepper;
@synthesize LSBLabel;
@synthesize LSBStepper;
@synthesize MSBLabel;
@synthesize MSBStepper;
@synthesize slidr = _slidr;
@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize clockTimer;
@synthesize loopTimer;
@synthesize loopThread;
@synthesize MeasureLabel, MeasureStepper, BeatLabel, BeatStepper;


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    
    channel = 1;
    tempo = 120;
    tempoStepper.value = tempo;
    LSB = 2;
    MSB = 2;
    timeCounter = 0;
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    paint = [[PaintView alloc] initWithFrame:_graph.bounds];
    [_graph addSubview:paint];
    
    IF_IOS_HAS_COREMIDI
    (
     // We only create a MidiInput object on iOS versions that support CoreMIDI
     midi = [[PGMidi alloc] init];
     [midi enableNetwork:YES];
     self.midi = midi;

     )
    
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    [self clearTextView];
    [self updateCountLabel];
    
    IF_IOS_HAS_COREMIDI
    (
     [self addString:@"This iOS Version supports CoreMIDI"];
     )
    else
    {
        [self addString:@"You are running iOS before 4.2. CoreMIDI is not supported."];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return NO;
    
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
     
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark IBActions

- (IBAction) clearTextView
{
    textView.text = nil;
}

-(const char *)ToStringFromBool:(BOOL) b { return b ? "yes":"no"; }

-(NSString *)ToString:(PGMidiConnection *) connection
{
    return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
            connection.name, [self ToStringFromBool: connection.isNetworkSession]];
}
- (IBAction) listAllInterfaces
{
    IF_IOS_HAS_COREMIDI
    ({
        [self addString:@"\n\nInterface list:"];
        for (PGMidiSource *source in midi.sources)
        {
            NSString *description = [NSString stringWithFormat:@"Source: %@", [self ToString:source]];
            [self addString:description];
        }
        [self addString:@""];
        for (PGMidiDestination *destination in midi.destinations)
        {
            NSString *description = [NSString stringWithFormat:@"Destination: %@", [self ToString:destination]];
            [self addString:description];
        }
    })
}

- (IBAction) sendMidiData
{
    [self performSelectorInBackground:@selector(sendMidiDataInBackground) withObject:nil];
    NSLog(@"MIDI SENT");
}

#pragma mark Shenanigans

- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

- (void) setMidi:(PGMidi*)m
{
    midi.delegate = nil;
    midi = m;
    midi.delegate = self;
    
    [self attachToAllExistingSources];
}

- (void) addString:(NSString*)string
{
    NSString *newText = [textView.text stringByAppendingFormat:@"\n%@", string];
    textView.text = newText;
    
    if (newText.length)
        [textView scrollRangeToVisible:(NSRange){newText.length-1, 1}];
}

- (void) updateCountLabel
{
    countLabel.text = [NSString stringWithFormat:@"sources=%u destinations=%u", midi.sources.count, midi.destinations.count];
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    source.delegate = self;
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source added: %@", [self ToString:source]]];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source removed: %@", [self ToString:source]]];
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation added: %@", [self ToString:destination]]];
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    [self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation removed: %@", [self ToString:destination]]];
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

- (void)midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    
    //if(![_holdSwitch isOn]){
        /*
        [self performSelectorOnMainThread:@selector(addString:)
                               withObject:@"MIDI received:"
                            waitUntilDone:NO];
        */
        const MIDIPacket *packet = &packetList->packet[0];
        for (int i = 0; i < packetList->numPackets; ++i)
        {
       /*    [self performSelectorOnMainThread:@selector(addString:)
                                   withObject: [self StringFromPacket: packet]
                                waitUntilDone:NO];
         */   
            
            /* Set LSB and MSB to non-time clock or noteOn/Off start/stop signals */
            NSLog(@"midi received");
            
           
                NSString * packetString = [self StringFromPacket:packet];
                if( [self IntFromPacket:packet withIndex:0] != 248){                
                    //NSLog(@"\n\nMIDI PACKET: %@", packetString);
                    if([_holdSwitch selectedSegmentIndex] == 0){ 
                    if( [self IntFromPacket:packet withIndex:1] == 98){
                        LSB = [self IntFromPacket:packet withIndex:2];
                        [LSBStepper setValue:LSB];
                        [LSBLabel performSelectorOnMainThread:@selector(setText:)
                                                   withObject: [NSString stringWithFormat:@"%d", LSB]
                                                waitUntilDone:NO];
                        NSLog(@"\n\nMIDI PACKET: %@, LSB: %d", packetString, LSB);

                    }
                    else if( [self IntFromPacket:packet withIndex:1] == 99){
                        MSB = [self IntFromPacket:packet withIndex:2];
                        [MSBStepper setValue:MSB];
                        [MSBLabel performSelectorOnMainThread:@selector(setText:)
                                               withObject: [NSString stringWithFormat:@"%d", MSB]
                                            waitUntilDone:NO];
                        NSLog(@"\n\nMIDI PACKET: %@, MSB: %d", packetString, MSB);
                    }
                    }

                } else{
                    if(looping){ 
                        [self performSelectorInBackground:@selector(sendSweepFromGraph) withObject:nil];
                    }
                }
        
           
            
            
            /*Make function to calculate tempo */
            packet = MIDIPacketNext(packet);
        }
    //}
}

- (void) sendMidiDataInBackground
{
    for (int n = 0; n < 20; ++n)
    {
        const UInt8 note      = n;
        const UInt8 noteOn[]  = { 0x90 + channel - 1, note, 127 };
        const UInt8 noteOff[] = { 0x80 + channel - 1, note, 0   };
        
        [midi sendBytes:noteOn size:sizeof(noteOn)];
        [NSThread sleepForTimeInterval:0.1];
        [midi sendBytes:noteOff size:sizeof(noteOff)];
    }
}

- (IBAction) sliderChanged : (id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSInteger sliderVal = (NSInteger) slider.value;
    [self sendMidiDataFromSlider:sliderVal];
}

- (IBAction) sendMidiDataFromSlider: (NSInteger)sliderVal
{
    
    NSLog(@"%d", sliderVal);
    const UInt8 note      =  sliderVal;
    const UInt8 noteOn[]  = { 0x90 + channel - 1, note, 127};
    const UInt8 noteOff[] = { 0x80 + channel - 1, note, 0   };
    
    [midi sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:0.1];
    [midi sendBytes:noteOff size:sizeof(noteOff)];
}

-(IBAction) setTempo:(id)sender
{
    
    UIStepper *stepper = (UIStepper *)sender;
    tempo = (NSInteger) stepper.value;
    
    [_tempoLabel setText:[NSString stringWithFormat:@"%d", tempo]];
}

-(IBAction) changeChannel:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    channel = (NSInteger) stepper.value;
    
    [_channelLabel setText:[NSString stringWithFormat:@"%d", channel]];
    
}

-(IBAction) changeLSB:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    LSB = (NSInteger) stepper.value;
    
    [LSBLabel setText:[NSString stringWithFormat:@"%d", LSB]];
    
}

-(IBAction) changeMSB:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    MSB = (NSInteger) stepper.value;
    
    [MSBLabel setText:[NSString stringWithFormat:@"%d", MSB]];
    
}
           
-(IBAction) toggleHold:(id)sender
{
    //UISwitch * theSwitch = (UISwitch *)sender;
    //_holdSwitch.on = theSwitch.on;
}

- (IBAction) loop{
    
    looping = true;
    timeCounter = 0;
    
    //[self performSelectorOnMainThread:@selector(sendMidiSweepInBG) withObject:nil waitUntilDone:NO];
    //loopThread = [[NSThread alloc] initWithTarget:self selector:@selector(sendMidiSweepInBG) object:nil];
    //[loopThread start];

    //[self performSelector:@selector(sendMidiSweepInBG) onThread:loopThread withObject:nil waitUntilDone:NO];
    //[self performSelectorInBackground:@selector(sendMidiSweepInBG) withObject:nil];
    
    // [self sendMidiClockInBG];
}

- (IBAction) play{
    [self performSelectorInBackground:@selector(sendMidiClockInBG) withObject:nil];

   // [self sendMidiClockInBG];
}
- (void) sendMidiClockInBG
{
    //Run this on a background thread
    playing = true;

    SInt32 latencyTime;
    //OSStatus result = MIDIObjectGetIntegerProperty(&midi, kMIDIPropertyAdvanceScheduleTimeMuSec, &latencyTime);
    
    const UInt8 start[]      = {250};
    
    //[midi sendBytes:start size:sizeof(start)];
    [midi sendQueuedMidi: start size:sizeof(start) atTime:mach_absolute_time()];
    NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
    clockTimer = [NSTimer timerWithTimeInterval: timeout target: self selector: @selector(sendClockTick) userInfo: nil repeats: TRUE];
    [[NSRunLoop currentRunLoop] addTimer:clockTimer forMode:NSDefaultRunLoopMode];

    
    NSInteger date = 100;
    while(playing)
    {
        ++date;
        // allow the run loop to run for, arbitrarily, 2 seconds
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:date]];
    }
     
}

- (void)sendClockTick
{
    if(playing){
        const UInt8 tick[]      = {248};
        [midi sendQueuedMidi: tick size:sizeof(tick) atTime:mach_absolute_time()];        
    }
}

- (void) sendMidiSweepInBG
{
    NSLog(@"\n\nTHREAD STARTED\n\n");
    //Run this on a background thread
    
    const UInt8 start[]      = {250};
    [midi sendQueuedMidi: start size:sizeof(start) atTime:mach_absolute_time()];
    
    NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
    loopTimer = [NSTimer timerWithTimeInterval: timeout target: self selector: @selector(sendSweepFromGraph) userInfo: nil repeats: TRUE];
    [[NSRunLoop currentRunLoop] addTimer:loopTimer forMode:NSDefaultRunLoopMode];
    
    
    NSInteger date = 100;
    while(looping)
    {
        ++date;
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:date]];
    }
     
    
}

-(void) sendSweepFromGraph{
    
    if(looping){
        
        double t = (timeCounter%96) / 96.0f;
        timeCounter++;
        
        //Out of 384 for 24 ticks per quarter note * 16 q notes
        
        //Run this on a background thread
        
        //Get slider value from datastore @ index, where index is ID
        NSInteger sliderVal = pow((1-t),3)*paint.getStartNode +
            3*pow((1-t),2)*t*paint.getcp1 +
            3*(1-t)*pow(t,2)*paint.getcp2 +
            pow(t,3)*paint.getEndNode;
                    
        int bit1 = 0xB0 + channel - 1;
        
        //SInt32 latencyTime;
        //OSStatus result = MIDIObjectGetIntegerProperty(&midi, kMIDIPropertyAdvanceScheduleTimeMuSec, &latencyTime);
        uint64_t time = mach_absolute_time();

        const UInt8 tick[]      = {248};
        [midi sendQueuedMidi: tick size:sizeof(tick) atTime:time];       
        
        const UInt8 LSBPacket[]      = {bit1, 98, LSB};
        [midi sendBytes:LSBPacket size:sizeof(LSBPacket)];  
        
        const UInt8 MSBPacket[]      = {bit1, 99, MSB};
        [midi sendBytes:MSBPacket size:sizeof(MSBPacket)];
        
        const UInt8 Data[]      = {bit1, 6, sliderVal};
        [midi sendBytes:Data size:sizeof(Data)];
        
        
        /*
        const UInt8 LSBPacket[]      = {bit1, 98, LSB};
        [midi sendQueuedMidi:LSBPacket size:sizeof(LSBPacket) atTime:time + result];  
        
        const UInt8 MSBPacket[]      = {bit1, 99, MSB};
        [midi sendQueuedMidi:MSBPacket size:sizeof(MSBPacket) atTime:time + result];
        
        const UInt8 Data[]      = {bit1, 6, sliderVal};
        [midi sendQueuedMidi:Data size:sizeof(Data) atTime:time + result];
      */
        
        /*
        const UInt8 LSBPacket2[]      = {bit1, 98, 42};
        [midi sendBytes:LSBPacket2 size:sizeof(LSBPacket)];
        
        const UInt8 MSBPacket2[]      = {bit1, 99, 2};
        [midi sendBytes:MSBPacket2 size:sizeof(MSBPacket)];
        
        const UInt8 Data2[]      = {bit1, 6, sliderVal};
        [midi sendBytes:Data2 size:sizeof(Data)];
         */
        
        NSLog(@"\n\nSLIDER %d LSB %d MSB %d\n", sliderVal, LSB, MSB);
    }
}

- (IBAction)stopClock{
    playing = false;
    const UInt8 stop[]     = {252};
    [midi sendQueuedMidi: stop size:sizeof(stop) atTime:mach_absolute_time()];
    
    [clockTimer invalidate];
}

- (IBAction)stopLoop{
    looping = false;
    const UInt8 stop[]     = {252};
    [midi sendQueuedMidi: stop size:sizeof(stop) atTime:mach_absolute_time()];
    [loopTimer invalidate];
}




@end
