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
        //source.delegate = self;
        [source addDelegate:self];
    }
}

//const char *ToString(BOOL b) { return b ? "yes":"no"; }

const char *ToToString(bool b) { return b ? "yes":"no"; }

NSString *ToString(PGMidiConnection *connection)
{
    return [NSString stringWithFormat:@"< PGMidiConnection: name=%@ isNetwork=%s >",
            connection.name, ToToString(connection.isNetworkSession)];
}

NSString *StringFromPacket(const MIDIPacket *packet)
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
	//source.delegate = self;
    [source addDelegate:self];
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

- (void) midiSource:(PGMidiSource*)source midiReceived:(const MIDIPacketList *)packetList
{
    [self performSelectorOnMainThread:@selector(addString:)
                           withObject:@"MIDI received:"
                        waitUntilDone:NO];
	
    
    UInt32 numPacket = packetList->numPackets;
    UInt32 packetBufferSize = sizeof(UInt32) + numPacket * sizeof(NoteMidiPacket);
    
    MIDIPacketList *octavePacketList = malloc(packetBufferSize);
    
    MIDIPacket *octavePacket = MIDIPacketListInit(octavePacketList);
    
    const MIDIPacket *packet = &packetList->packet[0];
    
    int statusByte;
    int status;
    Byte data[3];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        statusByte = packet->data[0];
        status = statusByte >= 0xf0 ? statusByte : statusByte >> 4 << 4;
        if ((status == 0x90 || status == 0x80) && packet->data[1] <= 115)
        {
            data[0] = packet->data[0];
            data[1] = packet->data[1] + 12; //add an octave
            data[2] = packet->data[2];
            
            octavePacket = MIDIPacketListAdd(octavePacketList,
                                             packetBufferSize,
                                             octavePacket,
                                             packet->timeStamp,
                                             3,
                                             data);
        }
        packet = MIDIPacketNext(packet);
    }
    
    [self.midi sendPacketList: packetList];
    [self.midi sendPacketList: octavePacketList];
}

- (void)viewDidUnload {
	[self setTextView:nil];
	[super viewDidUnload];
}
@end
