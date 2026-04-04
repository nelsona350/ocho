//
//  OptionsViewController.h
//  OchoSimple
//
//  Created by Nelson on 5/17/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsViewController;

@protocol OptionsViewControllerDelegate <NSObject>
- (void)optionsViewControllerApplyOptions:(OptionsViewController *)controller
                            flipDisplayOn:(bool)flipDisplaySwitchValue
                        unlimitedRoundsOn:(bool)unlimitedRoundsSwitchValue
                                  soundOn:(bool)soundSwitchValue
                               playerName:(NSString*)playerName
                                  coinSet:(int)selectedCoinSet;
@end


@interface OptionsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *flipDisplaySwitch;
@property (strong, nonatomic) IBOutlet UISwitch *unlimitedRoundsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *playerNameEntry;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UIScrollView *coinSetScroll;
- (IBAction)selectGray:(id)sender;
- (IBAction)selectYellow:(id)sender;
- (IBAction)selectPink:(id)sender;
- (IBAction)selectOrange:(id)sender;
- (IBAction)selectPurple:(id)sender;
- (IBAction)selectRed:(id)sender;
- (IBAction)selectBlue:(id)sender;
- (IBAction)selectGreen:(id)sender;
- (IBAction)selectBlack:(id)sender;


@property(nonatomic, assign) BOOL flipDisplayEnabled,unlimitedRoundsEnabled,soundEnabled;
@property(nonatomic, retain) NSString *playerName;
@property(nonatomic, assign) int coinSet;
@property(nonatomic, retain) NSMutableArray *unlockedCoinSets;


@property (nonatomic, weak) id <OptionsViewControllerDelegate> delegate;

- (IBAction)apply:(id)sender;
- (IBAction)setNewPlayerName:(id)sender;


@end
