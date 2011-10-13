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
//#import "AzBodyNoteAppDelegate.h"

@class E2editCellValue;

@interface E2editTVC : UITableViewController <ADBannerViewDelegate>
{
	//IBOutlet UITableView				*ibTvMain;  = self.tableView を使用。
	IBOutlet ADBannerView			*ibADBanner;
	
	E2record		*Re2edit;		// =nil:AddNew
	
@private
	//AzBodyNoteAppDelegate	*appDelegate;
	BOOL					mIsAddNew;
	float						mADBannerY;	//iAd表示位置のY座標
}

@property (nonatomic, retain) E2record		*Re2edit;
@property (nonatomic, assign) IBOutlet E2editCellValue *ownerE2editTVC;  // E2editCellValue と E2editTVC をFile's Ownerリンクするため

//- (IBAction)actionCellValueTouch:(UIButton *)button;
//- (IBAction)actionCellSliderChange:(UISlider *)slider;

// <delegate>
- (void)editUpdate;


@end
