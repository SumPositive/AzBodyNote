//
//  GViewBp.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>

#import "Global.h"

#define GRAPH_DAYS_SAFE		20  //安全帯

enum {
	bpHi		= 0,
	bpLo	= 1,
	bpEnd	= 2 //End count
};
typedef NSInteger bpType;

enum {
	optWake		= 0,		// Wake up
	optRest		= 1,		// at Rest
	optDown		= 2,		// Slowdown
    optSleep		= 3,		// for Sleep
	optEnd			= 4 //End count
};
typedef NSInteger optType;


@interface GViewBp : UIView
{
@private
	NSUInteger								mGraphDays;
	NSDecimalNumberHandler		*mBehaviorDec0; //小数以下0桁＝整数
	NSDecimalNumberHandler		*mBehaviorDec1; //小数以下1桁
}

@property (nonatomic, retain) NSArray		*ppE2records;

@end
