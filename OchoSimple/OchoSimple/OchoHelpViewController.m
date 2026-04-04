//
//  OchoHelpViewController.m
//  OCHO
//
//  Created by Nelson on 6/5/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "OchoHelpViewController.h"

@interface OchoHelpViewController ()
- (IBAction)dismissHelp:(id)sender;

@end

@implementation OchoHelpViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissHelp:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
