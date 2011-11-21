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


@interface E2editTVC : UITableViewController <NSFetchedResultsControllerDelegate> //<ADBannerViewDelegate>

@property (nonatomic, retain) E2record		*moE2edit;		//==nil:AddNew,  !=nil:Edit
//@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// <delegate>
- (void)editUpdate;

@end
