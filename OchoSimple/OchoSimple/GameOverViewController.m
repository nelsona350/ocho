//
//  GameOverViewController.m
//  OchoSimple
//
//  Created by Nelson on 5/21/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "GameOverViewController.h"
#import "HighScoresViewController.h"
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "BlockTextPromptAlertView.h"
#import "GameKitHelper.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface GameOverViewController ()

@end

@implementation GameOverViewController

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
    
    self.roundRanks = [[NSMutableArray alloc] init];
    
    self.finalScoreText.text =
    [NSString stringWithFormat:@"%d",self.finalScore];
    
    self.roundNumberText.text =
    [NSString stringWithFormat:@"%d",self.roundNumber];
    
    self.bestRoundText.text =
    [NSString stringWithFormat:@"%d",self.bestRound];
    
    if(self.closestCall == 289)
    {
        self.closestCallText.text = @"N/A";
    }
    else
    {
        self.closestCallText.text =
        [NSString stringWithFormat:@"%d",self.closestCall];
    }
    
    // sort round scores
    NSSortDescriptor *highestToLowest =
    [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [self.roundScores sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];

    
    // load local high scores
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.plistPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighScores.plist"];
    
    bool success = [fileManager fileExistsAtPath:self.plistPath];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighScores.plist"];
        success = [fileManager copyItemAtPath:defaultPath toPath:self.plistPath error:&error];
    }
    
    self.localHighScores = [NSMutableArray arrayWithContentsOfFile:self.plistPath];
    
    // submit any un-submitted scores to Game Center
    bool submitted = [[GameKitHelper sharedGameKitHelper]
                      submitScore:(int64_t)self.finalScore
                      category:@"com.adamzappl.ochosimple.highscores"];
    submitted = false;
        
    self.scoreRank = 0;
    while(self.scoreRank < 8 &&
          self.finalScore <= [self.localHighScores[self.scoreRank][@"score"] intValue])
    {
        self.scoreRank++;
    }
    
    // load local high round scores
    fileManager = [NSFileManager defaultManager];
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.plistPathRnd = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
    
    success = [fileManager fileExistsAtPath:self.plistPathRnd];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LocalHighRounds.plist"];
        success = [fileManager copyItemAtPath:defaultPath toPath:self.plistPathRnd error:&error];
    }
    
    self.localHighRounds = [NSMutableArray arrayWithContentsOfFile:self.plistPathRnd];
    
    self.roundRank = 0;
    while(self.roundRank < 4 &&
          self.bestRound <= [self.localHighRounds[self.roundRank][@"score"] intValue])
    {
        self.roundRank++;
    }
    
    if(self.scoreRank < 8)
    {
        // beat lowest high score
        
        UITextField *textField;
        NSString *popupTitle = @"NEW HIGH SCORE";
        NSString *popupMessage = [NSString stringWithFormat:@"Final Score: %i", self.finalScore];
        if(self.roundRank < 4)
        {
            popupTitle = @"NEW HIGH SCORE\nNEW HIGH SINGLE ROUND";
            popupMessage = [NSString stringWithFormat:@"Final Score: %i\nBest Single Round: %i", self.finalScore, self.bestRound];

        }
        
        BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:popupTitle
                                                                            message:popupMessage
                                                                          textField:&textField block:^(BlockTextPromptAlertView *alert)
        {
            [alert.textField resignFirstResponder];
            
            return YES;
        }];
        
        [alert addButtonWithTitle:@"RETURN" block:^
        {
            self.playerName = textField.text;
            
            if([self.playerName length] == 0)
            {
                self.playerName = @"Adam Zappl";
            }
            
            NSMutableDictionary *scoreEntry = [[NSMutableDictionary alloc]init];
            
            // create new high score entry
            [scoreEntry setObject:self.playerName forKey:@"name"];
            [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.finalScore] forKey:@"score"];
            [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.roundNumber] forKey:@"round"];
                        
            // insert new high score entry
            [self.localHighScores insertObject:scoreEntry atIndex:self.scoreRank];
            
            // remove lowest high score entry
            [self.localHighScores removeLastObject];
            
            // write updated high scores file
            [self.localHighScores writeToFile:self.plistPath atomically:YES];
            
            if(self.roundRank < 4)
            {
                /*
                // create new high round score entry
                [scoreEntry setObject:self.playerName forKey:@"name"];
                [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.bestRound] forKey:@"score"];
                [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.bestRoundNumber] forKey:@"round"];
                
                // insert new high round score entry
                [self.localHighRounds insertObject:scoreEntry atIndex:self.roundRank];
                
                // remove lowest high round score entry
                [self.localHighRounds removeLastObject];
                 */
                
                if(self.roundNumber > 0)
                {
                    // multiple rounds that may make the list, loop over all round scores
                    for(int i = 0; i < self.roundNumber; i++)
                    {
                        // only add rounds other than the best round, since if was already added
                        //if(i != self.bestRoundNumber-1)
                        {
                            int tempRoundRank = 0;
                            while(tempRoundRank < 4 &&
                                  [[self.roundScores objectAtIndex:i] intValue] <= [self.localHighRounds[tempRoundRank][@"score"] intValue])
                            {
                                tempRoundRank++;
                            }
                            
                            if(tempRoundRank < 4)
                            {
                                // create new high round score entry
                                
                                NSMutableDictionary *roundEntry = [[NSMutableDictionary alloc]init];

                                [roundEntry setObject:self.playerName forKey:@"name"];
                                [roundEntry setObject:[NSString stringWithFormat:@"%d",[[self.roundScores objectAtIndex:i] intValue]] forKey:@"score"];
                                [roundEntry setObject:[NSString stringWithFormat:@"%d",1] forKey:@"round"];
                                
                                // insert new high round score entry
                                [self.localHighRounds insertObject:roundEntry atIndex:tempRoundRank];
                                
                                // remove lowest high round score entry
                                [self.localHighRounds removeLastObject];
                                
                                // write updated high scores file
                                [self.localHighRounds writeToFile:self.plistPathRnd atomically:YES];
                                
                                // store round rank
                                [self.roundRanks
                                 addObject:[NSNumber numberWithInteger:tempRoundRank]];
                                
                            }
                        }
                    }
                }
                
                // write updated high scores file
                [self.localHighRounds writeToFile:self.plistPathRnd atomically:YES];
            }

            
            [self performSegueWithIdentifier:@"DisplayHighScores" sender:self];
        }];
        
        alert.textField.text = self.playerName;
        
        [alert show];

        
    }
    else if(self.roundRank < 4 && self.scoreRank == 8)
    {
        // beat lowest high round
        
        if(self.scoreRank == 8)
        {
            // have to get player name, since the high game score pop-up wasn't displayed
            UITextField *textField;
            BlockTextPromptAlertView *alert = [BlockTextPromptAlertView promptWithTitle:@"NEW HIGH SINGLE ROUND"
                                                                                message:[NSString stringWithFormat:@"Best Single Round: %i", self.bestRound]
                                                                              textField:&textField block:^(BlockTextPromptAlertView *alert)
                                               {
                                                   [alert.textField resignFirstResponder];
                                                   
                                                   return YES;
                                               }];
            
            [alert addButtonWithTitle:@"RETURN" block:^
             {
                 self.playerName = textField.text;
                 
                 if([self.playerName length] == 0)
                 {
                     self.playerName = @"Adam Zappl";
                 }
                                  
                 /*
                 // create new high score entry
                 [scoreEntry setObject:self.playerName forKey:@"name"];
                 [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.bestRound] forKey:@"score"];
                 [scoreEntry setObject:[NSString stringWithFormat:@"%d",self.bestRoundNumber] forKey:@"round"];
                 
                 // insert new high score entry
                 [self.localHighRounds insertObject:scoreEntry atIndex:self.roundRank];
                 
                 // remove lowest high score entry
                 [self.localHighRounds removeLastObject];
                  */
                 
                 if(self.roundNumber > 0)
                 {
                     // multiple rounds that may make the list, loop over all round scores
                     for(int i = 0; i < self.roundNumber; i++)
                     {
                         // only add rounds other than the best round, since if was already added
                         //if(i != self.bestRoundNumber-1)
                         {
                             int tempRoundRank = 0;
                             while(tempRoundRank < 4 &&
                                   [[self.roundScores objectAtIndex:i] intValue] <= [self.localHighRounds[tempRoundRank][@"score"] intValue])
                             {
                                 tempRoundRank++;
                             }
                             
                             if(tempRoundRank < 4)
                             {
                                 // create new high round score entry
                                 NSMutableDictionary *roundEntry = [[NSMutableDictionary alloc]init];
                                 
                                 [roundEntry setObject:self.playerName forKey:@"name"];
                                 [roundEntry setObject:[NSString stringWithFormat:@"%d",[[self.roundScores objectAtIndex:i] intValue]] forKey:@"score"];
                                 [roundEntry setObject:[NSString stringWithFormat:@"%d",1] forKey:@"round"];
                                 
                                 // insert new high round score entry
                                 [self.localHighRounds insertObject:roundEntry atIndex:tempRoundRank];
                                 
                                 // remove lowest high round score entry
                                 [self.localHighRounds removeLastObject];
                                 
                                 // write updated high scores file
                                 [self.localHighRounds writeToFile:self.plistPathRnd atomically:YES];

                                 // store round rank
                                 [self.roundRanks
                                  addObject:[NSNumber numberWithInteger:tempRoundRank]];

                             }
                         }
                     }
                 }
                 
                 [self performSegueWithIdentifier:@"DisplayHighScores" sender:self];
             }];
            
            alert.textField.text = self.playerName;
            
            [alert show];
        }    
        
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissGameOver:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)tweetScore:(id)sender
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
    {
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    }
    
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // check for retina display and 4 inch display
    double imageHeight = 300.0;
    double imageWidth = 320.0;
    
    if([[UIScreen mainScreen] bounds].size.height == 568.)
    {
        imageHeight = 355.0;
        imageWidth = 320.0;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
    {
        imageHeight *= 2.0;
        imageWidth *= 2.0;
    }
    
    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage],
                                                                   CGRectMake(0.,0.,imageWidth,imageHeight))];
    //NSData * data = UIImagePNGRepresentation(image);
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"gameSummary.png"];*/

    //[data writeToFile:imagePath atomically:YES];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%i on OCHO! <insert trash talk here> #ochochallenge", self.finalScore]];
        [tweetSheet addImage:image];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"OOPS!"
                                                       message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account configured."];
        
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        
        [alert show];

    }
    
}

- (IBAction)facebookScore:(id)sender
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
    {
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    }
    
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // check for retina display and 4 inch display
    double imageHeight = 300.0;
    double imageWidth = 320.0;
    
    if([[UIScreen mainScreen] bounds].size.height == 568.)
    {
        imageHeight = 355.0;
        imageWidth = 320.0;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
    {
        imageHeight *= 2.0;
        imageWidth *= 2.0;
    }
    
    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage],
                                                                   CGRectMake(0.,0.,imageWidth,imageHeight))];
    //NSData * data = UIImagePNGRepresentation(image);
    
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"gameSummary.png"];*/
    
    //[data writeToFile:imagePath atomically:YES];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *fbPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPost setInitialText:[NSString stringWithFormat:@"%i on OCHO! <insert trash talk here>", self.finalScore]];
        [fbPost addImage:image];
        [self presentViewController:fbPost animated:YES completion:nil];
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"OOPS!"
                                                       message:@"You can't create a post right now, make sure your device has an internet connection and you have at least one Facebook account configured."];
        
        [alert setCancelButtonWithTitle:@"OK" block:nil];
        
        [alert show];
        
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"DisplayHighScores"])
	{
        HighScoresViewController *highScoresViewController = segue.destinationViewController;
        //highScoresViewController.localHighScores = self.localHighScores;
        
        highScoresViewController.scoreRank = self.scoreRank;
        highScoresViewController.roundRanks = self.roundRanks;
        
        highScoresViewController.selectedSegment = 0;
        highScoresViewController.pageName.text = @"HIGH SCORES";
        
        if(self.scoreRank == 8 && self.roundRank < 4)
        {
            // if only a high single round was set, go to HSR page            
            highScoresViewController.selectedSegment = 1;
            highScoresViewController.pageName.text = @"HIGH SINGLE ROUNDS";

        }
        
        //self.scoreRank = 8;
        //[self.roundRanks removeAllObjects];
    }
}

@end
