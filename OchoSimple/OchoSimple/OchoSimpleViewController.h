//
//  OchoSimpleViewController.h
//  OchoSimple
//
//  Created by Nelson on 4/27/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "OptionsViewController.h"
#import "GameOverViewController.h"

@interface OchoSimpleViewController : UIViewController <OptionsViewControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    SystemSoundID buzzerSound,woohooSound,chachingSound,tone1Sound,tone2Sound,tone3Sound,tone4Sound,tone5Sound,tone6Sound,tone7Sound,tone8Sound,silence;
    NSURL *tone1URL,*tone2URL,*tone3URL,*tone4URL,*tone5URL,*tone6URL,*tone7URL,*tone8URL;
}

@property(nonatomic, assign) BOOL goodInitialToss,readyToToss,flipDisplayEnabled,unlimitedRoundsEnabled,isWidescreen,globalFromTossCoins,passed88,soundEnabled,tonePlaying,firstMatchFound;
@property(nonatomic, assign) int frameNumber,frameScore,totalScore,numberOfMatches,numberOfCoinsRemaining,roundNumber,roundScore,pointsToGo,currentHole,bestRound,closestCall,roundLimit,bestRoundNumber,numScreenshots,selectedCoinSet;
@property(nonatomic, assign) double delayInSeconds,toneDelay;
@property(nonatomic, retain) NSMutableArray *coin,*hole,*matchedCoin,*coinScores,*frameScores,*roundScores,*holeOld,*unlockedCoinSets;
@property(nonatomic, retain) NSString *enabledFeaturesPath,*playerName;
@property(nonatomic, retain) id globalSender;

@end
