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

//#define VA_GOAL		0
//#define VA_AVG			1
//#define VA_REC			2
#define GRAPH_DAYS_SAFE		20  //安全帯


@interface GViewBp : UIView
{
@private
	NSUInteger								mGraphDays;
	NSDecimalNumberHandler		*mBehaviorDec0; //小数以下0桁＝整数
	NSDecimalNumberHandler		*mBehaviorDec1; //小数以下1桁
}

@property (nonatomic, retain) NSArray		*ppE2records;

@end
