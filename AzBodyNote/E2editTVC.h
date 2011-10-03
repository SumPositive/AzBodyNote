//
//  E2editTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"

@class E2editCellValue;

@interface E2editTVC : UITableViewController
{
	IBOutlet UITableView				*ibTvMain;
	
	E2record		*Re2edit;		// =nil:AddNew
	
@private
	BOOL	mIsAddNew;
}

@property (nonatomic, retain) E2record		*Re2edit;
@property (nonatomic, assign) IBOutlet E2editCellValue *ownerE2editTVC;  // E2editCellValue と E2editTVC をFile's Ownerリンクするため

//- (IBAction)actionCellValueTouch:(UIButton *)button;
//- (IBAction)actionCellSliderChange:(UISlider *)slider;

@end
