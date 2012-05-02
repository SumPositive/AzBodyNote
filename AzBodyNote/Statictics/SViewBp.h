//
//  SViewBp.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"
#import "MocEntity.h"

#define STAT_DAYS_SAFE		20  //安全帯

enum {
	bpHi		= 0,
	bpLo	= 1,
	bpEnd	= 2 //End count
};
typedef NSInteger bpType;


@interface SViewBp : UIView
{
@private
	NSUInteger								mStatDays;
	NSDecimalNumberHandler		*mBehaviorDec0; //小数以下0桁＝整数
	NSDecimalNumberHandler		*mBehaviorDec1; //小数以下1桁
	CGContextRef					canvasContext;
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) NSInteger	ppSelectedSegmentIndex;

@end
