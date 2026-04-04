//
//  HighScoresViewController.m
//  OchoSimple
//
//  Created by Nelson on 5/23/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "HighScoresViewController.h"
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "BlockTextPromptAlertView.h"

@interface HighScoresViewController ()

@end

@implementation HighScoresViewController

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
    
    // load local high scores
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighScores.plist"];
    
    bool success = [fileManager fileExistsAtPath:plistPath];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighScores.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }
    
    fileManager = [NSFileManager defaultManager];
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPathRnd = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    
    success = [fileManager fileExistsAtPath:plistPath];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPathRnd error:&error];
    }
    
    self.localHighScores = [NSMutableArray arrayWithContentsOfFile:plistPath];
    self.localHighRounds = [NSMutableArray arrayWithContentsOfFile:plistPathRnd];
    
    // load local high scores
    self.segmentSelector.selectedSegmentIndex = self.selectedSegment;
    if(self.segmentSelector.selectedSegmentIndex == 0)
    {
        self.pageName.text = @"HIGH SCORES";

        self.name1.text = self.localHighScores[0][@"name"];
        self.name2.text = self.localHighScores[1][@"name"];
        self.name3.text = self.localHighScores[2][@"name"];
        self.name4.text = self.localHighScores[3][@"name"];
        self.name5.text = self.localHighScores[4][@"name"];
        self.name6.text = self.localHighScores[5][@"name"];
        self.name7.text = self.localHighScores[6][@"name"];
        self.name8.text = self.localHighScores[7][@"name"];
        
        self.score1.text = self.localHighScores[0][@"score"];
        self.score2.text = self.localHighScores[1][@"score"];
        self.score3.text = self.localHighScores[2][@"score"];
        self.score4.text = self.localHighScores[3][@"score"];
        self.score5.text = self.localHighScores[4][@"score"];
        self.score6.text = self.localHighScores[5][@"score"];
        self.score7.text = self.localHighScores[6][@"score"];
        self.score8.text = self.localHighScores[7][@"score"];
        
        self.round1.text = self.localHighScores[0][@"round"];
        self.round2.text = self.localHighScores[1][@"round"];
        self.round3.text = self.localHighScores[2][@"round"];
        self.round4.text = self.localHighScores[3][@"round"];
        self.round5.text = self.localHighScores[4][@"round"];
        self.round6.text = self.localHighScores[5][@"round"];
        self.round7.text = self.localHighScores[6][@"round"];
        self.round8.text = self.localHighScores[7][@"round"];
        
        self.score1.frame = CGRectMake(134,96,70,24);
        self.score2.frame = CGRectMake(134,128,70,24);
        self.score3.frame = CGRectMake(134,160,70,24);
        self.score4.frame = CGRectMake(134,192,70,24);
        self.scoreColumn.frame = CGRectMake(134,64,70,24);
        
        self.name1.frame = CGRectMake(20,96,106,24);
        self.name2.frame = CGRectMake(20,128,106,24);
        self.name3.frame = CGRectMake(20,160,106,24);
        self.name4.frame = CGRectMake(20,192,106,24);
        self.nameColumn.frame = CGRectMake(20,64,106,24);
        
        // show all
        [self.name5 setHidden:NO];
        [self.name6 setHidden:NO];
        [self.name7 setHidden:NO];
        [self.name8 setHidden:NO];
        
        [self.score5 setHidden:NO];
        [self.score6 setHidden:NO];
        [self.score7 setHidden:NO];
        [self.score8 setHidden:NO];
        
        [self.round1 setHidden:NO];
        [self.round2 setHidden:NO];
        [self.round3 setHidden:NO];
        [self.round4 setHidden:NO];
        [self.round5 setHidden:NO];
        [self.round6 setHidden:NO];
        [self.round7 setHidden:NO];
        [self.round8 setHidden:NO];
        [self.roundColumn setHidden:NO];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];
        
        if(self.scoreRank == 0)
        {
            [self.name1 setTextColor:[UIColor orangeColor]];
            [self.score1 setTextColor:[UIColor orangeColor]];
            [self.round1 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 1)
        {
            [self.name2 setTextColor:[UIColor orangeColor]];
            [self.score2 setTextColor:[UIColor orangeColor]];
            [self.round2 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 2)
        {
            [self.name3 setTextColor:[UIColor orangeColor]];
            [self.score3 setTextColor:[UIColor orangeColor]];
            [self.round3 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 3)
        {
            [self.name4 setTextColor:[UIColor orangeColor]];
            [self.score4 setTextColor:[UIColor orangeColor]];
            [self.round4 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 4)
        {
            [self.name5 setTextColor:[UIColor orangeColor]];
            [self.score5 setTextColor:[UIColor orangeColor]];
            [self.round5 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 5)
        {
            [self.name6 setTextColor:[UIColor orangeColor]];
            [self.score6 setTextColor:[UIColor orangeColor]];
            [self.round6 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 6)
        {
            [self.name7 setTextColor:[UIColor orangeColor]];
            [self.score7 setTextColor:[UIColor orangeColor]];
            [self.round7 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 7)
        {
            [self.name8 setTextColor:[UIColor orangeColor]];
            [self.score8 setTextColor:[UIColor orangeColor]];
            [self.round8 setTextColor:[UIColor orangeColor]];
        }


    }
    else
    {
        self.pageName.text = @"HIGH SINGLE ROUNDS";

        self.name1.text = self.localHighRounds[0][@"name"];
        self.name2.text = self.localHighRounds[1][@"name"];
        self.name3.text = self.localHighRounds[2][@"name"];
        self.name4.text = self.localHighRounds[3][@"name"];
        self.name5.text = self.localHighRounds[4][@"name"];
        self.name6.text = self.localHighRounds[5][@"name"];
        self.name7.text = self.localHighRounds[6][@"name"];
        self.name8.text = self.localHighRounds[7][@"name"];
        
        self.score1.text = self.localHighRounds[0][@"score"];
        self.score2.text = self.localHighRounds[1][@"score"];
        self.score3.text = self.localHighRounds[2][@"score"];
        self.score4.text = self.localHighRounds[3][@"score"];
        self.score5.text = self.localHighRounds[4][@"score"];
        self.score6.text = self.localHighRounds[5][@"score"];
        self.score7.text = self.localHighRounds[6][@"score"];
        self.score8.text = self.localHighRounds[7][@"score"];
        
        self.round1.text = self.localHighRounds[0][@"round"];
        self.round2.text = self.localHighRounds[1][@"round"];
        self.round3.text = self.localHighRounds[2][@"round"];
        self.round4.text = self.localHighRounds[3][@"round"];
        self.round5.text = self.localHighRounds[4][@"round"];
        self.round6.text = self.localHighRounds[5][@"round"];
        self.round7.text = self.localHighRounds[6][@"round"];
        self.round8.text = self.localHighRounds[7][@"round"];
        
        self.score1.frame = CGRectMake(179,96,70,24);
        self.score2.frame = CGRectMake(179,128,70,24);
        self.score3.frame = CGRectMake(179,160,70,24);
        self.score4.frame = CGRectMake(179,192,70,24);
        self.scoreColumn.frame = CGRectMake(179,64,70,24);
        
        self.name1.frame = CGRectMake(65,96,106,24);
        self.name2.frame = CGRectMake(65,128,106,24);
        self.name3.frame = CGRectMake(65,160,106,24);
        self.name4.frame = CGRectMake(65,192,106,24);
        self.nameColumn.frame = CGRectMake(65,64,106,24);
        
        // only show top 4, don't show round number
        [self.name5 setHidden:YES];
        [self.name6 setHidden:YES];
        [self.name7 setHidden:YES];
        [self.name8 setHidden:YES];

        [self.score5 setHidden:YES];
        [self.score6 setHidden:YES];
        [self.score7 setHidden:YES];
        [self.score8 setHidden:YES];
        
        [self.round1 setHidden:YES];
        [self.round2 setHidden:YES];
        [self.round3 setHidden:YES];
        [self.round4 setHidden:YES];
        [self.round5 setHidden:YES];
        [self.round6 setHidden:YES];
        [self.round7 setHidden:YES];
        [self.round8 setHidden:YES];
        [self.roundColumn setHidden:YES];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];
        
        for(int i = 0; i < [self.roundRanks count]; i++)
        {
            int roundRankLocal = [[self.roundRanks objectAtIndex:i] integerValue];
            
            if(roundRankLocal == 0)
            {
                [self.name1 setTextColor:[UIColor orangeColor]];
                [self.score1 setTextColor:[UIColor orangeColor]];
                [self.round1 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 1)
            {
                [self.name2 setTextColor:[UIColor orangeColor]];
                [self.score2 setTextColor:[UIColor orangeColor]];
                [self.round2 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 2)
            {
                [self.name3 setTextColor:[UIColor orangeColor]];
                [self.score3 setTextColor:[UIColor orangeColor]];
                [self.round3 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 3)
            {
                [self.name4 setTextColor:[UIColor orangeColor]];
                [self.score4 setTextColor:[UIColor orangeColor]];
                [self.round4 setTextColor:[UIColor orangeColor]];
            }
        }

    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissHighScores:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)resetHighScores:(id)sender
{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RESET HIGH SCORES?"
                                                    message:@"This will reset the high scores to the defaults."
                                                   delegate:self
                                          cancelButtonTitle:@"CANCEL"
                                          otherButtonTitles:@"RESET", nil];
    
    [alert show];*/
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"RESET HIGH SCORES?" message:@"This will reset the high scores to the defaults."];
    
    [alert setCancelButtonWithTitle:@"CANCEL" block:nil];
        
    [alert setDestructiveButtonWithTitle:@"RESET" block:^
    {
        [self reallyResetHighScores:nil];
    }];

    [alert show];

}


- (void) reallyResetHighScores:(id)sender;
{

    // reset scores by copying default plist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighScores.plist"];
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighScores.plist"];
    [fileManager removeItemAtPath:plistPath error:&error];
    [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    
    NSString *plistPathRnd = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    
    defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    [fileManager removeItemAtPath:plistPathRnd error:&error];
    [fileManager copyItemAtPath:defaultPath toPath:plistPathRnd error:&error];
    
    
    self.localHighScores = [NSMutableArray arrayWithContentsOfFile:plistPath];
    self.localHighRounds = [NSMutableArray arrayWithContentsOfFile:plistPathRnd];
    
    // reload local high scores after reset
    if(self.segmentSelector.selectedSegmentIndex == 0)
    {
        self.pageName.text = @"HIGH SCORES";

        self.name1.text = self.localHighScores[0][@"name"];
        self.name2.text = self.localHighScores[1][@"name"];
        self.name3.text = self.localHighScores[2][@"name"];
        self.name4.text = self.localHighScores[3][@"name"];
        self.name5.text = self.localHighScores[4][@"name"];
        self.name6.text = self.localHighScores[5][@"name"];
        self.name7.text = self.localHighScores[6][@"name"];
        self.name8.text = self.localHighScores[7][@"name"];
        
        self.score1.text = self.localHighScores[0][@"score"];
        self.score2.text = self.localHighScores[1][@"score"];
        self.score3.text = self.localHighScores[2][@"score"];
        self.score4.text = self.localHighScores[3][@"score"];
        self.score5.text = self.localHighScores[4][@"score"];
        self.score6.text = self.localHighScores[5][@"score"];
        self.score7.text = self.localHighScores[6][@"score"];
        self.score8.text = self.localHighScores[7][@"score"];
        
        self.round1.text = self.localHighScores[0][@"round"];
        self.round2.text = self.localHighScores[1][@"round"];
        self.round3.text = self.localHighScores[2][@"round"];
        self.round4.text = self.localHighScores[3][@"round"];
        self.round5.text = self.localHighScores[4][@"round"];
        self.round6.text = self.localHighScores[5][@"round"];
        self.round7.text = self.localHighScores[6][@"round"];
        self.round8.text = self.localHighScores[7][@"round"];
        
        self.score1.frame = CGRectMake(134,96,70,24);
        self.score2.frame = CGRectMake(134,128,70,24);
        self.score3.frame = CGRectMake(134,160,70,24);
        self.score4.frame = CGRectMake(134,192,70,24);
        self.scoreColumn.frame = CGRectMake(134,64,70,24);
        
        self.name1.frame = CGRectMake(20,96,106,24);
        self.name2.frame = CGRectMake(20,128,106,24);
        self.name3.frame = CGRectMake(20,160,106,24);
        self.name4.frame = CGRectMake(20,192,106,24);
        self.nameColumn.frame = CGRectMake(20,64,106,24);
        
        // show all
        [self.name5 setHidden:NO];
        [self.name6 setHidden:NO];
        [self.name7 setHidden:NO];
        [self.name8 setHidden:NO];
        
        [self.score5 setHidden:NO];
        [self.score6 setHidden:NO];
        [self.score7 setHidden:NO];
        [self.score8 setHidden:NO];
        
        [self.round1 setHidden:NO];
        [self.round2 setHidden:NO];
        [self.round3 setHidden:NO];
        [self.round4 setHidden:NO];
        [self.round5 setHidden:NO];
        [self.round6 setHidden:NO];
        [self.round7 setHidden:NO];
        [self.round8 setHidden:NO];
        [self.roundColumn setHidden:NO];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];
     
    }
    else
    {
        self.pageName.text = @"HIGH SINGLE ROUNDS";

        self.name1.text = self.localHighRounds[0][@"name"];
        self.name2.text = self.localHighRounds[1][@"name"];
        self.name3.text = self.localHighRounds[2][@"name"];
        self.name4.text = self.localHighRounds[3][@"name"];
        self.name5.text = self.localHighRounds[4][@"name"];
        self.name6.text = self.localHighRounds[5][@"name"];
        self.name7.text = self.localHighRounds[6][@"name"];
        self.name8.text = self.localHighRounds[7][@"name"];
        
        self.score1.text = self.localHighRounds[0][@"score"];
        self.score2.text = self.localHighRounds[1][@"score"];
        self.score3.text = self.localHighRounds[2][@"score"];
        self.score4.text = self.localHighRounds[3][@"score"];
        self.score5.text = self.localHighRounds[4][@"score"];
        self.score6.text = self.localHighRounds[5][@"score"];
        self.score7.text = self.localHighRounds[6][@"score"];
        self.score8.text = self.localHighRounds[7][@"score"];
        
        self.round1.text = self.localHighRounds[0][@"round"];
        self.round2.text = self.localHighRounds[1][@"round"];
        self.round3.text = self.localHighRounds[2][@"round"];
        self.round4.text = self.localHighRounds[3][@"round"];
        self.round5.text = self.localHighRounds[4][@"round"];
        self.round6.text = self.localHighRounds[5][@"round"];
        self.round7.text = self.localHighRounds[6][@"round"];
        self.round8.text = self.localHighRounds[7][@"round"];
        
        self.score1.frame = CGRectMake(179,96,70,24);
        self.score2.frame = CGRectMake(179,128,70,24);
        self.score3.frame = CGRectMake(179,160,70,24);
        self.score4.frame = CGRectMake(179,192,70,24);
        self.scoreColumn.frame = CGRectMake(179,64,70,24);
        
        self.name1.frame = CGRectMake(65,96,106,24);
        self.name2.frame = CGRectMake(65,128,106,24);
        self.name3.frame = CGRectMake(65,160,106,24);
        self.name4.frame = CGRectMake(65,192,106,24);
        self.nameColumn.frame = CGRectMake(65,64,106,24);
        
        // only show top 4, don't show round number
        [self.name5 setHidden:YES];
        [self.name6 setHidden:YES];
        [self.name7 setHidden:YES];
        [self.name8 setHidden:YES];
        
        [self.score5 setHidden:YES];
        [self.score6 setHidden:YES];
        [self.score7 setHidden:YES];
        [self.score8 setHidden:YES];
        
        [self.round1 setHidden:YES];
        [self.round2 setHidden:YES];
        [self.round3 setHidden:YES];
        [self.round4 setHidden:YES];
        [self.round5 setHidden:YES];
        [self.round6 setHidden:YES];
        [self.round7 setHidden:YES];
        [self.round8 setHidden:YES];
        [self.roundColumn setHidden:YES];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];

    }
    
    [self.name1 setAdjustsFontSizeToFitWidth:YES];
    [self.name2 setAdjustsFontSizeToFitWidth:YES];
    [self.name3 setAdjustsFontSizeToFitWidth:YES];
    [self.name4 setAdjustsFontSizeToFitWidth:YES];
    [self.name5 setAdjustsFontSizeToFitWidth:YES];
    [self.name6 setAdjustsFontSizeToFitWidth:YES];
    [self.name7 setAdjustsFontSizeToFitWidth:YES];
    [self.name8 setAdjustsFontSizeToFitWidth:YES];
    
    [self.round1 setAdjustsFontSizeToFitWidth:YES];
    [self.round2 setAdjustsFontSizeToFitWidth:YES];
    [self.round3 setAdjustsFontSizeToFitWidth:YES];
    [self.round4 setAdjustsFontSizeToFitWidth:YES];
    [self.round5 setAdjustsFontSizeToFitWidth:YES];
    [self.round6 setAdjustsFontSizeToFitWidth:YES];
    [self.round7 setAdjustsFontSizeToFitWidth:YES];
    [self.round8 setAdjustsFontSizeToFitWidth:YES];
    
    [self.score1 setAdjustsFontSizeToFitWidth:YES];
    [self.score2 setAdjustsFontSizeToFitWidth:YES];
    [self.score3 setAdjustsFontSizeToFitWidth:YES];
    [self.score4 setAdjustsFontSizeToFitWidth:YES];
    [self.score5 setAdjustsFontSizeToFitWidth:YES];
    [self.score6 setAdjustsFontSizeToFitWidth:YES];
    [self.score7 setAdjustsFontSizeToFitWidth:YES];
    [self.score8 setAdjustsFontSizeToFitWidth:YES];
    
    
}

- (IBAction)switchSegment:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if(selectedSegment == 0)
    {
        self.pageName.text = @"HIGH SCORES";
        
        self.name1.text = self.localHighScores[0][@"name"];
        self.name2.text = self.localHighScores[1][@"name"];
        self.name3.text = self.localHighScores[2][@"name"];
        self.name4.text = self.localHighScores[3][@"name"];
        self.name5.text = self.localHighScores[4][@"name"];
        self.name6.text = self.localHighScores[5][@"name"];
        self.name7.text = self.localHighScores[6][@"name"];
        self.name8.text = self.localHighScores[7][@"name"];
        
        self.score1.text = self.localHighScores[0][@"score"];
        self.score2.text = self.localHighScores[1][@"score"];
        self.score3.text = self.localHighScores[2][@"score"];
        self.score4.text = self.localHighScores[3][@"score"];
        self.score5.text = self.localHighScores[4][@"score"];
        self.score6.text = self.localHighScores[5][@"score"];
        self.score7.text = self.localHighScores[6][@"score"];
        self.score8.text = self.localHighScores[7][@"score"];
        
        self.round1.text = self.localHighScores[0][@"round"];
        self.round2.text = self.localHighScores[1][@"round"];
        self.round3.text = self.localHighScores[2][@"round"];
        self.round4.text = self.localHighScores[3][@"round"];
        self.round5.text = self.localHighScores[4][@"round"];
        self.round6.text = self.localHighScores[5][@"round"];
        self.round7.text = self.localHighScores[6][@"round"];
        self.round8.text = self.localHighScores[7][@"round"];
        
        self.score1.frame = CGRectMake(134,96,70,24);
        self.score2.frame = CGRectMake(134,128,70,24);
        self.score3.frame = CGRectMake(134,160,70,24);
        self.score4.frame = CGRectMake(134,192,70,24);
        self.scoreColumn.frame = CGRectMake(134,64,70,24);
        
        self.name1.frame = CGRectMake(20,96,106,24);
        self.name2.frame = CGRectMake(20,128,106,24);
        self.name3.frame = CGRectMake(20,160,106,24);
        self.name4.frame = CGRectMake(20,192,106,24);
        self.nameColumn.frame = CGRectMake(20,64,106,24);
        
        // show all
        [self.name5 setHidden:NO];
        [self.name6 setHidden:NO];
        [self.name7 setHidden:NO];
        [self.name8 setHidden:NO];
        
        [self.score5 setHidden:NO];
        [self.score6 setHidden:NO];
        [self.score7 setHidden:NO];
        [self.score8 setHidden:NO];
        
        [self.round1 setHidden:NO];
        [self.round2 setHidden:NO];
        [self.round3 setHidden:NO];
        [self.round4 setHidden:NO];
        [self.round5 setHidden:NO];
        [self.round6 setHidden:NO];
        [self.round7 setHidden:NO];
        [self.round8 setHidden:NO];
        [self.roundColumn setHidden:NO];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];
        
        if(self.scoreRank == 0)
        {
            [self.name1 setTextColor:[UIColor orangeColor]];
            [self.score1 setTextColor:[UIColor orangeColor]];
            [self.round1 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 1)
        {
            [self.name2 setTextColor:[UIColor orangeColor]];
            [self.score2 setTextColor:[UIColor orangeColor]];
            [self.round2 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 2)
        {
            [self.name3 setTextColor:[UIColor orangeColor]];
            [self.score3 setTextColor:[UIColor orangeColor]];
            [self.round3 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 3)
        {
            [self.name4 setTextColor:[UIColor orangeColor]];
            [self.score4 setTextColor:[UIColor orangeColor]];
            [self.round4 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 4)
        {
            [self.name5 setTextColor:[UIColor orangeColor]];
            [self.score5 setTextColor:[UIColor orangeColor]];
            [self.round5 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 5)
        {
            [self.name6 setTextColor:[UIColor orangeColor]];
            [self.score6 setTextColor:[UIColor orangeColor]];
            [self.round6 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 6)
        {
            [self.name7 setTextColor:[UIColor orangeColor]];
            [self.score7 setTextColor:[UIColor orangeColor]];
            [self.round7 setTextColor:[UIColor orangeColor]];
        }
        else if(self.scoreRank == 7)
        {
            [self.name8 setTextColor:[UIColor orangeColor]];
            [self.score8 setTextColor:[UIColor orangeColor]];
            [self.round8 setTextColor:[UIColor orangeColor]];
        }


    }
    else
    {
        self.pageName.text = @"HIGH SINGLE ROUNDS";

        self.name1.text = self.localHighRounds[0][@"name"];
        self.name2.text = self.localHighRounds[1][@"name"];
        self.name3.text = self.localHighRounds[2][@"name"];
        self.name4.text = self.localHighRounds[3][@"name"];
        self.name5.text = self.localHighRounds[4][@"name"];
        self.name6.text = self.localHighRounds[5][@"name"];
        self.name7.text = self.localHighRounds[6][@"name"];
        self.name8.text = self.localHighRounds[7][@"name"];
        
        self.score1.text = self.localHighRounds[0][@"score"];
        self.score2.text = self.localHighRounds[1][@"score"];
        self.score3.text = self.localHighRounds[2][@"score"];
        self.score4.text = self.localHighRounds[3][@"score"];
        self.score5.text = self.localHighRounds[4][@"score"];
        self.score6.text = self.localHighRounds[5][@"score"];
        self.score7.text = self.localHighRounds[6][@"score"];
        self.score8.text = self.localHighRounds[7][@"score"];
        
        self.round1.text = self.localHighRounds[0][@"round"];
        self.round2.text = self.localHighRounds[1][@"round"];
        self.round3.text = self.localHighRounds[2][@"round"];
        self.round4.text = self.localHighRounds[3][@"round"];
        self.round5.text = self.localHighRounds[4][@"round"];
        self.round6.text = self.localHighRounds[5][@"round"];
        self.round7.text = self.localHighRounds[6][@"round"];
        self.round8.text = self.localHighRounds[7][@"round"];
        
        self.score1.frame = CGRectMake(179,96,70,24);
        self.score2.frame = CGRectMake(179,128,70,24);
        self.score3.frame = CGRectMake(179,160,70,24);
        self.score4.frame = CGRectMake(179,192,70,24);
        self.scoreColumn.frame = CGRectMake(179,64,70,24);
        
        self.name1.frame = CGRectMake(65,96,106,24);
        self.name2.frame = CGRectMake(65,128,106,24);
        self.name3.frame = CGRectMake(65,160,106,24);
        self.name4.frame = CGRectMake(65,192,106,24);
        self.nameColumn.frame = CGRectMake(65,64,106,24);

        // only show top 4, don't show round number
        [self.name5 setHidden:YES];
        [self.name6 setHidden:YES];
        [self.name7 setHidden:YES];
        [self.name8 setHidden:YES];
        
        [self.score5 setHidden:YES];
        [self.score6 setHidden:YES];
        [self.score7 setHidden:YES];
        [self.score8 setHidden:YES];
        
        [self.round1 setHidden:YES];
        [self.round2 setHidden:YES];
        [self.round3 setHidden:YES];
        [self.round4 setHidden:YES];
        [self.round5 setHidden:YES];
        [self.round6 setHidden:YES];
        [self.round7 setHidden:YES];
        [self.round8 setHidden:YES];
        [self.roundColumn setHidden:YES];
        
        [self.name1 setTextColor:[UIColor whiteColor]];
        [self.score1 setTextColor:[UIColor whiteColor]];
        [self.round1 setTextColor:[UIColor whiteColor]];
        [self.name2 setTextColor:[UIColor whiteColor]];
        [self.score2 setTextColor:[UIColor whiteColor]];
        [self.round2 setTextColor:[UIColor whiteColor]];
        [self.name3 setTextColor:[UIColor whiteColor]];
        [self.score3 setTextColor:[UIColor whiteColor]];
        [self.round3 setTextColor:[UIColor whiteColor]];
        [self.name4 setTextColor:[UIColor whiteColor]];
        [self.score4 setTextColor:[UIColor whiteColor]];
        [self.round4 setTextColor:[UIColor whiteColor]];
        [self.name5 setTextColor:[UIColor whiteColor]];
        [self.score5 setTextColor:[UIColor whiteColor]];
        [self.round5 setTextColor:[UIColor whiteColor]];
        [self.name6 setTextColor:[UIColor whiteColor]];
        [self.score6 setTextColor:[UIColor whiteColor]];
        [self.round6 setTextColor:[UIColor whiteColor]];
        [self.name7 setTextColor:[UIColor whiteColor]];
        [self.score7 setTextColor:[UIColor whiteColor]];
        [self.round7 setTextColor:[UIColor whiteColor]];
        [self.name8 setTextColor:[UIColor whiteColor]];
        [self.score8 setTextColor:[UIColor whiteColor]];
        [self.round8 setTextColor:[UIColor whiteColor]];

        for(int i = 0; i < [self.roundRanks count]; i++)
        {
            int roundRankLocal = [[self.roundRanks objectAtIndex:i] integerValue];
            
            if(roundRankLocal == 0)
            {
                [self.name1 setTextColor:[UIColor orangeColor]];
                [self.score1 setTextColor:[UIColor orangeColor]];
                [self.round1 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 1)
            {
                [self.name2 setTextColor:[UIColor orangeColor]];
                [self.score2 setTextColor:[UIColor orangeColor]];
                [self.round2 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 2)
            {
                [self.name3 setTextColor:[UIColor orangeColor]];
                [self.score3 setTextColor:[UIColor orangeColor]];
                [self.round3 setTextColor:[UIColor orangeColor]];
            }
            else if(roundRankLocal == 3)
            {
                [self.name4 setTextColor:[UIColor orangeColor]];
                [self.score4 setTextColor:[UIColor orangeColor]];
                [self.round4 setTextColor:[UIColor orangeColor]];
            }
        }

    }

}
@end
