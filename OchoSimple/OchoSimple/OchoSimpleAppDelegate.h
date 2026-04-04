//
//  OchoSimpleAppDelegate.h
//  OchoSimple
//
//  Created by Nelson on 4/27/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface OchoSimpleAppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>
{
	AVAudioPlayer *backgroundMusicPlayer;
	BOOL backgroundMusicPlaying;
	BOOL backgroundMusicInterrupted;
	UInt32 otherMusicIsPlaying;
}

@property (strong, nonatomic) UIWindow *window;

@end
