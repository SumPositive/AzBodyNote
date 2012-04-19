//
//  E2editCellTweet.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//
#import "E2editCellTweet.h"

@implementation E2editCellTweet

//- (void)switchTweet:(UISwitch *)sw
- (IBAction)ibSwTweetChange:(id)sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:[sender isOn] forKey:GUD_bTweet];
	[userDefaults synchronize];
}

- (void)drawRect:(CGRect)rect
{
	ibLbTweet.text = NSLocalizedString(@"Tweet switch",nil);
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	ibSwTweet.selected = [userDefaults boolForKey:GUD_bTweet];
}

@end
