//
//  OchoSimpleViewController.m
//  OchoSimple
//
//  Created by Nelson on 4/27/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "OchoSimpleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BlockAlertView.h"
#import "BlockActionSheet.h"
#import "BlockTextPromptAlertView.h"
#import <StoreKit/StoreKit.h>
#import "IAPManagerOcho.h"
#import <AudioToolbox/AudioToolbox.h>


@interface OchoSimpleViewController ()
- (IBAction)holeOneClick:(id)sender;
- (IBAction)holeTwoClick:(id)sender;
- (IBAction)holeThreeClick:(id)sender;
- (IBAction)holeFourClick:(id)sender;
- (IBAction)holeFiveClick:(id)sender;
- (IBAction)holeSixClick:(id)sender;
- (IBAction)holeSevenClick:(id)sender;
- (IBAction)holeEightClick:(id)sender;
- (IBAction)nextTurnClick:(id)sender;
- (IBAction)newGameClick:(id)sender;
- (IBAction)offerUpgrade:(id)sender;
- (void)tossCoins:(id)sender;
- (void)checkMatch;
- (void) offerUnlimitedRounds;
- (void) processNextTurn:(id)sender;
- (void) processTossCoins:(id)sender;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) unlockUnlimitedRounds;
- (void) screenCapture;
- (void) copyHoles;
- (void) scheduleNextMatchCheck;
- (UIButton *)buttonForHoleNumber:(int)holeNumber;


@property (weak, nonatomic) IBOutlet UIButton *hole1;
@property (weak, nonatomic) IBOutlet UIButton *hole2;
@property (weak, nonatomic) IBOutlet UIButton *hole3;
@property (weak, nonatomic) IBOutlet UIButton *hole4;
@property (weak, nonatomic) IBOutlet UIButton *hole5;
@property (weak, nonatomic) IBOutlet UIButton *hole6;
@property (weak, nonatomic) IBOutlet UIButton *hole7;
@property (weak, nonatomic) IBOutlet UIButton *hole8;
@property (weak, nonatomic) IBOutlet UILabel *totalScoreText;
@property (weak, nonatomic) IBOutlet UILabel *frame1Score;
@property (weak, nonatomic) IBOutlet UILabel *frame2Score;
@property (weak, nonatomic) IBOutlet UILabel *frame3Score;
@property (weak, nonatomic) IBOutlet UILabel *frame4Score;
@property (weak, nonatomic) IBOutlet UILabel *frame5Score;
@property (weak, nonatomic) IBOutlet UILabel *frame6Score;
@property (weak, nonatomic) IBOutlet UILabel *frame7Score;
@property (weak, nonatomic) IBOutlet UILabel *frame8Score;
@property (weak, nonatomic) IBOutlet UIButton *frameScoreText;
@property (weak, nonatomic) IBOutlet UILabel *roundScoreText;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole1;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole2;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole3;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole4;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole5;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole6;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole7;
@property (weak, nonatomic) IBOutlet UIImageView *emptyHole8;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel4;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel5;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel7;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel6;
@property (weak, nonatomic) IBOutlet UILabel *emptyHoleLabel8;
@property (weak, nonatomic) IBOutlet UILabel *pointsToGoText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSTimeInterval holeActivationDelay;

@end

@implementation OchoSimpleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // play short silence to eliminate delay for first tone - goofy but effective
    NSString *silencePath = [[NSBundle mainBundle]
                              pathForResource:@"silence" ofType:@"wav"];
    NSURL *silenceURL = [NSURL fileURLWithPath:silencePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)silenceURL, &silence);
    AudioServicesPlaySystemSound(silence);
    
    // preset toneURLs for speed
    NSString *tonePath = [[NSBundle mainBundle]
                          pathForResource:@"mhTone1" ofType:@"wav"];
    tone1URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone2" ofType:@"wav"];
    tone2URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone3" ofType:@"wav"];
    tone3URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone4" ofType:@"wav"];
    tone4URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone5" ofType:@"wav"];
    tone5URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone6" ofType:@"wav"];
    tone6URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone7" ofType:@"wav"];
    tone7URL = [NSURL fileURLWithPath:tonePath];
    tonePath = [[NSBundle mainBundle]
                pathForResource:@"mhTone8" ofType:@"wav"];
    tone8URL = [NSURL fileURLWithPath:tonePath];


    [self.activityIndicator stopAnimating];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // check purchases - no need right now, since only IAP item is prompted for
    
    // check for first launch of newly installed app

    self.unlockedCoinSets = [[NSMutableArray alloc] init];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
                
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"UPGRADE TO OCHO PLUS?"
                                                       message:@"Your games are currently limited to 4 rounds. Do you want to upgrade to OCHO PLUS to unlock unlimited rounds?"];
        
        [alert setCancelButtonWithTitle:@"NO" block:^
         {
             [self.view setUserInteractionEnabled:YES];
             [self.activityIndicator stopAnimating];
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
             [[NSUserDefaults standardUserDefaults] synchronize];

         }];
        
        
        [alert setDestructiveButtonWithTitle:@"YES" block:^
         {
             //self.unlimitedRoundsEnabled = YES;
             [self.view setUserInteractionEnabled:NO];
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             SKProductsRequest *request= [[SKProductsRequest alloc]
                                          initWithProductIdentifiers: [NSSet setWithObject: @"com.adamzappl.ochosimple.unlimitedrounds3"]];
             request.delegate = self;
             
             [self.activityIndicator setColor:[UIColor blackColor]];
             [self.activityIndicator startAnimating];
             [request start];
             
         }];
        
        [alert show];

    }
    
    // prep for screenshots
    self.numScreenshots = 1;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    bool success = YES;
    int screenshotNum = 1;
    while(success)
    {
    
        NSString *screenshotName = [NSString stringWithFormat:@"screenshot%d.png", screenshotNum];
        
        NSString *pngPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:screenshotName];
        
        success = [fileManager removeItemAtPath:pngPath error:&error];
        
        screenshotNum++;
        
    }
    
    // load settings and enabled features
    self.enabledFeaturesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SettingsAndFeatures.plist"];
    
    success = [fileManager fileExistsAtPath:self.enabledFeaturesPath];
    if(!success)
    {
        // file does not exist yet, look in resources
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SettingsAndFeatures.plist"];
        success = [fileManager copyItemAtPath:defaultPath toPath:self.enabledFeaturesPath error:&error];
    }
    
    NSMutableDictionary *enabledFeatures = [NSMutableDictionary dictionaryWithContentsOfFile:self.enabledFeaturesPath];
    
    self.unlimitedRoundsEnabled = [enabledFeatures[@"unlimitedRounds"] boolValue];
    self.flipDisplayEnabled = [enabledFeatures[@"flipDisplay"] boolValue];
    self.soundEnabled = [enabledFeatures[@"sound"] boolValue];
    self.playerName = enabledFeatures[@"playerName"];
    self.selectedCoinSet = [enabledFeatures[@"coinSet"] intValue];
    [self.unlockedCoinSets setArray:enabledFeatures[@"unlockedCoinSets"]];
    
    // if unlockedCoinSets does not exist, it will set the array to NIL,
    // so the array must be reinitialized
    if (self.unlockedCoinSets == nil || [self.unlockedCoinSets count] == 0)
    {
        self.unlockedCoinSets = [[NSMutableArray alloc] init];
    }
    
    if(![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:1]])
    {
        [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:1]];
    }
    
    // make sure the user doesn't have a locked coin set selected
    if(![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:self.selectedCoinSet]])
    {
        self.selectedCoinSet = 1;
    }
    
    // set display programmatically to keep things pretty for 4 inch display

    // check for 4 inch display
    if([[UIScreen mainScreen] bounds].size.height == 568.)
    {
        self.isWidescreen = YES;
        
        if(!self.flipDisplayEnabled)
        {
            self.hole1.frame = CGRectMake(252,24,48,48);
            self.hole2.frame = CGRectMake(252,92,48,48);
            self.hole3.frame = CGRectMake(252,160,48,48);
            self.hole4.frame = CGRectMake(252,228,48,48);
            self.hole5.frame = CGRectMake(252,296,48,48);
            self.hole6.frame = CGRectMake(252,364,48,48);
            self.hole7.frame = CGRectMake(252,432,48,48);
            self.hole8.frame = CGRectMake(252,500,48,48);
            
            self.emptyHole1.frame = CGRectMake(252,24,48,48);
            self.emptyHole2.frame = CGRectMake(252,92,48,48);
            self.emptyHole3.frame = CGRectMake(252,160,48,48);
            self.emptyHole4.frame = CGRectMake(252,228,48,48);
            self.emptyHole5.frame = CGRectMake(252,296,48,48);
            self.emptyHole6.frame = CGRectMake(252,364,48,48);
            self.emptyHole7.frame = CGRectMake(252,432,48,48);
            self.emptyHole8.frame = CGRectMake(252,500,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(252,24,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(252,92,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(252,160,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(252,228,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(252,296,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(252,364,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(252,432,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(252,500,48,48);
            
            self.frame1Score.frame = CGRectMake(20,24,48,48);
            self.frame2Score.frame = CGRectMake(20,92,48,48);
            self.frame3Score.frame = CGRectMake(20,160,48,48);
            self.frame4Score.frame = CGRectMake(20,228,48,48);
            self.frame5Score.frame = CGRectMake(20,296,48,48);
            self.frame6Score.frame = CGRectMake(20,364,48,48);
            self.frame7Score.frame = CGRectMake(20,432,48,48);
            self.frame8Score.frame = CGRectMake(20,500,48,48);
        }
        else
        {
            self.hole1.frame = CGRectMake(20,24,48,48);
            self.hole2.frame = CGRectMake(20,92,48,48);
            self.hole3.frame = CGRectMake(20,160,48,48);
            self.hole4.frame = CGRectMake(20,228,48,48);
            self.hole5.frame = CGRectMake(20,296,48,48);
            self.hole6.frame = CGRectMake(20,364,48,48);
            self.hole7.frame = CGRectMake(20,432,48,48);
            self.hole8.frame = CGRectMake(20,500,48,48);
            
            self.emptyHole1.frame = CGRectMake(20,24,48,48);
            self.emptyHole2.frame = CGRectMake(20,92,48,48);
            self.emptyHole3.frame = CGRectMake(20,160,48,48);
            self.emptyHole4.frame = CGRectMake(20,228,48,48);
            self.emptyHole5.frame = CGRectMake(20,296,48,48);
            self.emptyHole6.frame = CGRectMake(20,364,48,48);
            self.emptyHole7.frame = CGRectMake(20,432,48,48);
            self.emptyHole8.frame = CGRectMake(20,500,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(20,24,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(20,92,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(20,160,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(20,228,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(20,296,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(20,364,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(20,432,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(20,500,48,48);
            
            self.frame1Score.frame = CGRectMake(252,24,48,48);
            self.frame2Score.frame = CGRectMake(252,92,48,48);
            self.frame3Score.frame = CGRectMake(252,160,48,48);
            self.frame4Score.frame = CGRectMake(252,228,48,48);
            self.frame5Score.frame = CGRectMake(252,296,48,48);
            self.frame6Score.frame = CGRectMake(252,364,48,48);
            self.frame7Score.frame = CGRectMake(252,432,48,48);
            self.frame8Score.frame = CGRectMake(252,500,48,48);
        }

    }
    else
    {
        self.isWidescreen = NO;
        
        if(!self.flipDisplayEnabled)
        {
            self.hole1.frame = CGRectMake(252,20,48,48);
            self.hole2.frame = CGRectMake(252,76,48,48);
            self.hole3.frame = CGRectMake(252,132,48,48);
            self.hole4.frame = CGRectMake(252,188,48,48);
            self.hole5.frame = CGRectMake(252,244,48,48);
            self.hole6.frame = CGRectMake(252,300,48,48);
            self.hole7.frame = CGRectMake(252,356,48,48);
            self.hole8.frame = CGRectMake(252,412,48,48);
            
            self.emptyHole1.frame = CGRectMake(252,20,48,48);
            self.emptyHole2.frame = CGRectMake(252,76,48,48);
            self.emptyHole3.frame = CGRectMake(252,132,48,48);
            self.emptyHole4.frame = CGRectMake(252,188,48,48);
            self.emptyHole5.frame = CGRectMake(252,244,48,48);
            self.emptyHole6.frame = CGRectMake(252,300,48,48);
            self.emptyHole7.frame = CGRectMake(252,356,48,48);
            self.emptyHole8.frame = CGRectMake(252,412,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(252,20,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(252,76,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(252,132,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(252,188,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(252,244,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(252,300,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(252,356,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(252,412,48,48);
            
            self.frame1Score.frame = CGRectMake(20,20,48,48);
            self.frame2Score.frame = CGRectMake(20,76,48,48);
            self.frame3Score.frame = CGRectMake(20,132,48,48);
            self.frame4Score.frame = CGRectMake(20,188,48,48);
            self.frame5Score.frame = CGRectMake(20,244,48,48);
            self.frame6Score.frame = CGRectMake(20,300,48,48);
            self.frame7Score.frame = CGRectMake(20,356,48,48);
            self.frame8Score.frame = CGRectMake(20,412,48,48);
        }
        else
        {
            self.hole1.frame = CGRectMake(20,20,48,48);
            self.hole2.frame = CGRectMake(20,76,48,48);
            self.hole3.frame = CGRectMake(20,132,48,48);
            self.hole4.frame = CGRectMake(20,188,48,48);
            self.hole5.frame = CGRectMake(20,244,48,48);
            self.hole6.frame = CGRectMake(20,300,48,48);
            self.hole7.frame = CGRectMake(20,356,48,48);
            self.hole8.frame = CGRectMake(20,412,48,48);
            
            self.emptyHole1.frame = CGRectMake(20,20,48,48);
            self.emptyHole2.frame = CGRectMake(20,76,48,48);
            self.emptyHole3.frame = CGRectMake(20,132,48,48);
            self.emptyHole4.frame = CGRectMake(20,188,48,48);
            self.emptyHole5.frame = CGRectMake(20,244,48,48);
            self.emptyHole6.frame = CGRectMake(20,300,48,48);
            self.emptyHole7.frame = CGRectMake(20,356,48,48);
            self.emptyHole8.frame = CGRectMake(20,412,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(20,20,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(20,76,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(20,132,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(20,188,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(20,244,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(20,300,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(20,356,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(20,412,48,48);
            
            self.frame1Score.frame = CGRectMake(252,20,48,48);
            self.frame2Score.frame = CGRectMake(252,76,48,48);
            self.frame3Score.frame = CGRectMake(252,132,48,48);
            self.frame4Score.frame = CGRectMake(252,188,48,48);
            self.frame5Score.frame = CGRectMake(252,244,48,48);
            self.frame6Score.frame = CGRectMake(252,300,48,48);
            self.frame7Score.frame = CGRectMake(252,356,48,48);
            self.frame8Score.frame = CGRectMake(252,412,48,48);
        }

    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"blackButton.png"];
    UIColor *textColor = [UIColor whiteColor];
    if(self.selectedCoinSet == 9)
    {
        buttonImage = [UIImage imageNamed:@"orangeButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 6)
    {
        buttonImage = [UIImage imageNamed:@"redButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 5)
    {
        buttonImage = [UIImage imageNamed:@"yellowButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 4)
    {
        buttonImage = [UIImage imageNamed:@"purpleButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 7)
    {
        buttonImage = [UIImage imageNamed:@"pinkButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 8)
    {
        buttonImage = [UIImage imageNamed:@"blueButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 3)
    {
        buttonImage = [UIImage imageNamed:@"greenButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 2)
    {
        buttonImage = [UIImage imageNamed:@"grayButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 1)
    {
        buttonImage = [UIImage imageNamed:@"blackButton.png"];
        textColor = [UIColor whiteColor];
    }
    
    [self.hole1 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole1 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole2 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole2 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole3 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole3 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole4 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole4 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole5 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole5 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole6 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole6 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole7 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole7 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole8 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole8 setTitleColor:textColor forState:UIControlStateNormal];

    
    self.roundNumber  = 0;
    self.frameNumber = 0;
    self.frameScore  = 0;
    self.totalScore  = 0;
    self.roundScore   = 0;
    self.numberOfCoinsRemaining = 8;
    self.readyToToss = NO;
    self.flipDisplayEnabled = NO;
    self.pointsToGo = 88;
    self.bestRound = 0;
    self.closestCall = 289;
    self.delayInSeconds = 1.0;
    self.holeActivationDelay = 0.25;
    self.roundLimit = 4;
    self.bestRoundNumber = 1;
    self.passed88 = NO;
    
    self.pointsToGoText.textColor =
        [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
    
    self.hole = [[NSMutableArray alloc] init];
    self.holeOld = [[NSMutableArray alloc] init];
    self.coin = [[NSMutableArray alloc] init];
    self.matchedCoin = [[NSMutableArray alloc] init];
    self.coinScores = [[NSMutableArray alloc] init];
    self.frameScores = [[NSMutableArray alloc] init];
    self.roundScores = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 8; i++)
    {
        [self.coin addObject:[NSNumber numberWithInteger:i+1]];
        [self.hole addObject:[NSNumber numberWithInteger:0]];
        [self.matchedCoin addObject:[NSNumber numberWithBool:NO]];
        [self.coinScores addObject:[NSNumber numberWithInteger:i+1]];
        [self.frameScores addObject:[NSNumber numberWithInteger:0]];
    }
    
    self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.roundScoreText.layer.borderWidth = 2;
    
    self.frame1Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame1Score.layer.borderWidth = 2;
    self.frame1Score.text = @"";

    self.frame2Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame2Score.layer.borderWidth = 2;
    self.frame2Score.text = @"";
    
    self.frame3Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame3Score.layer.borderWidth = 2;
    self.frame3Score.text = @"";
    
    self.frame4Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame4Score.layer.borderWidth = 2;
    self.frame4Score.text = @"";
    
    self.frame5Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame5Score.layer.borderWidth = 2;
    self.frame5Score.text = @"";
    
    self.frame6Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame6Score.layer.borderWidth = 2;
    self.frame6Score.text = @"";
    
    self.frame7Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame7Score.layer.borderWidth = 2;
    self.frame7Score.text = @"";
    
    self.frame8Score.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.frame8Score.layer.borderWidth = 2;
    self.frame8Score.text = @"";
    
    [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
    [self.frameScoreText.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.frameScoreText.titleLabel setMinimumScaleFactor:0.25];
    
    [self.hole1.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole1.titleLabel setMinimumScaleFactor:0.25];
    [self.hole2.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole2.titleLabel setMinimumScaleFactor:0.25];
    [self.hole3.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole3.titleLabel setMinimumScaleFactor:0.25];
    [self.hole4.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole4.titleLabel setMinimumScaleFactor:0.25];
    [self.hole5.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole5.titleLabel setMinimumScaleFactor:0.25];
    [self.hole6.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole6.titleLabel setMinimumScaleFactor:0.25];
    [self.hole7.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole7.titleLabel setMinimumScaleFactor:0.25];
    [self.hole8.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.hole8.titleLabel setMinimumScaleFactor:0.25];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)nextTurnClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    // offer unlimited rounds
    if(self.frameNumber == 8 &&
       self.roundScore + self.frameScore >= 88 &&
       !self.readyToToss &&
       !self.unlimitedRoundsEnabled &&
       self.roundNumber == self.roundLimit)
    {                
        
        self.globalFromTossCoins = NO;
        self.globalSender = sender;
        [self offerUnlimitedRounds];
                                
    }
    else
    {
        [self processNextTurn:sender];
    }
}

- (IBAction)newGameClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);

    self.bestRound = 0;
    self.bestRoundNumber = 1;
    self.closestCall = 289;
    self.roundNumber = 1;
    
    [self.frameScoreText setTitle:@"TOSS" forState:UIControlStateNormal];
    [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
    
    self.frame1Score.text = @"";
    self.frame2Score.text = @"";
    self.frame3Score.text = @"";
    self.frame4Score.text = @"";
    self.frame5Score.text = @"";
    self.frame6Score.text = @"";
    self.frame7Score.text = @"";
    self.frame8Score.text = @"";
    
    self.totalScore = 0;
    
    self.roundScore = 0;
    
    self.pointsToGo = 88;
    self.passed88 = NO;
    
    self.frameNumber = 0;
    
    self.pointsToGoText.textColor =
        [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
    
    NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
    NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
    NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
    
    self.totalScoreText.text  = totalScoreString;
    self.roundScoreText.text  = roundScoreString;
    self.pointsToGoText.text  = pointsToGoString;
    
    self.roundScoreText.textColor = [UIColor whiteColor];
    self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    for(int i = 0; i < 8; i++)
    {
        [self.coinScores replaceObjectAtIndex:i
                                   withObject:[NSNumber numberWithInteger:i+1]];
        [self.frameScores replaceObjectAtIndex:i
                                    withObject:[NSNumber numberWithInteger:0]];
    }
    
    // reset all holes to unmatched state
    UIButton *button = self.hole1;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:0] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole2;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:1] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole3;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:2] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole4;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:3] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole5;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:4] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole6;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:5] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole7;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:6] integerValue]]
            forState:(UIControlStateNormal)];
    button = self.hole8;
    [button setHidden:YES];
    [button setTitle:[NSString stringWithFormat:@"%d",
                      [[self.coinScores objectAtIndex:7] integerValue]]
            forState:(UIControlStateNormal)];
    
    self.emptyHoleLabel1.text = @"";
    self.emptyHoleLabel2.text = @"";
    self.emptyHoleLabel3.text = @"";
    self.emptyHoleLabel4.text = @"";
    self.emptyHoleLabel5.text = @"";
    self.emptyHoleLabel6.text = @"";
    self.emptyHoleLabel7.text = @"";
    self.emptyHoleLabel8.text = @"";

    
    self.readyToToss = YES;
}

- (IBAction)offerUpgrade:(id)sender
{
    [self.view setUserInteractionEnabled:NO];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"UPGRADE TO OCHO PLUS?"
                                                   message:@"Do you want to upgrade to OCHO PLUS to unlock unlimited rounds and alternate coin sets?"];
    
    [alert setCancelButtonWithTitle:@"NO" block:^
     {
         [self.view setUserInteractionEnabled:YES];
         [self.activityIndicator stopAnimating];
         
     }];
    
    
    [alert setDestructiveButtonWithTitle:@"YES" block:^
     {
         [self.view setUserInteractionEnabled:NO];
         
         SKProductsRequest *request= [[SKProductsRequest alloc]
                                      initWithProductIdentifiers: [NSSet setWithObject: @"com.adamzappl.ochosimple.unlimitedrounds3"]];
         request.delegate = self;
         
         [self.activityIndicator startAnimating];
         [request start];
         
     }];
    
    [alert show];

}

- (void)tossCoins:(id)sender
{
    
    // clear hole highlights; each hole will light up sequentially during checkMatch
    [self.hole1 setHighlighted:NO];
    [self.hole2 setHighlighted:NO];
    [self.hole3 setHighlighted:NO];
    [self.hole4 setHighlighted:NO];
    [self.hole5 setHighlighted:NO];
    [self.hole6 setHighlighted:NO];
    [self.hole7 setHighlighted:NO];
    [self.hole8 setHighlighted:NO];

    // draw a coin for each unmatched hole
    
	for(int i = 0;i < 8;i++)
	{
        
        // is hole empty?
		
		if ([[self.hole objectAtIndex:i] integerValue] == 0)
		{
            
            // draw from remaining coins
            
			int n = arc4random_uniform(self.numberOfCoinsRemaining);
			[self.hole replaceObjectAtIndex:i withObject:[self.coin objectAtIndex:n]];
			self.numberOfCoinsRemaining--;
            
            // shift coin array
            
			for(int j=n;j<self.numberOfCoinsRemaining;j++)
            {
                [self.coin replaceObjectAtIndex:j withObject:[self.coin objectAtIndex:(j+1)]];
            }
            
		}
	}
    
    // count numberOfMatches
    
	self.numberOfMatches = 0;
    self.frameScore = 0;
	for(int i = 0;i < 8;i++)
	{
        if ([[self.hole objectAtIndex:i] integerValue] == i+1 &&
            [[self.coinScores objectAtIndex:i] integerValue] > 0)
        {
            self.numberOfMatches++;
            self.frameScore += [[self.coinScores objectAtIndex:i] integerValue];
            [self.matchedCoin replaceObjectAtIndex:i
                                        withObject:[NSNumber numberWithBool:YES]];
            
        }
        else
        {
            [self.matchedCoin replaceObjectAtIndex:i
                                        withObject:[NSNumber numberWithBool:NO]];
            
        }
	}
    
    if(self.frameScore == 0 && self.goodInitialToss)
    {
        if(self.soundEnabled)
        {
            // ahh...
            NSString *buzzerPath = [[NSBundle mainBundle]
                                 pathForResource:@"buzzer" ofType:@"wav"];
            NSURL *buzzerURL = [NSURL fileURLWithPath:buzzerPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)buzzerURL, &buzzerSound);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                                    (0.25 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               AudioServicesPlaySystemSound(buzzerSound);
                           });
            [self screenCapture];

        }
        
        NSString *frameScoreString  = [NSString stringWithFormat:@"TOSS"];
        [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];

    }
    /*
    else if(self.frameScore >= 36)
    {
        if(self.soundEnabled)
        {
            // woohoo!
            NSString *woohooPath = [[NSBundle mainBundle]
                                    pathForResource:@"woohoo" ofType:@"wav"];
            NSURL *woohooURL = [NSURL fileURLWithPath:woohooPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)woohooURL, &woohooSound);
            AudioServicesPlaySystemSound(woohooSound);
        }

    }
    */
    
    // highlight matching coins/holes
    self.toneDelay = 0.0;

    self.firstMatchFound = NO;
    self.currentHole = 1;
    [self copyHoles];
    
    // pre-allocate tones
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone1URL, &tone1Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone2URL, &tone2Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone3URL, &tone3Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone4URL, &tone4Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone5URL, &tone5Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone6URL, &tone6Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone7URL, &tone7Sound);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone8URL, &tone8Sound);

    
    /*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                            (0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self scheduleNextMatchCheck];
                   });*/

    // disable user interaction while matches are being displayed
    if(self.soundEnabled)
    {
        [self.view setUserInteractionEnabled:NO];
    }
    
    [self checkMatch];
    
    // enable user interaction
    /*if(self.soundEnabled)
    {
        double lockoutTime = self.numberOfMatches * 0.125;
        if(lockoutTime > 1.0)
        {
            lockoutTime = 1.0;
        }
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                                (lockoutTime * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self.view setUserInteractionEnabled:YES];
                       });
    }*/
    
    if(self.frameScore == 0 &&
       self.goodInitialToss &&
       self.frameNumber == 8 &&
       self.roundScore >= 88 &&
       !self.unlimitedRoundsEnabled &&
       self.roundNumber == self.roundLimit)
    {
        self.globalFromTossCoins = YES;
        self.globalSender = sender;
        [self offerUnlimitedRounds];
    }
    else
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                (0.1 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self processTossCoins:sender];
                       });

    }
    
    [self screenCapture];
        
	return;
}

- (UIButton *)buttonForHoleNumber:(int)holeNumber
{
    if(holeNumber == 1) return self.hole1;
    if(holeNumber == 2) return self.hole2;
    if(holeNumber == 3) return self.hole3;
    if(holeNumber == 4) return self.hole4;
    if(holeNumber == 5) return self.hole5;
    if(holeNumber == 6) return self.hole6;
    if(holeNumber == 7) return self.hole7;
    if(holeNumber == 8) return self.hole8;
    return nil;
}

- (void)scheduleNextMatchCheck
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.holeActivationDelay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self checkMatch];
                   });
}

- (void) copyHoles
{
    [self.holeOld setArray:self.hole];
}

void soundFinishedPlaying(SystemSoundID ssID, void *clientData)
{
	OchoSimpleViewController* object = (__bridge OchoSimpleViewController *)(clientData);
    AudioServicesDisposeSystemSoundID(ssID);
    [object screenCapture];
    [object scheduleNextMatchCheck];
}

- (void)checkMatch
{
    int hole = self.currentHole;
    self.currentHole++;
    dispatch_queue_t serialQueue = dispatch_queue_create("com.ocho.queue", DISPATCH_QUEUE_SERIAL);

    UIButton *activeButton = [self buttonForHoleNumber:hole];
    if(activeButton != nil)
    {
        [activeButton setHighlighted:YES];
    }
    
    if(hole == 1)
    {
        NSString *frameScoreString  = [NSString stringWithFormat:@""];
        [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];

        if([self.matchedCoin objectAtIndex:0] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole1;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 1
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone1URL, &tone1Sound);
                AudioServicesAddSystemSoundCompletion (tone1Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));

                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone1Sound);
                               });

            }
            else
            {
                [self scheduleNextMatchCheck];
            }

        }
        else
        {
            self.emptyHoleLabel1.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:0] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 2)
    {
        if([self.matchedCoin objectAtIndex:1] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole2;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 2
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone2URL, &tone2Sound);
                AudioServicesAddSystemSoundCompletion (tone2Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone2Sound);
                               });
                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel2.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:1] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 3)
    {
        if([self.matchedCoin objectAtIndex:2] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole3;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 3
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone3URL, &tone3Sound);
                AudioServicesAddSystemSoundCompletion (tone3Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone3Sound);
                               });
                                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel3.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:2] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 4)
    {
        if([self.matchedCoin objectAtIndex:3] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole4;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 4
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone4URL, &tone4Sound);
                AudioServicesAddSystemSoundCompletion (tone4Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone4Sound);
                               });
                      
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel4.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:3] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 5)
    {
        if([self.matchedCoin objectAtIndex:4] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole5;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 5
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone5URL, &tone5Sound);
                AudioServicesAddSystemSoundCompletion (tone5Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone5Sound);
                               });
                                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel5.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:4] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 6)
    {
        if([self.matchedCoin objectAtIndex:5] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole6;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 6
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone6URL, &tone6Sound);
                AudioServicesAddSystemSoundCompletion (tone6Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone6Sound);
                               });
                                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel6.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:5] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 7)
    {
        if([self.matchedCoin objectAtIndex:6] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole7;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 7
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone7URL, &tone7Sound);
                AudioServicesAddSystemSoundCompletion (tone7Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone7Sound);
                               });
                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel7.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:6] integerValue]];
            [self scheduleNextMatchCheck];
        }
    }
    else if(hole == 8)
    {
        if([self.matchedCoin objectAtIndex:7] == [NSNumber numberWithBool:YES])
        {
            UIButton *button = self.hole8;
            [button setHidden:NO];
            [button setHighlighted:NO];
            
            if(self.soundEnabled)
            {
                // tone 8
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)tone8URL, &tone8Sound);
                AudioServicesAddSystemSoundCompletion (tone8Sound,NULL,NULL,soundFinishedPlaying,(__bridge void *)(self));
                
                dispatch_async(serialQueue, ^(void)
                               {
                                   AudioServicesPlaySystemSound(tone8Sound);
                               });
                
            }
            else
            {
                [self scheduleNextMatchCheck];
            }
            
        }
        else
        {
            self.emptyHoleLabel8.text =
            [NSString stringWithFormat:@"%d",[[self.holeOld objectAtIndex:7] integerValue]];
            [self scheduleNextMatchCheck];
        }
        
        if(self.numberOfMatches > 0)
        {
            NSString *frameScoreString  = [NSString stringWithFormat:@"%d",self.frameScore];
            [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];
        }
        else
        {
            if(self.roundScore > 88 && self.frameNumber == 8)
            {
                [self.frameScoreText setTitle:[NSString stringWithFormat:@"NEXT"]
                                     forState:UIControlStateNormal];
                [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];

            }
            else
            {
                NSString *frameScoreString  = [NSString stringWithFormat:@"TOSS"];
                [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];
            }
        }
        
        // set all holes to un-highlighted state
        [self.hole1 setHighlighted:NO];
        [self.hole2 setHighlighted:NO];
        [self.hole3 setHighlighted:NO];
        [self.hole4 setHighlighted:NO];
        [self.hole5 setHighlighted:NO];
        [self.hole6 setHighlighted:NO];
        [self.hole7 setHighlighted:NO];
        [self.hole8 setHighlighted:NO];

        [self.view setUserInteractionEnabled:YES];

    }
    
    return;
}

- (IBAction)holeOneClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);

    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:0] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:1]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeTwoClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);

    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:1] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:2]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeThreeClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:2] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:3]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeFourClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:3] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:4]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeFiveClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:4] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:5]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeSixClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:5] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:5 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:6]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeSevenClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:6] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:6 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:6 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:7]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (IBAction)holeEightClick:(id)sender
{
    AudioServicesDisposeSystemSoundID(tone1Sound);
    AudioServicesDisposeSystemSoundID(tone2Sound);
    AudioServicesDisposeSystemSoundID(tone3Sound);
    AudioServicesDisposeSystemSoundID(tone4Sound);
    AudioServicesDisposeSystemSoundID(tone5Sound);
    AudioServicesDisposeSystemSoundID(tone6Sound);
    AudioServicesDisposeSystemSoundID(tone7Sound);
    AudioServicesDisposeSystemSoundID(tone8Sound);
    AudioServicesDisposeSystemSoundID(buzzerSound);
    AudioServicesDisposeSystemSoundID(woohooSound);
    AudioServicesDisposeSystemSoundID(chachingSound);
    
    UIButton *button = sender;
    if([self.matchedCoin objectAtIndex:7] == [NSNumber numberWithBool:YES])
    {
        [button setHidden:YES];
        [self.matchedCoin replaceObjectAtIndex:7 withObject:[NSNumber numberWithBool:NO]];
        [self.hole replaceObjectAtIndex:7 withObject:[NSNumber numberWithInteger:0]];
        self.numberOfMatches--;
        [self.coin replaceObjectAtIndex:(7-self.numberOfMatches) withObject:[NSNumber numberWithInteger:8]];
        self.numberOfCoinsRemaining = 8 - self.numberOfMatches;
        [self tossCoins:sender];
    }
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Options"])
	{
        OptionsViewController *optionsViewController = segue.destinationViewController;
        optionsViewController.delegate = self;
        optionsViewController.flipDisplayEnabled = self.flipDisplayEnabled;
        optionsViewController.unlimitedRoundsEnabled = self.unlimitedRoundsEnabled;
        optionsViewController.playerName = self.playerName;
        optionsViewController.soundEnabled = self.soundEnabled;
        optionsViewController.coinSet = self.selectedCoinSet;
        optionsViewController.unlockedCoinSets = [[NSMutableArray alloc] init];
        [optionsViewController.unlockedCoinSets setArray:self.unlockedCoinSets];
    }
    else if([segue.identifier isEqualToString:@"GameOver"])
	{
        
        
        if(![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:1]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:1]];
        }
        
        if(self.roundNumber > 1 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:2]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:2]];
        }
        
        if(self.totalScore > 100 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:3]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:3]];
        }
        
        if(self.roundNumber > 2 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:4]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:4]];
        }
        
        if(self.totalScore > 200 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:5]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:5]];
        }
        
        if(self.roundNumber > 3 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:6]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:6]];
        }
        
        if(self.totalScore > 300 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:7]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:7]];
        }
        
        if((self.roundNumber > 4 ||
           (self.roundNumber == 4 && [[self.roundScores objectAtIndex:3] intValue] >= 88)) &&
            ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:8]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:8]];
        }
        
        if(self.totalScore > 400 &&
           ![self.unlockedCoinSets containsObject:[NSNumber numberWithInteger:9]])
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:9]];
        }
        
        
        GameOverViewController *gameOverViewController = segue.destinationViewController;
        gameOverViewController.finalScore = self.totalScore;
        gameOverViewController.bestRound = self.bestRound;
        self.bestRound = 0;
        gameOverViewController.bestRoundNumber = self.bestRoundNumber;
        self.bestRoundNumber = 1;
        gameOverViewController.closestCall = self.closestCall;
        self.closestCall = 289;
        gameOverViewController.roundNumber = self.roundNumber;
        self.roundNumber = 1;
        gameOverViewController.playerName = self.playerName;
        gameOverViewController.roundScores = [[NSMutableArray alloc] init];
        [gameOverViewController.roundScores setArray:self.roundScores];
        
        [self.roundScores removeAllObjects];
        
        [self.frameScoreText setTitle:@"TOSS" forState:UIControlStateNormal];
        [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
        
        self.frame1Score.text = @"";
        self.frame2Score.text = @"";
        self.frame3Score.text = @"";
        self.frame4Score.text = @"";
        self.frame5Score.text = @"";
        self.frame6Score.text = @"";
        self.frame7Score.text = @"";
        self.frame8Score.text = @"";
        
        if(self.roundScore < 88 || !self.unlimitedRoundsEnabled)
        {
            self.totalScore = 0;
        }
        
        self.roundScore = 0;
        
        self.pointsToGo = 88;
        self.passed88 = NO;
        
        if(self.pointsToGo > 0)
        {
            self.pointsToGoText.textColor =
            [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
        }
        
        NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
        NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
        NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
        
        self.totalScoreText.text  = totalScoreString;
        self.roundScoreText.text  = roundScoreString;
        self.pointsToGoText.text  = pointsToGoString;
        
        self.roundScoreText.textColor = [UIColor whiteColor];
        self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        self.emptyHoleLabel1.text = @"";
        self.emptyHoleLabel2.text = @"";
        self.emptyHoleLabel3.text = @"";
        self.emptyHoleLabel4.text = @"";
        self.emptyHoleLabel5.text = @"";
        self.emptyHoleLabel6.text = @"";
        self.emptyHoleLabel7.text = @"";
        self.emptyHoleLabel8.text = @"";
        
        if(self.totalScore > 100)
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:2]];
        }
        
        if(self.totalScore > 100)
        {
            [self.unlockedCoinSets addObject:[NSNumber numberWithInteger:2]];
        }
        
        NSMutableDictionary *feature = [[NSMutableDictionary alloc]init];
        
        // apply new settings
        [feature setObject:[NSString stringWithFormat:@"%@", self.unlimitedRoundsEnabled ? @"YES" : @"NO"] forKey:@"unlimitedRounds"];
        
        [feature setObject:[NSString stringWithFormat:@"%@", self.flipDisplayEnabled ? @"YES" : @"NO"] forKey:@"flipDisplay"];
        
        [feature setObject:[NSString stringWithFormat:@"%@", self.soundEnabled ? @"YES" : @"NO"] forKey:@"sound"];
        
        [feature setObject:self.playerName forKey:@"playerName"];
        
        [feature setObject:@"0" forKey:@"freeRounds"];
        
        [feature setObject:[NSString stringWithFormat:@"%d", self.selectedCoinSet] forKey:@"coinSet"];

        [feature setObject:self.unlockedCoinSets forKey:@"unlockedCoinSets"];
        
        // write features file
        [feature writeToFile:self.enabledFeaturesPath atomically:YES];

        
    }
}

- (void) offerUnlimitedRounds
{
    [self.view setUserInteractionEnabled:NO];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"UPGRADE TO OCHO PLUS?"
                                                   message:@"You have reached the round limit in this game. Do you want to upgrade to OCHO PLUS to unlock unlimited rounds?"];
    
    [alert setCancelButtonWithTitle:@"NO" block:^
     {
         [self.view setUserInteractionEnabled:YES];
         [self.activityIndicator stopAnimating];
         
         if(self.globalFromTossCoins)
         {
             [self processTossCoins:self.globalSender];
         }
         else
         {
             [self processNextTurn:self.globalSender];
         }
     }];
    
    
    [alert setDestructiveButtonWithTitle:@"YES" block:^
     {
         //self.unlimitedRoundsEnabled = YES;
         [self.view setUserInteractionEnabled:NO];
         
         SKProductsRequest *request= [[SKProductsRequest alloc]
                                      initWithProductIdentifiers: [NSSet setWithObject: @"com.adamzappl.ochosimple.unlimitedrounds3"]];
         request.delegate = self;
                  
         [self.activityIndicator startAnimating];
         [request start];
         
     }];
    
    [alert show];
    
}

- (void) unlockUnlimitedRounds
{
        
    NSMutableDictionary *feature = [[NSMutableDictionary alloc]init];
    
    if(self.unlimitedRoundsEnabled)
    {
        // enable unlimited rounds
        [feature setObject:@"YES" forKey:@"unlimitedRounds"];
        
        // write features file
        [feature writeToFile:self.enabledFeaturesPath atomically:YES];
    }
    
    [self.view setUserInteractionEnabled:YES];
    [self.activityIndicator stopAnimating];
    
    if(self.globalFromTossCoins)
    {
        [self processTossCoins:self.globalSender];
    }
    else
    {
        [self processNextTurn:self.globalSender];
    }
    
}

- (void)processNextTurn:(id)sender
{
    [self screenCapture];
    
    self.goodInitialToss = NO;
    
    NSString *frameScoreString  = [NSString stringWithFormat:@"%d",self.frameScore];
            
    if(self.frameNumber > 0)
    {
        [self.frameScores replaceObjectAtIndex:(self.frameNumber-1)
                                    withObject:[NSNumber numberWithInteger:self.frameScore]];
    }
    else
    {
        if(!self.readyToToss)
        {
            self.roundNumber++;
        }
    }
    
    if(!self.readyToToss)
    {
        if(self.frameNumber == 1)
        {
            self.frame1Score.text = frameScoreString;
        }
        else if(self.frameNumber == 2)
        {
            self.frame2Score.text = frameScoreString;
        }
        else if(self.frameNumber == 3)
        {
            self.frame3Score.text = frameScoreString;
        }
        else if(self.frameNumber == 4)
        {
            self.frame4Score.text = frameScoreString;
        }
        else if(self.frameNumber == 5)
        {
            self.frame5Score.text = frameScoreString;
        }
        else if(self.frameNumber == 6)
        {
            self.frame6Score.text = frameScoreString;
        }
        else if(self.frameNumber == 7)
        {
            self.frame7Score.text = frameScoreString;
        }
        else if(self.frameNumber == 8)
        {
            self.frame8Score.text = frameScoreString;
        }
        
    }
    
    self.roundScoreText.textColor = [UIColor whiteColor];
    self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
    UIButton *button = sender;
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:60.0]];
    
    // display total score at end of game
    if(self.frameNumber == 8)
    {
        
        self.totalScore += self.frameScore;
        self.roundScore += self.frameScore;
        self.pointsToGo = 88 - self.roundScore;
        self.frameScore  = 0;
        
        if(self.roundScore >= 88)
        {
            self.roundScoreText.textColor = [UIColor greenColor];
            self.roundScoreText.layer.borderColor = [[UIColor greenColor] CGColor];
            
            if(!self.passed88 && self.soundEnabled)
            {
                // woohoo!
                NSString *woohooPath = [[NSBundle mainBundle]
                                        pathForResource:@"woohoo" ofType:@"wav"];
                NSURL *woohooURL = [NSURL fileURLWithPath:woohooPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)woohooURL, &woohooSound);
                AudioServicesPlaySystemSound(woohooSound);
                [self screenCapture];

            }
            else
            {
                if(self.soundEnabled && !self.readyToToss)
                {
                    
                    // chaching!
                    NSString *chachingPath = [[NSBundle mainBundle]
                                              pathForResource:@"chaching" ofType:@"wav"];
                    NSURL *chachingURL = [NSURL fileURLWithPath:chachingPath];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)chachingURL, &chachingSound);
                    AudioServicesPlaySystemSound(chachingSound);
                    [self screenCapture];

                    
                }
                
            }

            self.passed88 = YES;

        }
        else
        {
            if(self.soundEnabled && !self.readyToToss)
            {
                
                // chaching!
                NSString *chachingPath = [[NSBundle mainBundle]
                                          pathForResource:@"chaching" ofType:@"wav"];
                NSURL *chachingURL = [NSURL fileURLWithPath:chachingPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)chachingURL, &chachingSound);
                AudioServicesPlaySystemSound(chachingSound);
                [self screenCapture];

            }
            
        }

        
        if(self.pointsToGo > 0)
        {
            self.pointsToGoText.textColor =
            [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
        }
        else
        {
            self.pointsToGoText.textColor = [UIColor greenColor];
            self.pointsToGo = 0;
        }
        
        NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
        NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
        NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
        
        self.totalScoreText.text  = totalScoreString;
        self.roundScoreText.text  = roundScoreString;
        self.pointsToGoText.text  = pointsToGoString;
        
        self.frameNumber = 0;
        
        if(!self.readyToToss)
        {
            
            if(self.roundScore > self.bestRound)
            {
                self.bestRound = self.roundScore;
                self.bestRoundNumber = self.roundNumber;
            }
            
            if(self.roundScore >= 88 && self.roundScore < self.closestCall)
            {
                self.closestCall = self.roundScore;
            }
            
            [self.roundScores addObject:[NSNumber numberWithInteger:self.roundScore]];
            
            if(self.roundScore < 88 || (!self.unlimitedRoundsEnabled && self.roundNumber == self.roundLimit))
            {
                
                for(int i = 0; i < 8; i++)
                {
                    [self.coinScores replaceObjectAtIndex:i
                                               withObject:[NSNumber numberWithInteger:i+1]];
                    [self.frameScores replaceObjectAtIndex:i
                                                withObject:[NSNumber numberWithInteger:0]];
                }
                
                self.frameScoreText.enabled = NO;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                                        (self.delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   [self performSegueWithIdentifier:@"GameOver" sender:self];
                                   self.frameScoreText.enabled = YES;
                               });
                
                
                self.readyToToss = YES;
            }
            else
            {
                [button setTitle:[NSString stringWithFormat:@"NEXT"] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
                
                for(int i = 0; i < 8; i++)
                {
                    [self.coinScores replaceObjectAtIndex:i
                                               withObject:[NSNumber numberWithInteger:i+1]];
                    [self.frameScores replaceObjectAtIndex:i
                                                withObject:[NSNumber numberWithInteger:0]];
                }
            }
            
            // reset all holes to unmatched state
            button = self.hole1;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:0] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole2;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:1] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole3;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:2] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole4;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:3] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole5;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:4] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole6;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:5] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole7;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:6] integerValue]]
                    forState:(UIControlStateNormal)];
            button = self.hole8;
            [button setHidden:YES];
            [button setTitle:[NSString stringWithFormat:@"%d",
                              [[self.coinScores objectAtIndex:7] integerValue]]
                    forState:(UIControlStateNormal)];
            
        }
        else
        {
            [button setTitle:@"TOSS" forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
            
            self.frame1Score.text = @"";
            self.frame2Score.text = @"";
            self.frame3Score.text = @"";
            self.frame4Score.text = @"";
            self.frame5Score.text = @"";
            self.frame6Score.text = @"";
            self.frame7Score.text = @"";
            self.frame8Score.text = @"";
            
            if(self.roundScore < 88 || (!self.unlimitedRoundsEnabled && self.roundNumber > self.roundLimit))
            {
                self.totalScore = 0;
            }
            
            self.roundScore = 0;
            
            self.pointsToGo = 88;
            self.passed88 = NO;
            
            if(self.pointsToGo > 0)
            {
                self.pointsToGoText.textColor =
                [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
            }
            
            NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
            NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
            NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
            
            self.totalScoreText.text  = totalScoreString;
            self.roundScoreText.text  = roundScoreString;
            self.pointsToGoText.text  = pointsToGoString;
            
            self.roundScoreText.textColor = [UIColor whiteColor];
            self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
            
        }
        
        self.roundScore = 0;
        self.passed88 = NO;
        
        self.emptyHoleLabel1.text = @"";
        self.emptyHoleLabel2.text = @"";
        self.emptyHoleLabel3.text = @"";
        self.emptyHoleLabel4.text = @"";
        self.emptyHoleLabel5.text = @"";
        self.emptyHoleLabel6.text = @"";
        self.emptyHoleLabel7.text = @"";
        self.emptyHoleLabel8.text = @"";
        
        return;
    }
    
    // reset round/scores if starting a new round
    if(self.frameNumber == 0)
    {
        
        self.frameNumber = 0;
        self.frameScore  = 0;
        
        NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
        NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
        NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
        
        self.totalScoreText.text  = totalScoreString;
        self.roundScoreText.text  = roundScoreString;
        self.pointsToGoText.text  = pointsToGoString;
        
        self.frame1Score.text = @"";
        self.frame2Score.text = @"";
        self.frame3Score.text = @"";
        self.frame4Score.text = @"";
        self.frame5Score.text = @"";
        self.frame6Score.text = @"";
        self.frame7Score.text = @"";
        self.frame8Score.text = @"";
        
    }
    
    
    // reset all holes to unmatched state
    button = self.hole1;
    [button setHidden:YES];
    button = self.hole2;
    [button setHidden:YES];
    button = self.hole3;
    [button setHidden:YES];
    button = self.hole4;
    [button setHidden:YES];
    button = self.hole5;
    [button setHidden:YES];
    button = self.hole6;
    [button setHidden:YES];
    button = self.hole7;
    [button setHidden:YES];
    button = self.hole8;
    [button setHidden:YES];
    
    self.emptyHoleLabel1.text = @"";
    self.emptyHoleLabel2.text = @"";
    self.emptyHoleLabel3.text = @"";
    self.emptyHoleLabel4.text = @"";
    self.emptyHoleLabel5.text = @"";
    self.emptyHoleLabel6.text = @"";
    self.emptyHoleLabel7.text = @"";
    self.emptyHoleLabel8.text = @"";
    
    
    self.totalScore += self.frameScore;
    self.roundScore += self.frameScore;
    self.pointsToGo = 88 - self.roundScore;
    
    if(self.roundScore >= 88)
    {
        self.roundScoreText.textColor = [UIColor greenColor];
        self.roundScoreText.layer.borderColor = [[UIColor greenColor] CGColor];
        
        if(self.soundEnabled && !self.readyToToss)
        {
            if(!self.passed88)
            {
                // woohoo!
                NSString *woohooPath = [[NSBundle mainBundle]
                                        pathForResource:@"woohoo" ofType:@"wav"];
                NSURL *woohooURL = [NSURL fileURLWithPath:woohooPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)woohooURL, &woohooSound);
                AudioServicesPlaySystemSound(woohooSound);
                
            }
            else
            {
                // chaching!
                NSString *chachingPath = [[NSBundle mainBundle]
                                          pathForResource:@"chaching" ofType:@"wav"];
                NSURL *chachingURL = [NSURL fileURLWithPath:chachingPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)chachingURL, &chachingSound);
                AudioServicesPlaySystemSound(chachingSound);
                [self screenCapture];

            }

        }
        self.passed88 = YES;

    }
    else if(self.frameNumber > 0)
    {
        if(self.soundEnabled && !self.readyToToss)
        {
            
            // chaching!
            NSString *chachingPath = [[NSBundle mainBundle]
                                      pathForResource:@"chaching" ofType:@"wav"];
            NSURL *chachingURL = [NSURL fileURLWithPath:chachingPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)chachingURL, &chachingSound);
            AudioServicesPlaySystemSound(chachingSound);
            [self screenCapture];

        }
        
    }
    
    if(self.pointsToGo > 0)
    {
        self.pointsToGoText.textColor =
        [UIColor colorWithRed:196./255. green:24./255. blue:20./255. alpha:1];
    }
    else
    {
        self.pointsToGoText.textColor = [UIColor greenColor];
        self.pointsToGo = 0;
    }
    
    
    self.frameScore = 0;
    
    // reset button to point to "next turn"
    button = sender;
    
    if(!self.readyToToss)
    {
        self.readyToToss = YES;
        [button setTitle:@"TOSS" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
        
        NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
        NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
        NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
        
        self.totalScoreText.text  = totalScoreString;
        self.roundScoreText.text  = roundScoreString;
        self.pointsToGoText.text  = pointsToGoString;
        
        return;
    }
    
    // prepare arrays for next turn
    self.numberOfCoinsRemaining = 8;
    for(int i = 0; i < 8; i++)
    {
        [self.coin replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:i+1]];
        [self.hole replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
        [self.matchedCoin replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
    
    self.frameNumber++;
    
    while(!self.goodInitialToss)
    {
        self.numberOfCoinsRemaining = 8;
        
        for(int i = 0; i < 8; i++)
        {
            [self.coin replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:i+1]];
            [self.hole replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
            [self.matchedCoin replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
        
        [self tossCoins:sender];
        
        if(self.numberOfMatches > 0)
        {
            self.goodInitialToss = YES;
        }
        
    }
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:60.0]];
    self.readyToToss = NO;
    
    // clear unmatched holes and reload coins
    int j = 0;
    for(int i = 0;i < 8;i++)
    {
        if ([[self.hole objectAtIndex:i] integerValue] != i+1)
        {
            self.coin[j] = self.hole[i];
            self.hole[i] = [NSNumber numberWithInteger:0];
            j++;
        }
    }
    
    [self screenCapture];
    
}

- (void) processTossCoins:(id)sender
{
    [self screenCapture];
    
    NSString *frameScoreString  = [NSString stringWithFormat:@"%d",self.frameScore];
    
    if(self.frameScore == 0 && self.goodInitialToss)
    {
        frameScoreString = @"TOSS";
        self.readyToToss = YES;
        [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:25.0]];
        if(self.frameNumber == 8)
        {
            if(self.roundScore > self.bestRound)
            {
                self.bestRound = self.roundScore;
                self.bestRoundNumber = self.roundNumber;
            }
            
            if(self.roundScore >= 88)
            {
                if(self.roundScore < self.closestCall)
                {
                    self.closestCall = self.roundScore;
                }
                
            }
            
            if(self.roundNumber > [self.roundScores count])
            {
                [self.roundScores addObject:[NSNumber numberWithInteger:self.roundScore]];
            }
            else
            {
                [self.roundScores replaceObjectAtIndex:(self.roundNumber-1) withObject:[NSNumber numberWithInteger:self.roundScore]];
            }
            
            if((!self.unlimitedRoundsEnabled && self.roundNumber == self.roundLimit) || self.roundScore < 88)
            {
                frameScoreString = @"0";
                [self.frameScoreText.titleLabel setFont:[UIFont boldSystemFontOfSize:65.0]];
                [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];
                
                self.frameScoreText.enabled = NO;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)
                                                        (self.delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   [self performSegueWithIdentifier:@"GameOver" sender:self];
                                   self.frameScoreText.enabled = YES;
                               });
                
                NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
                NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
                NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
                
                self.totalScoreText.text  = totalScoreString;
                self.roundScoreText.text  = roundScoreString;
                self.pointsToGoText.text  = pointsToGoString;
                
                self.roundScoreText.textColor = [UIColor whiteColor];
                self.roundScoreText.layer.borderColor = [[UIColor whiteColor] CGColor];
                
                self.readyToToss = YES;
                
                self.frameNumber = 0;
                
                self.frame8Score.text = frameScoreString;
                
                return;
                
            }
            else
            {
                frameScoreString = [NSString stringWithFormat:@"NEXT"];
                self.readyToToss = YES;
                
                if(self.roundScore >= 88)
                {
                    self.roundNumber++;
                }

            }
            
        }
        
        self.emptyHoleLabel1.text = @"";
        self.emptyHoleLabel2.text = @"";
        self.emptyHoleLabel3.text = @"";
        self.emptyHoleLabel4.text = @"";
        self.emptyHoleLabel5.text = @"";
        self.emptyHoleLabel6.text = @"";
        self.emptyHoleLabel7.text = @"";
        self.emptyHoleLabel8.text = @"";
        
        NSString *frameScoreString2  = [NSString stringWithFormat:@"%d",self.frameScore];
        
        if(self.goodInitialToss)
        {
            if(self.frameNumber == 1)
            {
                self.frame1Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 2)
            {
                self.frame2Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 3)
            {
                self.frame3Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 4)
            {
                self.frame4Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 5)
            {
                self.frame5Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 6)
            {
                self.frame6Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 7)
            {
                self.frame7Score.text = frameScoreString2;
            }
            else if(self.frameNumber == 8)
            {
                self.frame8Score.text = frameScoreString2;
            }
        }
        
    }
    
    NSString *totalScoreString  = [NSString stringWithFormat:@"%d",self.totalScore];
    NSString *roundScoreString  = [NSString stringWithFormat:@" %d",self.roundScore];
    NSString *pointsToGoString  = [NSString stringWithFormat:@"%d ",self.pointsToGo];
    
    self.totalScoreText.text  = totalScoreString;
    self.roundScoreText.text  = roundScoreString;
    self.pointsToGoText.text  = pointsToGoString;
    
    if(!self.soundEnabled)
    {
        [self.frameScoreText setTitle:frameScoreString forState:(UIControlStateNormal)];
    }
    
    [self screenCapture];

}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSArray *myProduct = response.products;
    if([myProduct count] > 0)
    {
        NSLog(@"%@",[[myProduct objectAtIndex:0] productIdentifier]);
        
        //Since only one product, we do not need to choose from the array. Proceed directly to payment.
        
        SKPayment *newPayment = [SKPayment paymentWithProduct:[myProduct objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:newPayment];

    }
    else
    {
        if(self.globalFromTossCoins)
        {
            [self processTossCoins:self.globalSender];
        }
        else
        {
            [self processNextTurn:self.globalSender];
        }
    }
    
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");

    self.unlimitedRoundsEnabled = YES;
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self unlockUnlimitedRounds];

}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restored");

    self.unlimitedRoundsEnabled = YES;
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [self unlockUnlimitedRounds];

}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    // Display an error here.
    
    [self.view setUserInteractionEnabled:NO];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"PURCHASE INCOMPLETE"
                                                   message:@"Your purchase failed or was cancelled. Try again?"];
    
    [alert setCancelButtonWithTitle:@"NO" block:^
     {
         [self.view setUserInteractionEnabled:YES];
         [self.activityIndicator stopAnimating];

         if(self.globalFromTossCoins)
         {
             [self processTossCoins:self.globalSender];
         }
         else
         {
             [self processNextTurn:self.globalSender];
         }
     }];
    
    
    [alert setDestructiveButtonWithTitle:@"YES" block:^
     {
         //self.unlimitedRoundsEnabled = YES;
         [self.view setUserInteractionEnabled:NO];
         
         SKProductsRequest *request= [[SKProductsRequest alloc]
                                      initWithProductIdentifiers: [NSSet setWithObject: @"com.adamzappl.ochosimple.unlimitedrounds3"]];
         request.delegate = self;
         
         [self.activityIndicator startAnimating];
         [request start];
         
     }];
    
    [alert show];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) screenCapture
{
    /*if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
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

    NSData * data = UIImagePNGRepresentation(image);
    
    NSString *screenshotName = [NSString stringWithFormat:@"screenshot%d.png", self.numScreenshots];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagePath =
    [[paths objectAtIndex:0] stringByAppendingPathComponent:screenshotName];
    
    [data writeToFile:imagePath atomically:YES];
    
    self.numScreenshots++;*/
}


#pragma mark - OptionsViewControllerDelegate

- (void)optionsViewControllerApplyOptions:(OptionsViewController *)controller
                            flipDisplayOn:(bool)flipDisplaySwitchValue
                        unlimitedRoundsOn:(bool)unlimitedRoundsSwitchValue
                                  soundOn:(bool)soundSwitchValue
                               playerName:(NSString*)playerName
                                  coinSet:(int)selectedCoinSet;
{
	self.flipDisplayEnabled = flipDisplaySwitchValue;
    
    //self.unlimitedRoundsEnabled = unlimitedRoundsSwitchValue;
    
    self.playerName = playerName;
    
    self.soundEnabled = soundSwitchValue;
    
    self.selectedCoinSet = selectedCoinSet;
    
    NSMutableDictionary *feature = [[NSMutableDictionary alloc]init];
    
    // apply new settings
    [feature setObject:[NSString stringWithFormat:@"%@", self.unlimitedRoundsEnabled ? @"YES" : @"NO"] forKey:@"unlimitedRounds"];
    
    [feature setObject:[NSString stringWithFormat:@"%@", self.flipDisplayEnabled ? @"YES" : @"NO"] forKey:@"flipDisplay"];
    
    [feature setObject:[NSString stringWithFormat:@"%@", self.soundEnabled ? @"YES" : @"NO"] forKey:@"sound"];
    
    [feature setObject:self.playerName forKey:@"playerName"];
    
    [feature setObject:@"0" forKey:@"freeRounds"];
  
    [feature setObject:[NSString stringWithFormat:@"%d", self.selectedCoinSet] forKey:@"coinSet"];
    
    [feature setObject:self.unlockedCoinSets forKey:@"unlockedCoinSets"];

    // write features file
    [feature writeToFile:self.enabledFeaturesPath atomically:YES];

    // check for 4 inch display
    if(self.isWidescreen)
    {
        if(!self.flipDisplayEnabled)
        {
            self.hole1.frame = CGRectMake(252,24,48,48);
            self.hole2.frame = CGRectMake(252,92,48,48);
            self.hole3.frame = CGRectMake(252,160,48,48);
            self.hole4.frame = CGRectMake(252,228,48,48);
            self.hole5.frame = CGRectMake(252,296,48,48);
            self.hole6.frame = CGRectMake(252,364,48,48);
            self.hole7.frame = CGRectMake(252,432,48,48);
            self.hole8.frame = CGRectMake(252,500,48,48);
            
            self.emptyHole1.frame = CGRectMake(252,24,48,48);
            self.emptyHole2.frame = CGRectMake(252,92,48,48);
            self.emptyHole3.frame = CGRectMake(252,160,48,48);
            self.emptyHole4.frame = CGRectMake(252,228,48,48);
            self.emptyHole5.frame = CGRectMake(252,296,48,48);
            self.emptyHole6.frame = CGRectMake(252,364,48,48);
            self.emptyHole7.frame = CGRectMake(252,432,48,48);
            self.emptyHole8.frame = CGRectMake(252,500,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(252,24,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(252,92,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(252,160,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(252,228,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(252,296,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(252,364,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(252,432,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(252,500,48,48);
            
            self.frame1Score.frame = CGRectMake(20,24,48,48);
            self.frame2Score.frame = CGRectMake(20,92,48,48);
            self.frame3Score.frame = CGRectMake(20,160,48,48);
            self.frame4Score.frame = CGRectMake(20,228,48,48);
            self.frame5Score.frame = CGRectMake(20,296,48,48);
            self.frame6Score.frame = CGRectMake(20,364,48,48);
            self.frame7Score.frame = CGRectMake(20,432,48,48);
            self.frame8Score.frame = CGRectMake(20,500,48,48);
        }
        else
        {
            self.hole1.frame = CGRectMake(20,24,48,48);
            self.hole2.frame = CGRectMake(20,92,48,48);
            self.hole3.frame = CGRectMake(20,160,48,48);
            self.hole4.frame = CGRectMake(20,228,48,48);
            self.hole5.frame = CGRectMake(20,296,48,48);
            self.hole6.frame = CGRectMake(20,364,48,48);
            self.hole7.frame = CGRectMake(20,432,48,48);
            self.hole8.frame = CGRectMake(20,500,48,48);
            
            self.emptyHole1.frame = CGRectMake(20,24,48,48);
            self.emptyHole2.frame = CGRectMake(20,92,48,48);
            self.emptyHole3.frame = CGRectMake(20,160,48,48);
            self.emptyHole4.frame = CGRectMake(20,228,48,48);
            self.emptyHole5.frame = CGRectMake(20,296,48,48);
            self.emptyHole6.frame = CGRectMake(20,364,48,48);
            self.emptyHole7.frame = CGRectMake(20,432,48,48);
            self.emptyHole8.frame = CGRectMake(20,500,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(20,24,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(20,92,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(20,160,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(20,228,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(20,296,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(20,364,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(20,432,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(20,500,48,48);
            
            self.frame1Score.frame = CGRectMake(252,24,48,48);
            self.frame2Score.frame = CGRectMake(252,92,48,48);
            self.frame3Score.frame = CGRectMake(252,160,48,48);
            self.frame4Score.frame = CGRectMake(252,228,48,48);
            self.frame5Score.frame = CGRectMake(252,296,48,48);
            self.frame6Score.frame = CGRectMake(252,364,48,48);
            self.frame7Score.frame = CGRectMake(252,432,48,48);
            self.frame8Score.frame = CGRectMake(252,500,48,48);
        }
        
    }
    else
    {        
        if(!self.flipDisplayEnabled)
        {
            self.hole1.frame = CGRectMake(252,20,48,48);
            self.hole2.frame = CGRectMake(252,76,48,48);
            self.hole3.frame = CGRectMake(252,132,48,48);
            self.hole4.frame = CGRectMake(252,188,48,48);
            self.hole5.frame = CGRectMake(252,244,48,48);
            self.hole6.frame = CGRectMake(252,300,48,48);
            self.hole7.frame = CGRectMake(252,356,48,48);
            self.hole8.frame = CGRectMake(252,412,48,48);
            
            self.emptyHole1.frame = CGRectMake(252,20,48,48);
            self.emptyHole2.frame = CGRectMake(252,76,48,48);
            self.emptyHole3.frame = CGRectMake(252,132,48,48);
            self.emptyHole4.frame = CGRectMake(252,188,48,48);
            self.emptyHole5.frame = CGRectMake(252,244,48,48);
            self.emptyHole6.frame = CGRectMake(252,300,48,48);
            self.emptyHole7.frame = CGRectMake(252,356,48,48);
            self.emptyHole8.frame = CGRectMake(252,412,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(252,20,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(252,76,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(252,132,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(252,188,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(252,244,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(252,300,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(252,356,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(252,412,48,48);
            
            self.frame1Score.frame = CGRectMake(20,20,48,48);
            self.frame2Score.frame = CGRectMake(20,76,48,48);
            self.frame3Score.frame = CGRectMake(20,132,48,48);
            self.frame4Score.frame = CGRectMake(20,188,48,48);
            self.frame5Score.frame = CGRectMake(20,244,48,48);
            self.frame6Score.frame = CGRectMake(20,300,48,48);
            self.frame7Score.frame = CGRectMake(20,356,48,48);
            self.frame8Score.frame = CGRectMake(20,412,48,48);
        }
        else
        {
            self.hole1.frame = CGRectMake(20,20,48,48);
            self.hole2.frame = CGRectMake(20,76,48,48);
            self.hole3.frame = CGRectMake(20,132,48,48);
            self.hole4.frame = CGRectMake(20,188,48,48);
            self.hole5.frame = CGRectMake(20,244,48,48);
            self.hole6.frame = CGRectMake(20,300,48,48);
            self.hole7.frame = CGRectMake(20,356,48,48);
            self.hole8.frame = CGRectMake(20,412,48,48);
            
            self.emptyHole1.frame = CGRectMake(20,20,48,48);
            self.emptyHole2.frame = CGRectMake(20,76,48,48);
            self.emptyHole3.frame = CGRectMake(20,132,48,48);
            self.emptyHole4.frame = CGRectMake(20,188,48,48);
            self.emptyHole5.frame = CGRectMake(20,244,48,48);
            self.emptyHole6.frame = CGRectMake(20,300,48,48);
            self.emptyHole7.frame = CGRectMake(20,356,48,48);
            self.emptyHole8.frame = CGRectMake(20,412,48,48);
            
            self.emptyHoleLabel1.frame = CGRectMake(20,20,48,48);
            self.emptyHoleLabel2.frame = CGRectMake(20,76,48,48);
            self.emptyHoleLabel3.frame = CGRectMake(20,132,48,48);
            self.emptyHoleLabel4.frame = CGRectMake(20,188,48,48);
            self.emptyHoleLabel5.frame = CGRectMake(20,244,48,48);
            self.emptyHoleLabel6.frame = CGRectMake(20,300,48,48);
            self.emptyHoleLabel7.frame = CGRectMake(20,356,48,48);
            self.emptyHoleLabel8.frame = CGRectMake(20,412,48,48);
            
            self.frame1Score.frame = CGRectMake(252,20,48,48);
            self.frame2Score.frame = CGRectMake(252,76,48,48);
            self.frame3Score.frame = CGRectMake(252,132,48,48);
            self.frame4Score.frame = CGRectMake(252,188,48,48);
            self.frame5Score.frame = CGRectMake(252,244,48,48);
            self.frame6Score.frame = CGRectMake(252,300,48,48);
            self.frame7Score.frame = CGRectMake(252,356,48,48);
            self.frame8Score.frame = CGRectMake(252,412,48,48);
        }
        
    }
    
    UIImage *buttonImage = [UIImage imageNamed:@"blackButton.png"];
    UIColor *textColor = [UIColor whiteColor];
    if(self.selectedCoinSet == 9)
    {
        buttonImage = [UIImage imageNamed:@"orangeButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 6)
    {
        buttonImage = [UIImage imageNamed:@"redButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 5)
    {
        buttonImage = [UIImage imageNamed:@"yellowButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 4)
    {
        buttonImage = [UIImage imageNamed:@"purpleButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 7)
    {
        buttonImage = [UIImage imageNamed:@"pinkButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 8)
    {
        buttonImage = [UIImage imageNamed:@"blueButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 3)
    {
        buttonImage = [UIImage imageNamed:@"greenButton.png"];
        textColor = [UIColor whiteColor];
    }
    else if(self.selectedCoinSet == 2)
    {
        buttonImage = [UIImage imageNamed:@"grayButton.png"];
        textColor = [UIColor blackColor];
    }
    else if(self.selectedCoinSet == 1)
    {
        buttonImage = [UIImage imageNamed:@"blackButton.png"];
        textColor = [UIColor whiteColor];
    }
    
    [self.hole1 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole1 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole2 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole2 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole3 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole3 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole4 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole4 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole5 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole5 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole6 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole6 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole7 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole7 setTitleColor:textColor forState:UIControlStateNormal];
    [self.hole8 setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.hole8 setTitleColor:textColor forState:UIControlStateNormal];

    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
