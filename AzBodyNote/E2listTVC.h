//
//  E2listTVC.h
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "E2listCell.h"

#ifdef GD_Ad_ENABLED
#import "GADBannerView.h"
#endif

@interface E2listTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
#ifdef GD_Ad_ENABLED
	, GADBannerViewDelegate
#endif
>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
