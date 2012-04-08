//
//  SettingTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingTVC.h"
//#import "SettCellSwitch.h"
#import "SettCellGoogleLogin.h"
#import "AZAboutThisVC.h"
#import "AZStoreTVC.h"


#define STORE_PRODUCTID_UNLOCK		@"com.azukid.AzBodyNote.Unlock"		// In-App Purchase ProductIdentifier


@interface SettingTVC (Private)
@end

@implementation SettingTVC


- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"TabSettings",nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	GA_TRACK_PAGE(@"SettingTVC");
	mAppDelegate.app_is_AdShow = NO; //これは広告表示可能なViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {
		mAppDelegate.adWhirlView.alpha = 0;
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: return  55;	// Tweet
		case 1: return  88;	// Google Login
	}
    return 44; // Default
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {	// Tweet
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"SettTweet",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"SettTweet detail",nil);
			if ([userDefaults boolForKey:GUD_bTweet]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			return cell;
		}	break;
			
		case 1: {	// Google Login
			static NSString *cid = @"SettCellGoogleLogin";  //== Identifire に一致させること
			SettCellGoogleLogin *cell = (SettCellGoogleLogin*)[tableView dequeueReusableCellWithIdentifier:cid];
			if (cell == nil) {
				UINib *nib = [UINib nibWithNibName:cid   bundle:nil];
				[nib instantiateWithOwner:self options:nil];
				cell = (SettCellGoogleLogin*)[tableView dequeueReusableCellWithIdentifier:cid];
				assert(cell);
			}
			return cell;
		}	break;
			
		case 100: {	// このアプリについて
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			//cell.imageView.image = [UIImage imageNamed:@"Icon57"];
			//cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
			//cell.imageView.frame = CGRectMake(0, 0, 32, 32);
			cell.textLabel.text = NSLocalizedString(@"AZAboutThis",nil);
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			return cell;
		}	break;

		case 101: {	// あずき商店
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.imageView.image = [UIImage imageNamed:@"Icon-Store-32"];
			cell.textLabel.text = NSLocalizedString(@"AZStore",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"AZStore detail",nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
		case 0: {  // Tweet
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([userDefaults boolForKey:GUD_bTweet]) {
				[userDefaults setBool: NO forKey:GUD_bTweet];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[userDefaults setBool: YES forKey:GUD_bTweet];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[userDefaults synchronize];
		} break;
			
		case 100: {	// このアプリについて
			AZAboutThisVC *vc = [[AZAboutThisVC alloc] init];
			vc.ppImgIcon = [UIImage imageNamed:@"Icon57"];
			vc.ppProductTitle = NSLocalizedString(@"Product Title",nil);
			vc.ppProductSubtitle = @"Condition (.azc)";
			vc.ppSupportSite = @"condition.azukid.com";
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
			
		case 101: {	// あずき商店
			AZStoreTVC *vc = [[AZStoreTVC alloc] init];
			// 商品IDリスト
			NSSet *pids = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil]; // 商品が複数ある場合は列記
			[vc setProductIDs:pids];
			vc.hidesBottomBarWhenPushed = YES; //以降のタブバーを消す
			[self.navigationController pushViewController:vc animated:YES];
		}	break;
	}
}


@end
