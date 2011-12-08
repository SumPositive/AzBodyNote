//
//  E2editCellNote.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "E2editTVC.h"
#import "E2editCellNote.h"

@implementation E2editCellNote
{
	__unsafe_unretained id						delegate;
	__strong E2record			*Re2record;
	
	IBOutlet UITextField		*ibTfNote1;
	IBOutlet UITextField		*ibTfNote2;
}
@synthesize delegate;
@synthesize Re2record;
//@synthesize ibTfNote1, ibTfNote2;



- (void)drawRect:(CGRect)rect
{
	assert(Re2record);
	//assert(RzKey);
	ibTfNote1.delegate = self;
	ibTfNote1.text = Re2record.sNote1;
	ibTfNote1.placeholder = NSLocalizedString(@"PH_Note1",nil); //@"Condition, memo";
	
	ibTfNote2.delegate = self;
	ibTfNote2.text = Re2record.sNote2;
	ibTfNote2.placeholder = NSLocalizedString(@"PH_Note2",nil); //@"Medicine,  memo";
}


#pragma mark - <UITextFieldDelegate>

/*** [Done]を押さずに[Save]が押されたとき、textFieldDidEndEditing:を通らないため、文字入力の都度更新するようにした。
- (void)textFieldDidEndEditing:(UITextField *)textField            
{	// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
	if (textField==ibTfNote1 && ![Re2record.sNote1 isEqualToString:textField.text]) {
		Re2record.sNote1 = textField.text;
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];  // 変更あり
		}
	}
	else if (textField==ibTfNote2 && ![Re2record.sNote2 isEqualToString:textField.text]) {
		Re2record.sNote2 = textField.text;
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];  // 変更あり
		}
	}
}*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   
{	// return NO to not change text     テキストが変更される「直前」に呼び出される。これにより入力文字数制限を行っている。
    NSMutableString *text = [textField.text mutableCopy];// autorelease];
    [text replaceCharactersInRange:range withString:string];
	// 置き換えた後の長さをチェックする
	if (100 < [text length]) return NO; // OVER
	
	// [Done]を押さずに[Save]が押されたとき、textFieldDidEndEditing:を通らないため、文字入力の都度更新するようにした。
	// この時点で、textField.text は更新されていない。
	if (textField==ibTfNote1 && ![Re2record.sNote1 isEqualToString:text]) {
		Re2record.sNote1 = text;  //textField.text;
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];  // 変更あり
		}
	}
	else if (textField==ibTfNote2 && ![Re2record.sNote2 isEqualToString:text]) {
		Re2record.sNote2 = text;  //textField.text;
		if ([delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate editUpdate];  // 変更あり
		}
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	// called when 'return' key pressed. return NO to ignore.
	[textField resignFirstResponder];
	return YES;
}

@end
