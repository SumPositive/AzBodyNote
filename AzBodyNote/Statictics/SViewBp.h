//
//  SViewBp.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Global.h"
#import "MocEntity.h"

#define STAT_DAYS_SAFE		20  //安全帯

enum {
	bpHi		= 0,
	bpLo	= 1,
	bpEnd	= 2 //End count
};
typedef NSInteger bpType;

enum {
	statDispersalHiLo		= 0,
	statDispersal24Hour	= 1,
	statTypeEnd				= 2 //End count
};
typedef NSInteger statType;


@interface SViewBp : UIView
{
@private
	CGFloat					mPadScale;	//= iPad / iPhone
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) statType		ppStatType;
@property (nonatomic, assign) NSInteger	ppDays;

@end
