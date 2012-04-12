//
//  SettCellGSpread.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"


@interface SettCellGSpread : UITableViewCell <UITextFieldDelegate>
{
	IBOutlet UILabel				*ibLbTitle;
	IBOutlet UILabel				*ibLbDetail;
	IBOutlet UITextField		*ibTfId;
	IBOutlet UITextField		*ibTfPw;
@private
}

@end
