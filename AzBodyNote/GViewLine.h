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


@interface GViewLine : UIView

@property (nonatomic, retain) NSArray		*ppE2records;
@property (nonatomic, retain) NSString		*ppEntityKey;
@property (nonatomic, retain) NSString		*ppGoalKey;
@property (nonatomic, assign) NSInteger	ppDec;
@property (nonatomic, assign) NSInteger	ppMin;
@property (nonatomic, assign) NSInteger	ppMax;

@end
