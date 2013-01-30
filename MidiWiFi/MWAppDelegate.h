//
//  MWAppDelegate.h
//  MidiWiFi
//
//  Created by Olivier Scherler on 27.01.13.
//  Copyright (c) 2013 Olivier Scherler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MWViewController.h"

@class PGMidi;

@interface MWAppDelegate : UIResponder <UIApplicationDelegate>
{
	MWViewController *viewController;
    PGMidi                    *midi;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet MWViewController *viewController;

@end
