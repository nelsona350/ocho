#import "GameKitHelper.h"
//#import "GameConstants.h"

@interface GameKitHelper ()
<GKGameCenterControllerDelegate>
{
    BOOL gameCenterFeaturesEnabled;
}
@end

@implementation GameKitHelper

#pragma mark Singleton stuff

+(id) sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper =
        [[GameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
    
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:(^(UIViewController* viewController, NSError *error)
        {
            
            
            if([GKLocalPlayer localPlayer].authenticated)
            {
                //do some stuff
                gameCenterFeaturesEnabled = YES;
                
            }
            else if(viewController)
            {
                [self presentViewController:viewController];
            }
            else
            {
                
                // not logged in
                
            }
            
            
        })];
        
    }
    else
    {
        NSLog(@"Already authenticated!");
    }
}

#pragma mark Property setters

-(void) setLastError:(NSError*)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo]
                                           description]);
    }
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController
{
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc
{
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
}

-(BOOL) submitScore:(int64_t)score category:(NSString*)category
{
    //1: Check if Game Center
    //   features are enabled
    if (!gameCenterFeaturesEnabled)
    {
        return NO;
    }
    
    //2: Create a GKScore object
    GKScore* gkScore =
    [[GKScore alloc]
     initWithCategory:category];
    
    //3: Set the score value
    gkScore.value = score;
    
    //4: Send the score to Game Center
    BOOL success = NO;
    [gkScore reportScoreWithCompletionHandler:
     ^(NSError* error)
     {
         
         [self setLastError:error];
                  
         if ([_delegate respondsToSelector:
              @selector(onScoresSubmitted:)])
         {
             
             [_delegate onScoresSubmitted:success];
         }
     }];
    
    return success;
}


@end
