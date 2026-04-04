//
//  HighScoresViewController.h
//  OchoSimple
//
//  Created by Nelson on 5/23/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoresViewController : UIViewController

@property(nonatomic, retain) NSMutableArray *localHighScores,*localHighRounds,*roundRanks;
@property(nonatomic, assign) int selectedSegment,scoreRank;
@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UILabel *name2;
@property (weak, nonatomic) IBOutlet UILabel *name3;
@property (weak, nonatomic) IBOutlet UILabel *name4;
@property (weak, nonatomic) IBOutlet UILabel *name5;
@property (weak, nonatomic) IBOutlet UILabel *name6;
@property (weak, nonatomic) IBOutlet UILabel *name7;
@property (weak, nonatomic) IBOutlet UILabel *name8;
@property (weak, nonatomic) IBOutlet UILabel *score1;
@property (weak, nonatomic) IBOutlet UILabel *score2;
@property (weak, nonatomic) IBOutlet UILabel *score3;
@property (weak, nonatomic) IBOutlet UILabel *score4;
@property (weak, nonatomic) IBOutlet UILabel *score5;
@property (weak, nonatomic) IBOutlet UILabel *score6;
@property (weak, nonatomic) IBOutlet UILabel *score7;
@property (weak, nonatomic) IBOutlet UILabel *score8;
@property (weak, nonatomic) IBOutlet UILabel *round1;
@property (weak, nonatomic) IBOutlet UILabel *round2;
@property (weak, nonatomic) IBOutlet UILabel *round3;
@property (weak, nonatomic) IBOutlet UILabel *round4;
@property (weak, nonatomic) IBOutlet UILabel *round5;
@property (weak, nonatomic) IBOutlet UILabel *round6;
@property (weak, nonatomic) IBOutlet UILabel *round7;
@property (weak, nonatomic) IBOutlet UILabel *round8;
@property (weak, nonatomic) IBOutlet UILabel *roundColumn;
@property (weak, nonatomic) IBOutlet UILabel *pageName;
@property (weak, nonatomic) IBOutlet UILabel *scoreColumn;
@property (weak, nonatomic) IBOutlet UILabel *nameColumn;
- (IBAction)dismissHighScores:(id)sender;
- (IBAction)resetHighScores:(id)sender;
- (void) reallyResetHighScores:(id)sender;
- (IBAction)switchSegment:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentSelector;

@end
