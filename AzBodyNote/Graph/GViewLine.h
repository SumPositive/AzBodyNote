//
//  GViewLine.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>

#import "Global.h"

//#define VA_GOAL		0
//#define VA_AVE			1
//#define VA_REC			2
#define GRAPH_DAYS_SAFE		20  //安全帯


@interface GViewLine : UIView
{
@private
	CGFloat					mPadScale;	//= iPad / iPhone
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) NSInteger	ppPage;

@property (nonatomic, assign) CGFloat		ppRecordWidth;
@property (nonatomic, retain) UIFont			*ppFont;

@property (nonatomic, retain) NSString		*ppEntityKey;
@property (nonatomic, retain) NSString		*ppGoalKey;
@property (nonatomic, assign) NSInteger	ppDec;
@property (nonatomic, assign) NSInteger	ppMin;
@property (nonatomic, assign) NSInteger	ppMax;
@property (nonatomic, assign) NSInteger	ppBMI_Tall;	//BMI 身長(cm)

@end
