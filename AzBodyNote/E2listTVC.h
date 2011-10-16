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

@interface E2listTVC : UITableViewController <NSFetchedResultsControllerDelegate>
{
	
@private
	//NSDateFormatter		*mDateFormatter;			// TableCell高速化のため
	NSIndexPath				*mIndexPathEdit;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, assign) IBOutlet E2listCell *ownerCell;  // E2listCell と E2listTVC をFile's Ownerリンクするため

@end
