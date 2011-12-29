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
#import "GADBannerView.h"


@interface E2listTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
	, GADBannerViewDelegate>
{
	IBOutlet UILabel				*ibLbDate;
	IBOutlet UILabel				*ibLbTime;
	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	//IBOutlet UILabel				*ibLbWeight;
	//IBOutlet UILabel				*ibLbTemp;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
