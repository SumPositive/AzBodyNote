//
//  SettCellGoogleLogin.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettCellGoogleLogin.h"
#import "SFHFKeychainUtils.h"

@implementation SettCellGoogleLogin
//@synthesize ibLbTitle, ibLbDetail, ibTfId, ibTfPw;


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
	ibLbTitle.text = NSLocalizedString(@"SettGoogle",nil);
	ibLbDetail.text = NSLocalizedString(@"SettGoogle detail",nil);
	ibTfId.delegate = self;		//<UITextFieldDelegate>
	ibTfPw.delegate = self;	//<UITextFieldDelegate>
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define GKC_ServiceName		@"AzCondition"
#define GKC_UserName				@"GoogleLoginName"

#pragma make - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)sender 
{	// キーボードのリターンキーを押したときに呼ばれる
	if (sender==ibTfId) {	//-------------------------------------------------------------Google+ ID
		if ([sender.text length] <= 0 OR 80 < [sender.text length]) {
			// GoogleServiceログイン状態をクリアする
			//[GoogleService docServiceClear];
			//[GoogleService photoServiceClear];
			// IDを破棄する
			NSError *error; // nilを渡すと異常終了するので注意
			[SFHFKeychainUtils deleteItemForUsername:GKC_UserName
									  andServiceName:GKC_ServiceName error:&error];
			sender.text = @"";
			[sender resignFirstResponder];
			ibTfPw.text = @"";
			//[self.tableView reloadData];  // cell表示更新のため
			alertBox(NSLocalizedString(@"Google ID delete",nil), nil, @"OK");
			return YES;
		}
		// ID KeyChainに保存する
		NSError *error; // nilを渡すと異常終了するので注意
		[SFHFKeychainUtils storeUsername:GKC_UserName
							 andPassword: sender.text
						  forServiceName:GKC_ServiceName 
						  updateExisting:YES error:&error];
		ibTfPw.text = @"";
		//ibTfPw.hidden = NO;
		[ibTfPw becomeFirstResponder];
	}
	else if (sender==ibTfPw) {	//-------------------------------------------------------------Google+ PW
		[sender resignFirstResponder];	//iPad//disablesAutomaticKeyboardDismissalカテゴリ定義が必要＞Global定義
		//sender.hidden = YES;
		if ([sender.text length] <= 0 OR 80 < [sender.text length]) {
			// PWを破棄する
			NSError *error; // nilを渡すと異常終了するので注意
			[SFHFKeychainUtils deleteItemForUsername:GKC_UserName
									  andServiceName:GKC_ServiceName error:&error];
			sender.text = @"";
			//[self.tableView reloadData];  // cell表示更新のため
			alertBox(NSLocalizedString(@"Google PW delete",nil), nil, @"OK");
			return YES;
		}
		if (0 < [ibTfId.text length] && 0 < [sender.text length]) {
			//[GoogleService loginID: ibTfId.text  withPW: sender.text  isSetting:YES];
		}
	}
    return YES;
}

@end
