//
//  EditDateVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"


@interface EditDateVC : UIViewController
{
@private
	E2record			*Re2node;
	id						delegate;	
	NSTimeInterval	MintervalPrev;
}

@property (nonatomic, retain) E2record			*Re2record;
@property (nonatomic, assign) id						delegate;
@property (nonatomic, assign) NSInteger	PiMinYearMMDD;
@property (nonatomic, assign) NSInteger	PiMaxYearMMDD;

@end
