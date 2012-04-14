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
@synthesize theTimer;


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
    
    //return NO;
    
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
        //NSLog(@"midi received");
        if(![_holdSwitch isOn]){
            NSString * packetString = [self StringFromPacket:packet];
            if( [self IntFromPacket:packet withIndex:0] != 0xF8){                
                //NSLog(@"\n\nMIDI PACKET: %@", packetString);
                
                if( [self IntFromPacket:packet withIndex:1] == 98 && [self IntFromPacket:packet withIndex:2] != 100){
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
                //else {
                else if( [self IntFromPacket:packet withIndex:1] == 6){
                    int sliderVal = [self IntFromPacket:packet withIndex:2];
                    //[_slidr setValue:sliderVal];
                    NSLog(@"\n\nMIDI PACKET: %@, Data: %d", packetString, sliderVal);
                }

            }
        }
        
        /*Make function to calculate tempo */
        packet = MIDIPacketNext(packet);
    }
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
    UISwitch * theSwitch = (UISwitch *)sender;
    _holdSwitch.on = theSwitch.on;
}

- (IBAction) play{
    [self performSelectorInBackground:@selector(sendMidiClockInBG) withObject:nil];
    [self performSelectorInBackground:@selector(sendMidiSweepInBG) withObject:nil];

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
    theTimer = [NSTimer timerWithTimeInterval: timeout target: self selector: @selector(sendClockTick) userInfo: nil repeats: TRUE];
    [[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSDefaultRunLoopMode];

    
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
    //Run this on a background thread
    playing = true;
    
    SInt32 latencyTime;
    //OSStatus result = MIDIObjectGetIntegerProperty(&midi, kMIDIPropertyAdvanceScheduleTimeMuSec, &latencyTime);
        
    //[midi sendBytes:start size:sizeof(start)];

    NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
    theTimer = [NSTimer timerWithTimeInterval: timeout target: self selector: @selector(sendSweepFromGraph) userInfo: nil repeats: TRUE];
    [[NSRunLoop currentRunLoop] addTimer:theTimer forMode:NSDefaultRunLoopMode];
    
    
    NSInteger date = 100;
    while(playing)
    {
        ++date;
        // allow the run loop to run for, arbitrarily, 2 seconds
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:date]];
    }
    
}

-(void) sendSweepFromGraph{
    
    //playing = true;

    
    double t = (timeCounter%384) / 384.0f;
    timeCounter++;
    
    //Out of 384 for 24 ticks per quarter note * 16 q notes
    
    //Run this on a background thread
    
    /* CGPoint s = CGPointMake(0.0, point3.y);
     CGPoint e = CGPointMake(rect.size.width, 120.0);
     CGPoint cp1 = CGPointMake(120.0, 30.0);
     CGPoint cp2 = CGPointMake(210.0, 210.0);
     */
    
    //Get slider value from datastore @ index, where index is ID
    NSInteger sliderVal = pow((1-t),3)*paint.getStartNode + 3*pow((1-t),2)*t*30 + 3*(1-t)*pow(t,2)*120 + pow(t,3)*210;
        
    NSLog(@"\n\nSLIDER VAL IS %d", sliderVal);
    
    int bit1 = 0xB0 + channel - 1;
    
    const UInt8 LSBPacket[]      = {bit1, 98, LSB};
    [midi sendBytes:LSBPacket size:sizeof(LSBPacket)];
    [NSThread sleepForTimeInterval:0.01];
    
    const UInt8 MSBPacket[]      = {bit1, 99, MSB};
    [midi sendBytes:MSBPacket size:sizeof(MSBPacket)];
    [NSThread sleepForTimeInterval:0.01];
    
    const UInt8 Data[]      = {bit1, 6, sliderVal};
    [midi sendBytes:Data size:sizeof(Data)];
    
    NSLog(@"\n\nSLIDER %d LSB %d MSB %d\n", sliderVal, LSB, MSB);
}

- (IBAction) sendMidiClockInBackground
{
    //Run this on a background thread
    playing = true;
    
    //Send System Common Song Position Pointer
    //const UInt8 position[]      = {242,0,0};
    
    
    SInt32 latencyTime;
    OSStatus result = MIDIObjectGetIntegerProperty(&midi, kMIDIPropertyAdvanceScheduleTimeMuSec, &latencyTime);
    
    //NSLog(@"\n\nLatency: %ld, %ld", result, latencyTime);
    
    /* Get the timebase info */
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    
    uint64_t startTime = mach_absolute_time();
    
    //onTime += result * 1000000;
    
    //[midi sendQueuedMidi: position size:sizeof(position) atTime:onTime];    
    
    const UInt8 start[]      = {250};

    //[midi sendBytes:start size:sizeof(start)];
    [midi sendQueuedMidi: start size:sizeof(start) atTime:startTime];

    //uint64_t duration = mach_absolute_time() - startTime;
    
    //uint64_t sendTime = startTime;
    //Timeout is in seconds
    
    /*
    while(playing){
        const UInt8 tick[]      = {248};
        
        [midi sendQueuedMidi: tick size:sizeof(tick) atTime:mach_absolute_time()];
        NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
        [NSThread sleepForTimeInterval:timeout];

    }
    */
    
    NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
    [NSTimer scheduledTimerWithTimeInterval: timeout target: self selector: @selector(sendClockTick) userInfo: nil repeats: TRUE];  
     
    /*
    while(playing)
    {
        
        //[self performSelector:@selector(sendClockTick) withObject:nil afterDelay: timeout];
        

        
        
        //Duration is in nanoseconds
        NSLog(@"\n\n\nduration is:%llu\n\n\n", duration);        

        
        const UInt8 tick[]      = {248};
        
        //Timeout is in seconds
        NSTimeInterval timeout = 1.0/((tempo*24)/60.0);
        //NSTimeInterval timeout = 0.020833;
        
        NSLog(@"\n\n\nTimeout is:%f\n\n\n", timeout);
        
        // Convert to nanoseconds 
        duration *= info.numer;
        duration /= info.denom;
        duration = timeout*1000000;
        // Convert back 
        duration /= info.numer;
        duration *= info.denom;
        
        sendTime = mach_absolute_time() + result;
        [midi sendQueuedMidi: tick size:sizeof(tick) atTime:sendTime];
        //[midi sendBytes: tick size:sizeof(tick)];

        NSLog(@"\n\n\nsendTime is:%llu\n\n\n", sendTime);        
        NSLog(@"\n\n\nduration 2 is:%llu\n\n\n", duration);
        NSLog(@"\n\n\ncurr - sendTime is:%llu\n\n\n", currTime - sendTime);
        NSLog(@"\n\n\ntimeout2 is:%f\n\n\n", timeout - (mach_absolute_time() - sendTime)/1000000000);

        //[NSThread sleepForTimeInterval:timeout - (mach_absolute_time() - sendTime)/1000000000];
         
    }
     */
}

- (IBAction)stopClock{
    playing = false;
    const UInt8 stop[]     = {252};
    [midi sendQueuedMidi: stop size:sizeof(stop) atTime:mach_absolute_time()];
    
    [theTimer invalidate];
}

-(IBAction) sweepSlide: (id) sender
{
    [self performSelectorInBackground:@selector(sendSweepSlide) withObject:sender];
}

- (IBAction) sendSweepSlide: (id)sender
{
    //Run this on a background thread

    playing = true;
    

    UISlider *slider = (UISlider *)sender;
    NSInteger sliderVal = (NSInteger) slider.value;

    int bit1 = 0xB0 + channel - 1;
    
    const UInt8 LSBPacket[]      = {bit1, 98, LSB};
    [midi sendBytes:LSBPacket size:sizeof(LSBPacket)];
    [NSThread sleepForTimeInterval:0.01];

    const UInt8 MSBPacket[]      = {bit1, 99, MSB};
    [midi sendBytes:MSBPacket size:sizeof(MSBPacket)];
    [NSThread sleepForTimeInterval:0.01];

    const UInt8 Data[]      = {bit1, 6, sliderVal};
    [midi sendBytes:Data size:sizeof(Data)];
    
    NSLog(@"\n\nSLIDER %d LSB %d MSB %d\n", sliderVal, LSB, MSB);

 }




@end
