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
#import "EditDateVC.h"
#import "E2editCellNote.h"
#import "E2editCellDial.h"
#import "E2editCellTweet.h"


@interface E2editTVC : UITableViewController 
			<UITableViewDelegate, NSFetchedResultsControllerDelegate, 
				EditDateDelegate>

@property (nonatomic, assign) NSInteger	editMode;		//==0:AddNew,  1:Edit,  2:Goal Edit
@property (nonatomic, retain) E2record		*moE2edit;

// <delegate>
//- (void)buttonSave:(BOOL)pop;
- (void)editUpdate;

@end
