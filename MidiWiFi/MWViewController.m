//
//  MWViewController.m
//  MidiWiFi
//
//  Created by Olivier Scherler on 27.01.13.
//  Copyright (c) 2013 Olivier Scherler. All rights reserved.
//

#import <CoreMIDI/CoreMIDI.h>

#import "MWViewController.h"
#import "iOSVersionDetection.h"

@interface MWViewController ()

@end

@implementation MWViewController

@synthesize midi;
@synthesize textView;

- (IBAction) clearTextView
{
    textView.text = nil;
}

- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in midi.sources)
    {
        source.delegate = self;
    }
}

//const char *ToString(BOOL b) { return b ? "yes":"no"; }

const char *ToToString(bool b) { return b ? "yes":"no"; }

NSString *ToString(PGMidiConnection *connection)
{
    return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
            connection.name, ToToString(connection.isNetworkSession)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMidi:(PGMidi*)m
{
	[self addString: @"setMidi"];
	
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

- (IBAction) listAllInterfaces
{
    //IF_IOS_HAS_COREMIDI
    //({
        [self addString:@"\n\nInterface list:"];
        for (PGMidiSource *source in midi.sources)
        {
            NSString *description = [NSString stringWithFormat:@"Source: %@", ToString(source)];
            [self addString:description];
        }
        [self addString:@""];
        for (PGMidiDestination *destination in midi.destinations)
        {
            NSString *description = [NSString stringWithFormat:@"Destination: %@", ToString(destination)];
            [self addString:description];
        }
    //})
}

- (IBAction)refresh:(id)sender {
	[self listAllInterfaces];
}

- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
	source.delegate = self;
    //[self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source added: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    //[self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Source removed: %@", ToString(source)]];
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    //[self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation added: %@", ToString(destination)]];
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    //[self updateCountLabel];
    [self addString:[NSString stringWithFormat:@"Desintation removed: %@", ToString(destination)]];
}

- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    /*
	[self performSelectorOnMainThread:@selector(addString:)
                           withObject:@"MIDI received:"
                        waitUntilDone:NO];
	
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        [self performSelectorOnMainThread:@selector(addString:)
                               withObject:StringFromPacket(packet)
                            waitUntilDone:NO];
        packet = MIDIPacketNext(packet);
    }
	/**/
}

- (void)viewDidUnload {
	[self setTextView:nil];
	[super viewDidUnload];
}
@end
