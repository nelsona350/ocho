//
//  OptionsViewController.m
//  OchoSimple
//
//  Created by Nelson on 5/17/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "OptionsViewController.h"
#import "HighScoresViewController.h"
#import "BlockAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface OptionsViewController ()

@end

@implementation OptionsViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.flipDisplaySwitch setOn:self.flipDisplayEnabled];
    [self.soundSwitch setOn:self.soundEnabled];
    //[self.unlimitedRoundsSwitch setOn:self.unlimitedRoundsEnabled];
    
    if([self.playerName length] == 0)
    {
        self.playerName = @"Adam Zappl";
    }
    
    self.playerNameEntry.text = self.playerName;
    
    self.coinSetScroll.contentSize=CGSizeMake(164,164);
    self.coinSetScroll.layer.borderColor =
    [[UIColor whiteColor] CGColor];
    self.coinSetScroll.layer.borderWidth = 2;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)apply:(id)sender
{
    
    [self.delegate optionsViewControllerApplyOptions:self
                                       flipDisplayOn:self.flipDisplaySwitch.isOn
                                   unlimitedRoundsOn:self.unlimitedRoundsSwitch.isOn
                                             soundOn:self.soundSwitch.isOn
                                          playerName:self.playerName
                                          coinSet:self.coinSet];

}

- (IBAction)setNewPlayerName:(id)sender
{
    self.playerName = [(UITextField*) sender text];
    
    if([self.playerName length] == 0)
    {
        self.playerName = @"Adam Zappl";
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DisplayHighScores"])
	{
        HighScoresViewController *highScoresViewController = segue.destinationViewController;
        //highScoresViewController.localHighScores = self.localHighScores;
        
        highScoresViewController.scoreRank = 8;
        highScoresViewController.roundRanks = nil;
        
        highScoresViewController.selectedSegment = 0;
        highScoresViewController.pageName.text = @"HIGH SCORES";
        
    }
}


- (IBAction)selectBlack:(id)sender
{
    self.coinSet = 1;
}

- (IBAction)selectGreen:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:3]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 3;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, score 100 points or more in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {             
         }];
        
        [alert show];
    }
}

- (IBAction)selectYellow:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:5]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 5;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, score 200 points or more in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectPink:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:7]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 7;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, score 300 points or more in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectOrange:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:9]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 9;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, score 400 points or more in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectGray:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:2]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 2;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, pass round 1 in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectPurple:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:4]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 4;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, pass round 2 in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectRed:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:6]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 6;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, pass round 3 in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

- (IBAction)selectBlue:(id)sender
{
    if([self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:8]] || self.unlimitedRoundsEnabled)
    {
        self.coinSet = 8;
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"COIN SET LOCKED"
                                                       message:@"To unlock this coin set, pass round 4 in a game or upgrade to OCHO PLUS"];
        
        [alert setCancelButtonWithTitle:@"OK" block:^
         {
         }];
        
        [alert show];
    }
}

@end
