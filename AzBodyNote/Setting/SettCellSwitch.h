//
//  SettCellSwitch.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_SettCellSwitch_Tweet		1
#define TAG_SettCellSwitch_Test		2


@interface SettCellSwitch : UITableViewCell
{
	//IBOutlet UISwitch *ibSwitch;
@private
}

@property (nonatomic, retain) IBOutlet UISwitch *ibSwitch;

- (IBAction)ibSwitchChange:(UISwitch *)sw;

@end
