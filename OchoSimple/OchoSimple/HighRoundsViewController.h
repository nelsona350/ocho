//
//  HighRoundsViewController.h
//  OchoSimple
//
//  Created by Nelson on 5/23/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighRoundsViewController : UIViewController

@property(nonatomic, retain) NSMutableArray *localHighRounds;
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
- (IBAction)dismissHighRounds:(id)sender;
- (IBAction)resetHighRounds:(id)sender;
- (void) reallyResetHighRounds:(id)sender;

@end
