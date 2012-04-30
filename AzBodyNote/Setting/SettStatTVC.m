//
//  SettStatTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettStatTVC.h"
#import "GraphVC.h"


@implementation SettStatTVC
@synthesize ppBackStat = __BackStat;


- (void)actionBack
{
	[self dismissModalViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
		GA_TRACK_PAGE(@"SettStatTVC");
		__BackStat = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"SettStat",nil);
	
	//self.navigationItem.rightBarButtonItem = [self editButtonItem];	//右[Edit]ボタン
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (__BackStat) {
		// Graphから呼び出されたときバックボタンが無いので付ける
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
												 initWithTitle: NSLocalizedString(@"SettStat Back", nil)
												 style:UIBarButtonItemStyleBordered
												 target:self action:@selector(actionBack)];
	}

	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mValueDays = [[kvs objectForKey:GUD_SettStatDays] integerValue];
	if (mValueDays<1 OR GRAPH_PAGE_LIMIT <mValueDays) {
		mValueDays = 1;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{	// 非表示になる前に呼び出される
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];

	
	[kvs synchronize];
    [super viewWillDisappear:animated];
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
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section==0) {
		return 1;
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		if (indexPath.row==0) return 88; // Days
		return 44;
	}
    return 44; // Default
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (void)refreshStatDays
{
	if (mLbValueDays) {
		mLbValueDays.text = [NSString stringWithFormat:@"%ld", (long)mValueDays];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル
	static NSString *sysCellDial = @"sysCellDial";
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	
	if (indexPath.section==0) {
		switch (indexPath.row) {
			case 0: {	// 期間指定
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellDial];
				if (cell == nil) {
					cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellDial];
					// Label
					UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 25)];
					lb.font = [UIFont boldSystemFontOfSize:20];
					lb.adjustsFontSizeToFitWidth = YES;
					lb.minimumFontSize = 10;
					lb.backgroundColor = [UIColor clearColor];
					lb.text = NSLocalizedString(@"SettStat Days",nil);
					[cell.contentView addSubview:lb];
					// Label
					mLbValueDays = [[UILabel alloc] initWithFrame:CGRectMake(200, 8, 70, 30)];
					mLbValueDays.font = [UIFont systemFontOfSize:26];
					mLbValueDays.textAlignment = UITextAlignmentRight;
					mLbValueDays.backgroundColor = [UIColor clearColor];
					[cell.contentView addSubview:mLbValueDays];
					// AZDial
					mDialDays = [[AZDial alloc] initWithFrame:CGRectMake(15, 40, 280, 44)
													 delegate: self
														 dial: mValueDays
														  min: 1
														  max: 50
														 step: 1
													  stepper: 1];
					[cell.contentView addSubview:mDialDays];
					mDialDays.backgroundColor = [UIColor clearColor]; //self.backgroundColor;
				}
				[self refreshStatDays];
				return cell;
			}	break;
		}
	}
    return nil;
}


#pragma mark - <AZDialDelegate>
- (void)dialChanged:(id)sender dial:(NSInteger)dial
{	// dialが変位したとき
	mValueDays = dial;
	[self refreshStatDays];
}

- (void)dialDone:(id)sender dial:(NSInteger)dial
{	// dial変位が停止したとき
	mValueDays = dial;
	[self refreshStatDays];

	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject:[NSNumber numberWithInteger:mValueDays] forKey:GUD_SettStatDays];
}


@end
