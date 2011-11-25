//
//  E2listTVC.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2listTVC.h"
#import "E2editTVC.h"


@interface E2listTVC ()
- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation E2listTVC
{
	AzBodyNoteAppDelegate		*appDelegate_;
	NSManagedObjectContext		*moc_;
	NSIndexPath							*indexPathEdit_;
	//BOOL										bEditReturn_;

#ifdef GD_Ad_ENABLED
	GADBannerView		*adMobView_;
#endif
}
@synthesize fetchedResultsController = frc_;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	appDelegate_ = [[UIApplication sharedApplication] delegate];
	moc_ = [appDelegate_ managedObjectContext];
	NSLog(@"E2listTVC: moc_=%@", moc_);
	assert(moc_);
	//bEditReturn_ = NO;

	//self.tableView.delegate = self;
	
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:@"RefreshAllViews" 
											   object:[[UIApplication sharedApplication] delegate]];

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
	
	//self.managedObjectContext = [MocFunctions getMoc];

	// TableView
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone; // セル区切り線なし
	//self.tableView.separatorColor = [UIColor blackColor];
	UIImage *imgTile = [UIImage imageNamed:@"Tx-WdWhite320"];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:imgTile];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
/*	// データ抽出する
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
	{
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}*/
	
	if (indexPathEdit_ && frc_) {
		NSLog(@"viewWillAppear: indexPathEdit_=%@", indexPathEdit_);
		NSArray *aPaths = [NSArray arrayWithObject:indexPathEdit_];
		[self.tableView reloadRowsAtIndexPaths:aPaths withRowAnimation:UITableViewRowAnimationFade];
	}
	
	if (indexPathEdit_) {
		indexPathEdit_ = nil; // Editモード解除
	} else { 
		// 最終行を表示する
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[[self.fetchedResultsController sections] count]] 
							  atScrollPosition:UITableViewScrollPositionMiddle animated:NO];  // 実機検証結果:NO
		self.view.alpha = 0;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (self.view.alpha != 1) {
		[super viewDidAppear:animated];
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDuration:TABBAR_CHANGE_TIME];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		// アニメ終了状態
		self.view.alpha = 1;
		// アニメ実行
		[UIView commitAnimations];
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}
*/

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
	//[mDateFormatter release], mDateFormatter = nil;
}

/*
- (void)dealloc
{
	[__fetchedResultsController release];
	[__managedObjectContext release];
    [super dealloc];
}
*/


#pragma mark - iCloud
- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
    if (note) {
		[self viewWillAppear:YES];
    }
}


#pragma mark - <UITableViewDelegate>

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section < [[self.fetchedResultsController sections] count]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	}
	return 1; // END LINE - AdMob
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{	// セクション ヘッダ
	if (section < [[self.fetchedResultsController sections] count]) {
		NSInteger iYearMM = [[[[self.fetchedResultsController sections] objectAtIndex:section] name] integerValue];
		NSInteger iYear = iYearMM / 100;
		
		//NSLog(@"(2) currentLocale NSLocaleLanguageCode : %@",[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
		if ([[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] isEqualToString:@"ja"]) { // 「書式」で変わる。　「言語」でない
			return [NSString stringWithFormat:@"%d年 %d月", iYear, iYearMM - (iYear * 100)]; 
		} else {
			return [NSString stringWithFormat:@"%d / %d", iYearMM - (iYear * 100), iYear]; 
		}
	}
	return @"Latest";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section < [[self.fetchedResultsController sections] count]) {
		return 44; // Default
	}
    return 50; // END LINE - AdMob
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section < [[self.fetchedResultsController sections] count]) 
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
	else {
		static NSString *CidEnd = @"E2listEnd";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CidEnd];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CidEnd];
			cell.accessoryType = UITableViewCellAccessoryNone;
			//cell.textLabel.textAlignment = UITextAlignmentCenter;
			//cell.textLabel.textColor = [UIColor grayColor];
			cell.textLabel.text = @"";
#ifdef GD_Ad_ENABLED
			//--------------------------------------------------------------------------------------------------------- AdMob
			if (adMobView_==nil) {
				adMobView_ = [[GADBannerView alloc]
							   initWithFrame:CGRectMake(0, 0,			// TableCell用
														GAD_SIZE_320x50.width,
														GAD_SIZE_320x50.height)];
				adMobView_.delegate = nil;  //もし self セットするならば、Unload時に解放処理しなければ落ちる。
				adMobView_.rootViewController = self;
				adMobView_.adUnitID = AdMobID_BodyNote;
				GADRequest *request = [GADRequest request];
				[adMobView_ loadRequest:request];
			}
			[cell.contentView addSubview:adMobView_];
#endif
		}
		return cell;
	}
    return nil;
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
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [moc_ deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![moc_ save:&error])
        {
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
	//[indexPathEdit_ release]
	indexPathEdit_ = [indexPath copy];	// 戻ったときにセルを再描画するため

	/* Storyboard導入により、prepareForSegue:が「先に」呼び出される。
	E2editTVC *editVc = [[E2editTVC alloc] init];
	editVc.Re2edit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:editVc animated:YES];
    [editVc release];
	 */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: sender=%@", sender);
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: [segue identifier]=%@", [segue identifier]);
	NSLog(@"prepareForSegue: [segue sourceViewController]=%@", [segue sourceViewController]);
	NSLog(@"prepareForSegue: [segue destinationViewController]=%@", [segue destinationViewController]);

	if ([[segue identifier] isEqualToString:@"pushE2edit"])
	{
		// Assume self.view is the table view
		NSIndexPath *path = [self.tableView indexPathForSelectedRow];//選択中のセル位置
		NSLog(@"prepareForSegue: path=%@", path);
		E2record *e2 = [self.fetchedResultsController objectAtIndexPath:path];
		NSLog(@"prepareForSegue: e2=%@", e2);

		E2editTVC *editVc = [segue destinationViewController];
		editVc.moE2edit = e2;  //[self.fetchedResultsController objectAtIndexPath:mIndexPathEdit];
		//bEditReturn_ = YES;
	}
}

						 
- (void)configureCell:(E2listCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"configureCell: indexPath=%@", indexPath);
	E2record *e2 = [self.fetchedResultsController objectAtIndexPath:indexPath];
	//NSLog(@"configureCell: indexPath=%@  moE2node=%@", indexPath, e2);
	cell.moE2node = e2;
	[cell draw]; // moE2node を描画する
}

/*
- (void)insertNewObject
{
    // Create a new instance of the entity managed by the fetched results controller.
    //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:moc_];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:E2_dateTime];
    
    // Save the context.
    NSError *error = nil;
    if (![moc_ save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}*/


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{	// データ抽出コントローラを生成する
    if (frc_)
    {
        return frc_;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// エンティティ指定
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"E2record" inManagedObjectContext:moc_];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
	//[fetchRequest setFetchBatchSize:20];
	//[fetchRequest setFetchLimit:50];
	//[fetchRequest setFetchOffset:0];

	// where
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"]]; // 未保存を除外する
    
	// ソート条件指定
    // Edit the sort key as appropriate.
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_nYearMM ascending:YES];		// セクション指定のため
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:YES];	
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects: sort1, sort2, nil];
    //[sort2 release];
    //[sort1 release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[sortDescriptors release];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFrc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																								managedObjectContext:moc_ 
																								  sectionNameKeyPath:E2_nYearMM	// セクション指定のため
																										   cacheName:@"E2listDate"];
    aFrc.delegate = self;

	// データ抽出する
	NSError *error = nil;
	if (![aFrc performFetch:&error])
	{
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    self.fetchedResultsController = aFrc; //retain
    //[aFrc release];
    //[fetchRequest release];
    return aFrc;
}    


#pragma mark - <NSFetchedResultsControllerDelegate>

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
            
		/*非表示状態なので不要。 表示されたときに、viewWillAppear:にて描画処理されるため
		case NSFetchedResultsChangeUpdate:
            [self configureCell:(E2listCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;*/
            
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
