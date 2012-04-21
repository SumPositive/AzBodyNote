//
//  E2editCellDateOpt.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "E2editTVC.h"		// editUpdate 更新通知のため


@interface E2editCellDateOpt : UITableViewCell
{
	IBOutlet UISegmentedControl		*ibSegment;
	
@private
	NSArray							*mTitles;
}

@property (nonatomic, unsafe_unretained) id		delegate;		// editUpdate 更新通知のため
@property (nonatomic, retain) E2record				*ppE2record;		// 結果を戻すため

@end
