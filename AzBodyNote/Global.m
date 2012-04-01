//
//  Global.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "Global.h"



void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton )
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:zTitle
													message:zMsg
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:zButton, nil];
	[alert show];
}

// nil --> [NSNull null]   コンテナ保存オブジェクトにnilが含まれる可能性があるときに使用
id toNSNull( id obj )
{
	if (obj) return obj;
	return [NSNull null];
}

// [NSNull null] --> nil
id toNil( id obj )
{
	if (obj) {
		if (obj==[NSNull null]) {
			return nil;
		}
		return obj;
	}
	return nil;
}

NSString *strValue( NSInteger val,  NSInteger dec )
{
	if (val <= 0) return @"";
	if (dec<=0) {
		return [NSString stringWithFormat:@"%ld", (long)val];
	} else {
		NSInteger iPow = (NSInteger)pow(10, dec); //= 10 ^ mValueDec;
		NSInteger iInt = val / iPow;
		NSInteger iDec = val - iInt * iPow;
		if (iDec<=0) {
			switch (dec) {
				case 1: return [NSString stringWithFormat:@"%ld.0", (long)iInt]; break;
				case 2: return [NSString stringWithFormat:@"%ld.00", (long)iInt]; break;
				default:return [NSString stringWithFormat:@"%ld", (long)iInt]; break;
			}
		} else {
			return [NSString stringWithFormat:@"%ld.%ld", (long)iInt, (long)iDec];
		}
	}
}



