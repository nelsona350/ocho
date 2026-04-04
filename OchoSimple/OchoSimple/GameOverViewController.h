//
//  GameOverViewController.h
//  OchoSimple
//
//  Created by Nelson on 5/21/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameOverViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic, assign) int finalScore,roundNumber,bestRound,closestCall,scoreRank,bestRoundNumber,roundRank;
@property(nonatomic, retain) NSMutableArray *localHighScores,*localHighRounds,*roundScores,
*roundRanks;
@property(nonatomic, retain) NSString *playerName,*plistPath,*plistPathRnd;

@property (weak, nonatomic) IBOutlet UILabel *finalScoreText;
@property (weak, nonatomic) IBOutlet UILabel *bestRoundText;
@property (weak, nonatomic) IBOutlet UILabel *closestCallText;
@property (weak, nonatomic) IBOutlet UILabel *roundNumberText;

- (IBAction)dismissGameOver:(id)sender;
- (IBAction)tweetScore:(id)sender;
- (IBAction)facebookScore:(id)sender;

@end
