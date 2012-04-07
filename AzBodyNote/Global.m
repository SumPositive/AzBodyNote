//
//  Global.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "Global.h"


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



