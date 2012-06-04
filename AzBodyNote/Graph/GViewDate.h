//
//  GViewDate.h
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Global.h"


@interface GViewDate : UIView
{
@private
	CGFloat					mPadScale;	//= iPad / iPhone
}

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, assign) NSInteger	ppPage;

@property (nonatomic, assign) CGFloat		ppRecordWidth;
//@property (nonatomic, retain) UIFont			*ppFont;

@end
