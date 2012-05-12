//
//  E2listTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreData/CoreData.h>

#import "AppDelegate.h"
#import "E2listCell.h"
#import "E2editTVC.h"
#import "AZDropboxVC.h"	//<AZDropboxDelegate>



@interface E2listTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, AZDropboxDelegate>
{
	IBOutlet UILabel				*ibLbDate;
	IBOutlet UILabel				*ibLbTime;
	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	IBOutlet UILabel				*ibLbWeight;
	IBOutlet UILabel				*ibLbTemp;
	//IBOutlet UILabel				*ibLbNote1;
	IBOutlet UILabel				*ibLbPedo;
	IBOutlet UILabel				*ibLbBodyFat;
	IBOutlet UILabel				*ibLbSkMuscle;
	
@private
	AppDelegate					*appDelegate_;
	MocFunctions					*mocFunc_;
	NSIndexPath					*indexPathEdit_;
	NSIndexPath					*indexPathDelete_;
	
	//GADBannerView		*adMobView_;
	//NSUInteger						e2offset_;
	UILabel							*lbPagePrev_;
	//UILabel							*lbPageNext_;
	//BOOL								mbGoal;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
