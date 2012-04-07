//
//  SettCellLogin.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_SettCellLogin_Google		1

@interface SettCellLogin : UITableViewCell
{
@private
	IBOutlet UITextField		*ibTfId;
	IBOutlet UITextField		*ibTfPw;
}

@end
