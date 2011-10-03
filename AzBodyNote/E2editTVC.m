//
//  E2editTVC.m
//  AzBodyNote
//
//  Created by 松山 和正 on 11/10/02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "MocEntity.h"
#import "MocFunctions.h"
#import "E2editTVC.h"
#import "E2editCellValue.h"

@implementation E2editTVC
@synthesize Re2edit;
@synthesize ownerE2editTVC;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - IBAction

/*
- (IBAction)ibBuValue:(UIButton *)button
{
	NSLog(@"ibBuValue");
}

- (IBAction)ibSrValueChange:(UISlider *)slider
{
	NSLog(@"ibSrValueChange");
}

- (IBAction)actionCellValueTouch:(UIButton *)button
{
	NSLog(@"actionCellValueTouch .tag=%d", button.tag);
}
- (IBAction)actionCellSliderChange:(UISlider *)slider
{
	NSLog(@"actionCellSliderChange .tag=%d", slider.tag);
}
*/

- (void)actionClear
{
	assert(mIsAddNew);
	assert(Re2edit);
	
	Re2edit.datetime = [NSDate date];
	Re2edit.bpHi_mmHg = nil;
	Re2edit.bpLo_mmHg = nil;
	Re2edit.pulse_bpm = nil;
	
	[self.tableView reloadData];
}

- (void)actionSave
{
	
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
	if (Re2edit) {
		// Edit mode.
		mIsAddNew = NO;
		// [Cancel]ボタンを左側に追加する  Navi標準の戻るボタンでは actionCancel 処理ができないため
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
												  target:self action:@selector(actionCancel)] autorelease];
	} else {
		// AddNew mode.
		mIsAddNew = YES;
		Re2edit = [MocFunctions insertAutoEntity:@"E2record"]; // autorelese
		// [Clear]ボタンを左側に追加する  Navi標準の戻るボタンでは cancelClose:処理ができないため
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithTitle:NSLocalizedString(@"Clear",nil) style:UIBarButtonItemStyleBordered 
												  target:self action:@selector(actionClear)] autorelease];
	}

	// SAVEボタンを右側に追加する
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
											   target:self action:@selector(actionSave)] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO; // 変更あればYESにする
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // タテ正面のみ
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		return 50; // DateTime
	} else {
		return 80; // CellValue
	}
    return 44; // Default
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    assert(indexPath.section==0);
	static NSString *CellIDate = @"CellDate";
	static NSString *CellIValue = @"E2editCellValue";

    if (indexPath.row==0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIDate];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIDate] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.font = [UIFont systemFontOfSize:18];
			cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
		}
		cell.textLabel.text = NSLocalizedString(@"DateTime",nil);
		
		NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
		// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		[fmt setCalendar:calendar];
		[calendar release];
		//[df setLocale:[NSLocale systemLocale]];これがあると曜日が表示されない。
		[fmt setDateFormat:@"yyyy-M-d EE HH:mm"];
		if (mIsAddNew OR Re2edit.datetime==nil) {
			Re2edit.datetime = [NSDate date];
		}
		cell.detailTextLabel.text = [fmt stringFromDate:Re2edit.datetime];
		[fmt release];
		return cell;
	}
	else {
		E2editCellValue *cell = (E2editCellValue*)[tableView dequeueReusableCellWithIdentifier:CellIValue];
		if (cell == nil) {
			//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIValue] autorelease];
			UINib *nib = [UINib nibWithNibName:CellIValue   bundle:nil];
			//NSArray *array = [nib instantiateWithOwner:s  options:nil];
			//cell = (E2editCellValue*)[array objectAtIndex:0];
			[nib instantiateWithOwner:self options:nil];
			cell = self.ownerE2editTVC;
			
			//cell = [[[E2editCellValue alloc] init] autorelease];
			//--------------------------------------------------------------------------Name
			//mCellName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 173, 35)];
			//mCellName.font = [UIFont	systemFontSize:
			//[cell.contentView addSubview:mCellName], [mCellName release];
		}
		switch (indexPath.row) {
			case 1:
				cell.ibLbName.text = NSLocalizedString(@"BpHi Name",nil);
				cell.ibLbUnit.text = @"mmHg";
				cell.ibBuValue.tag = 1;
				cell.ibSrValue.tag = 1;
				cell.RnValue = Re2edit.bpHi_mmHg; // NSNumber
				cell.mValueMin = 30;
				cell.mValueMax = 300;
				cell.mValueRate = 1;
				cell.mValueStep = 1;
				break;
			case 2:
				cell.ibLbName.text = NSLocalizedString(@"BpLo Name",nil);
				cell.ibLbUnit.text = @"mmHg";
				cell.ibBuValue.tag = 2;
				cell.ibSrValue.tag = 2;
				cell.RnValue = Re2edit.bpLo_mmHg; // NSNumber
				cell.mValueMin = 20;
				cell.mValueMax = 200;
				cell.mValueRate = 1;
				cell.mValueStep = 1;
				break;
			case 3:
				cell.ibLbName.text = NSLocalizedString(@"Pulse rate",nil);
				cell.ibLbUnit.text = NSLocalizedString(@"Pulse unit",nil);
				cell.ibBuValue.tag = 3;
				cell.ibSrValue.tag = 3;
				cell.RnValue = Re2edit.pulse_bpm; // NSNumber
				cell.mValueMin = 10;
				cell.mValueMax = 200;
				cell.mValueRate = 1;
				cell.mValueStep = 1;
				break;
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
