//
//  HighRoundsViewController.m
//  OchoSimple
//
//  Created by Nelson on 5/23/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "HighRoundsViewController.h"
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "BlockTextPromptAlertView.h"

@interface HighRoundsViewController ()

@end

@implementation HighRoundsViewController

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
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    
    bool success = [fileManager fileExistsAtPath:plistPath];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
        [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    }
    
    self.localHighRounds = [NSMutableArray arrayWithContentsOfFile:plistPath];

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissHighRounds:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)resetHighRounds:(id)sender
{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RESET HIGH SCORES?"
                                                    message:@"This will reset the high scores to the defaults."
                                                   delegate:self
                                          cancelButtonTitle:@"CANCEL"
                                          otherButtonTitles:@"RESET", nil];
    
    [alert show];*/
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"RESET HIGH ROUND SCORES?" message:@"This will reset the high round scores to the defaults."];
    
    [alert setCancelButtonWithTitle:@"CANCEL" block:nil];
        
    [alert setDestructiveButtonWithTitle:@"RESET" block:^
    {
        [self reallyResetHighRounds:nil];
    }];

    [alert show];

}


- (void) reallyResetHighRounds:(id)sender;
{

    // reset scores by copying default plist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    [fileManager removeItemAtPath:plistPath error:&error];
    [fileManager copyItemAtPath:defaultPath toPath:plistPath error:&error];
    
    self.localHighRounds = [NSMutableArray arrayWithContentsOfFile:plistPath];
    
    // reload local high scores after reset
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
        
    [self.name1 setAdjustsFontSizeToFitWidth:YES];
    [self.name2 setAdjustsFontSizeToFitWidth:YES];
    [self.name3 setAdjustsFontSizeToFitWidth:YES];
    [self.name4 setAdjustsFontSizeToFitWidth:YES];
    [self.name5 setAdjustsFontSizeToFitWidth:YES];
    [self.name6 setAdjustsFontSizeToFitWidth:YES];
    [self.name7 setAdjustsFontSizeToFitWidth:YES];
    [self.name8 setAdjustsFontSizeToFitWidth:YES];
        
    [self.score1 setAdjustsFontSizeToFitWidth:YES];
    [self.score2 setAdjustsFontSizeToFitWidth:YES];
    [self.score3 setAdjustsFontSizeToFitWidth:YES];
    [self.score4 setAdjustsFontSizeToFitWidth:YES];
    [self.score5 setAdjustsFontSizeToFitWidth:YES];
    [self.score6 setAdjustsFontSizeToFitWidth:YES];
    [self.score7 setAdjustsFontSizeToFitWidth:YES];
    [self.score8 setAdjustsFontSizeToFitWidth:YES];
    
    
}
@end
