//
//  E2editTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <iAd/iAd.h>
#import "MocEntity.h"
#import "E2editCellDial.h"
#import "E2editCellNote.h"

#ifdef GD_Ad_ENABLED
#import <iAd/iAd.h>
#import "GADBannerView.h"
#endif


@interface E2editTVC : UITableViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate
#ifdef GD_Ad_ENABLED
	,ADBannerViewDelegate, GADBannerViewDelegate
#endif
>

@property (nonatomic, retain) E2record		*moE2edit;		//==nil:AddNew,  !=nil:Edit

// <delegate>
- (void)editUpdate;

@end
