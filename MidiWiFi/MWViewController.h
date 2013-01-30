//
//  MWViewController.h
//  MidiWiFi
//
//  Created by Olivier Scherler on 27.01.13.
//  Copyright (c) 2013 Olivier Scherler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PGMidi.h"

@interface MWViewController : UIViewController <PGMidiDelegate, PGMidiSourceDelegate>
{
	//PGMidi *midi;
}

@property (nonatomic,assign) PGMidi *midi;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction) listAllInterfaces;
- (IBAction)refresh:(id)sender;

@end
