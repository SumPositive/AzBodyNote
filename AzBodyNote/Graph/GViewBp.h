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
#define IMAGE_GAP_MIN			30.0		// Hi-Lo差がこれ以下になると、Optアイコン非表示にして接触回避する
#define VALUE_GAP_MIN			70.0		// Hi-Lo差がこれ以下になると、数値を45度傾けて接触回避する

#define Graph_BMI_Tall_MIN			50	//これ未満ならば非表示
#define Graph_BMI_Tall_MAX		250

enum {
	bpHi			= 0,
	bpLo		= 1,
	bpPress	= 2,		// 脈圧	Puls pressure = Hi - Lo
	bpMean	= 3,		// 平均血圧　　Mean blood pressure = (Hi + Lo + Lo)/3
	bpEnd		= 4		//End count
};
typedef NSInteger bpType;


@interface GViewBp : UIView
{
@private
	CGFloat					mPadScale;	//= iPad / iPhone
	BOOL						mBpMean;
	BOOL						mBpPress;
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) NSInteger	ppPage;

@property (nonatomic, assign) CGFloat		ppRecordWidth;
@property (nonatomic, retain) UIFont			*ppFont;

@end
