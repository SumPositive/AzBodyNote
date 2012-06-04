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
#define IMAGE_GAP_MIN			70.0

enum {
	bpHi		= 0,
	bpLo	= 1,
	bpEnd	= 2 //End count
};
typedef NSInteger bpType;


@interface GViewBp : UIView
{
@private
	CGFloat					mPadScale;	//= iPad / iPhone
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) NSInteger	ppPage;

@property (nonatomic, assign) CGFloat		ppRecordWidth;
@property (nonatomic, retain) UIFont			*ppFont;

@end
