//
//  E2editCellNote.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//
#import "E2editCellNote.h"


@implementation E2editCellNote
@synthesize delegate = delegate_;
@synthesize Re2record = e2record_;


- (void)drawRect:(CGRect)rect
{
	if (e2record_==nil) return;
	assert(e2record_);

	ibTfNote1.delegate = self;
	ibTfNote1.text = e2record_.sNote1;
	ibTfNote1.placeholder = NSLocalizedString(@"PH_Note1",nil); //@"Condition, memo";
	
	ibTfNote2.delegate = self;
	ibTfNote2.text = e2record_.sNote2;
	ibTfNote2.placeholder = NSLocalizedString(@"PH_Note2",nil); //@"Medicine,  memo";
}


#pragma mark - <UITextFieldDelegate>

/*** [Done]を押さずに[Save]が押されたとき、textFieldDidEndEditing:を通らないため、文字入力の都度更新するようにした。
- (void)textFieldDidEndEditing:(UITextField *)textField            
{	// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
	if (textField==ibTfNote1 && ![e2record_.sNote1 isEqualToString:textField.text]) {
		e2record_.sNote1 = textField.text;
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];  // 変更あり
		}
	}
	else if (textField==ibTfNote2 && ![e2record_.sNote2 isEqualToString:textField.text]) {
		e2record_.sNote2 = textField.text;
		if ([delegate_ respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
			[delegate_ editUpdate];  // 変更あり
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
	if (textField==ibTfNote1 && ![e2record_.sNote1 isEqualToString:text]) {
		e2record_.sNote1 = text;  //textField.text;
		if ([delegate_ respondsToSelector:@selector(delegateEditChange)]) { // E2editTVC:<delegate>
			[delegate_ delegateEditChange];  // 変更あり
		}
	}
	else if (textField==ibTfNote2 && ![e2record_.sNote2 isEqualToString:text]) {
		e2record_.sNote2 = text;  //textField.text;
		if ([delegate_ respondsToSelector:@selector(delegateEditChange)]) { // E2editTVC:<delegate>
			[delegate_ delegateEditChange];  // 変更あり
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
