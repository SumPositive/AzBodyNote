//
//  E2editTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <iAd/iAd.h>
#import <Twitter/TWTweetComposeViewController.h>
//#import <DropboxSDK/JSON.h>

#import "AppDelegate.h"
#import "EditDateVC.h"
#import "E2editCellDateOpt.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"
#import "CalcView.h"

#define PANEL_TOP_ROW		2


@interface E2editTVC : UITableViewController 
			<UITableViewDelegate, NSFetchedResultsControllerDelegate, 
				EditDateDelegate>
{
@private
	AppDelegate			*appDelegate_;
	MocFunctions			*mocFunc_;
	
	//BOOL			bAddNew_;  >>>>>>>>>  editMode_==0
	BOOL			bEditDate_;
	//float				fADBannerY_;	//iAd表示位置のY座標
	
	NSInteger	iPrevBpHi_;
	NSInteger	iPrevBpLo_;
	NSInteger	iPrevPuls_;
	NSInteger	iPrevWeight_;
	NSInteger	iPrevTemp_;
	NSInteger	iPrevPedometer_;
	NSInteger	iPrevBodyFat_;
	NSInteger	iPrevSkMuscle_;
	UIButton		*buDelete_;		// Edit時のみ使用
	NSUbiquitousKeyValueStore *kvsGoal_;
	
	EKCalendar	*mEKCalendar;
	NSArray		*mPanels;
	TWTweetComposeViewController		*mTweetVC;
}

@property (nonatomic, assign) NSInteger	editMode;		//==0:AddNew,  1:Edit,  2:Goal Edit
@property (nonatomic, strong) E2record		*moE2edit;

// <delegate>
- (void)delegateEditChange;
- (void)delegateDateOptChange;

@end
