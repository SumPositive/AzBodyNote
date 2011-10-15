//
//  E2editTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "MocEntity.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"


@interface E2editTVC : UITableViewController <ADBannerViewDelegate>
{
	E2record		*Re2edit;		// =nil:AddNew
	
@private
	E2record		*Re2prev;	// 直前のレコード
	BOOL			mIsAddNew;
	ADBannerView	*mADBanner;
	float						mADBannerY;	//iAd表示位置のY座標
}

@property (nonatomic, retain) E2record		*Re2edit;
@property (nonatomic, assign) IBOutlet E2editCellDial *ownerCellDial;  // E2editCellDial と E2editTVC をFile's Ownerリンクするため
@property (nonatomic, assign) IBOutlet E2editCellNote *ownerCellNote;  // E2editCellNote と E2editTVC をFile's Ownerリンクするため

// <delegate>
- (void)editUpdate;

@end
