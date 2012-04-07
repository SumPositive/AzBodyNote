//
//  SettingTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "SettingTVC.h"
#import "SettCellSwitch.h"
#import "SettCellLogin.h"
#import "InformationVC.h"
#import "AZStoreTVC.h"


#define STORE_PRODUCTID_UNLOCK		@"com.azukid.AzBodyNote.Unlock"		// In-App Purchase ProductIdentifier


@interface SettingTVC ()

@end

@implementation SettingTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	// Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	if (section==0) {
		return 2;
	} else {
		return 2;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *idCellSubtitle = @"CellStyleSubtitle";
	static NSString *idCellSwitch = @"SettCellSwitch";  //== Identifire に一致させること

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {	// Tweet
			SettCellSwitch *cell = (SettCellSwitch*)[tableView dequeueReusableCellWithIdentifier:idCellSwitch];
			if (cell == nil) {
				UINib *nib = [UINib nibWithNibName:idCellSwitch   bundle:nil];
				[nib instantiateWithOwner:self options:nil];
				cell = (SettCellSwitch*)[tableView dequeueReusableCellWithIdentifier:idCellSwitch];
				assert(cell);
			}
			cell.tag = TAG_SettCellSwitch_Tweet;
			cell.textLabel.text = NSLocalizedString(@"SettTweet",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettTweet detail",nil);
			[cell.ibSwitch setOn: [userDefaults boolForKey:GUD_bTweet]];
			return cell;
		}	break;
			
		case 2: {	// Test
			SettCellSwitch *cell = (SettCellSwitch*)[tableView dequeueReusableCellWithIdentifier:idCellSwitch];
			if (cell == nil) {
				UINib *nib = [UINib nibWithNibName:idCellSwitch   bundle:nil];
				[nib instantiateWithOwner:self options:nil];
				cell = (SettCellSwitch*)[tableView dequeueReusableCellWithIdentifier:idCellSwitch];
				assert(cell);
			}
			cell.tag = TAG_SettCellSwitch_Test;
			cell.textLabel.text = NSLocalizedString(@"SettTest",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettTest detail",nil);
			[cell.ibSwitch setOn: ![userDefaults boolForKey:GUD_bTweet]];
			return cell;
		}	break;
			
		case 100: {	// このアプリについて
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idCellSubtitle];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = NSLocalizedString(@"SettInformation",nil);
			return cell;
		}	break;

		case 101: {	// あずき商店
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idCellSubtitle];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = NSLocalizedString(@"SettAppStore",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettAppStore detail",nil);
			return cell;
		}	break;
	}
    return nil;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	// 画面遷移のとき、didSelectRowAtIndexPath:よりも先に呼び出される
	NSLog(@"prepareForSegue: sender=%@", sender);
	NSLog(@"prepareForSegue: segue=%@", segue);
	NSLog(@"prepareForSegue: [segue identifier]=%@", [segue identifier]);
	NSLog(@"prepareForSegue: [segue sourceViewController]=%@", [segue sourceViewController]);
	NSLog(@"prepareForSegue: [segue destinationViewController]=%@", [segue destinationViewController]);
	
/*	if ([[segue identifier] isEqualToString:@"push_Information"])
	{
		InformationVC *vc = [segue destinationViewController];
	}*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	// 選択状態を解除する
	
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 100: {	// このアプリについて
			// InformationVC
		}	break;
			
		case 101: {	// あずき商店
			AZStoreTVC *vc = [[AZStoreTVC alloc] init];
			[vc setTitle:NSLocalizedString(@"SettTest",nil)];
			// 商品IDリスト
			NSSet *pids = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil]; // 商品が複数ある場合は列記
			[vc setProductIDs:pids];  //商品一覧リクエスト開始
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
	}
}


@end
