//
//  E2listTVC.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "Global.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2listTVC.h"
#import "E2editTVC.h"


@interface E2listTVC ()
- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation E2listTVC
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
//@synthesize ownerCell;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Set up the edit and add buttons.
	//self.navigationItem.leftBarButtonItem = self.editButtonItem;

	//UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
	//self.navigationItem.rightBarButtonItem = addButton;
	//[addButton release];
	
/*	// TableCell表示で使う日付フォーマッタを定義する
	assert(mDateFormatter==nil);
	mDateFormatter = [[NSDateFormatter alloc] init];
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[mDateFormatter setCalendar:calendar];
	[calendar release];
	//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
	[mDateFormatter setDateFormat:@"dd  HH:mm"];
*/
	
	self.managedObjectContext = [MocFunctions getMoc];

	// TableView
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // セル区切り線なし
	//self.tableView.separatorColor = [UIColor blackColor];
	UIImage *imgTile = [UIImage imageNamed:@"Tx-WdWhite320"];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	//[mDateFormatter release], mDateFormatter = nil;
}

- (void)dealloc
{
	[__fetchedResultsController release];
	[__managedObjectContext release];
    [super dealloc];
}


#pragma mark - <UITableViewDelegate>

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{	// セクション ヘッダ
	NSInteger iYearMM = [[[[self.fetchedResultsController sections] objectAtIndex:section] name] integerValue];
	NSInteger iYear = iYearMM / 100;
	
	//NSLog(@"(2) currentLocale NSLocaleLanguageCode : %@",[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
	if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"ja"]) { // 「書式」で変わる。　「言語」でない
		return [NSString stringWithFormat:@"%d年 %d月", iYear, iYearMM - (iYear * 100)]; 
	} else {
		return [NSString stringWithFormat:@"%d / %d", iYearMM - (iYear * 100), iYear]; 
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *Cid = @"E2listCell";  //== Class名
	E2listCell *cell = (E2listCell*)[tableView dequeueReusableCellWithIdentifier:Cid];
	if (cell == nil) {
		UINib *nib = [UINib nibWithNibName:Cid   bundle:nil];
		[nib instantiateWithOwner:self options:nil];
		//cell = self.ownerCell;
		// 選択
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//cell.selectionStyle = UITableViewCellSelectionStyleNone; // 選択時ハイライトなし
	}

	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する

	/* Storyboard導入により、prepareForSegue:が「先に」呼び出される。
	E2editTVC *editVc = [[E2editTVC alloc] init];
	editVc.Re2edit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:editVc animated:YES];
    [editVc release];
	 */
	//[mIndexPathEdit release], mIndexPathEdit = [indexPath copy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: sender=%@", sender);
	if ([[segue identifier] isEqualToString:@"pushE2edit"])
	{
		E2listCell *cell = sender;
		// [segue destinationViewController] is read-only, so in order to
		// write to that view controller you'll have to locally instantiate
		// it here:
		//ViewController *upcomingViewController = [segue destinationViewController];

		E2editTVC *editVc = [segue destinationViewController];
		editVc.Re2edit = cell.Re2node;  //[self.fetchedResultsController objectAtIndexPath:mIndexPathEdit];

		// You now have a solid reference to the upcoming / destination view
		// controller. Example use: Allocate and initialize some property of
		// the destination view controller before you reach it and inject a
		// reference to the current view controller into the upcoming one:
		//upcomingViewController.someProperty = [[SomePropertyClass alloc] initWithString:@"Whatever!"];
		//upcomingViewController.initialViewController = [segue sourceViewController];
		// Or, equivalent, but more straightforward:
		//upcomingViewController.initialViewController = self;
	}
}


						 
- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	//NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [[managedObject valueForKey: E2_dateTime] description];

	E2record *e2 = [self.fetchedResultsController objectAtIndexPath:indexPath];

	cell.Re2node = e2;
	/*
	cell.ibLbDate.text = [mDateFormatter stringFromDate:e2.dateTime];
	cell.ibLbBpHi.text = [self strValue:[e2.nBpHi_mmHg integerValue] dec:0]; 
	cell.ibLbBpLo.text = [self strValue:[e2.nBpLo_mmHg integerValue] dec:0];
	cell.ibLbPuls.text = [self strValue:[e2.nPulse_bpm integerValue] dec:0];
	cell.ibLbWeight.text = [self strValue:[e2.nWeight_g integerValue] dec:1];
	cell.ibLbTemp.text = [self strValue:[e2.nTemp_10c integerValue] dec:1];
	 */
}

- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:E2_dateTime];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{	// データ抽出コントローラを生成する
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// エンティティ指定
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"E2record" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
	//[fetchRequest setFetchBatchSize:20];
	[fetchRequest setFetchLimit:50];
	[fetchRequest setFetchOffset:0];

	// where
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"]]; // 未保存を除外する
    
	// ソート条件指定
    // Edit the sort key as appropriate.
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_nYearMM ascending:YES];		// セクション指定のため
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:YES];	
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sort1, sort2, nil];
    [sort2 release];
    [sort1 release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:E2_nYearMM	// セクション指定のため
																										   cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];

	// データ抽出する
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
        {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

#pragma mark - <Fetched results controller delegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(E2listCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
