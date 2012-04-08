//
//  SettCellSwitch.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettCellSwitch.h"
#import "Global.h"

@implementation SettCellSwitch
@synthesize ibSwitch;


/***通らない
 - (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
 {
 self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 if (self) {
 // Initialization code
 }
 return self;
 }*/

- (void)drawRect:(CGRect)rect
{	// ここは初期化時に1度だけ通る

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ibSwitchChange:(UISwitch *)sw
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	switch (sw.tag) {
		case TAG_SettCellSwitch_Tweet:
			[userDefaults setBool:[sw isOn] forKey:GUD_bTweet];
			[userDefaults synchronize];
			break;

		case TAG_SettCellSwitch_Test:
			NSLog(@"TAG_SettCellSwitch_Test");
			break;
	}
}

@end
