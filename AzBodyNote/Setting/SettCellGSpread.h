//
//  SettCellGoogleLogin.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

//#define TAG_SettCellLogin_Google		1

@interface SettCellGoogleLogin : UITableViewCell <UITextFieldDelegate>
{
	IBOutlet UILabel				*ibLbTitle;
	IBOutlet UILabel				*ibLbDetail;
	IBOutlet UITextField		*ibTfId;
	IBOutlet UITextField		*ibTfPw;
@private
}

//@property (nonatomic, retain) IBOutlet UILabel		*ibLbTitle;
//@property (nonatomic, retain) IBOutlet UILabel		*ibLbDetail;
//@property (nonatomic, retain) IBOutlet UITextField	*ibTfId;
//@property (nonatomic, retain) IBOutlet UITextField	*ibTfPw;

@end
