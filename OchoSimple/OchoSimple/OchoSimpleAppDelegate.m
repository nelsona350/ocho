//
//  OchoSimpleAppDelegate.m
//  OchoSimple
//
//  Created by Nelson on 4/27/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "OchoSimpleAppDelegate.h"
#import "GameKitHelper.h"

@implementation OchoSimpleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // check for first launch of newly installed app
    [[NSUserDefaults standardUserDefaults]
     registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
    
    // Set up the audio session
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
	
	// Create audio player with background music
	NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"silenceLong" ofType:@"wav"];
	NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
	NSError *error;
	backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
	[backgroundMusicPlayer setDelegate:self];  // We need this so we can restart after interruptions
	[backgroundMusicPlayer setNumberOfLoops:-1];	// Negative number means loop forever
    
    // Authenticate Player with Game Center
    [[GameKitHelper sharedGameKitHelper]
     authenticateLocalPlayer];

    
    return YES;
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self tryPlayMusic];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
	backgroundMusicInterrupted = YES;
	backgroundMusicPlaying = NO;
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *) player {
	if (backgroundMusicInterrupted) {
		[self tryPlayMusic];
		backgroundMusicInterrupted = NO;
	}
}

- (void)tryPlayMusic {
	
	// Check to see if iPod music is already playing
	UInt32 propertySize = sizeof(otherMusicIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherMusicIsPlaying);
	
	// Play the music if no other music is playing and we aren't playing already
	if (otherMusicIsPlaying != 1 && !backgroundMusicPlaying) {
		[backgroundMusicPlayer prepareToPlay];
		[backgroundMusicPlayer play];
		backgroundMusicPlaying = YES;
	}
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}

@end
