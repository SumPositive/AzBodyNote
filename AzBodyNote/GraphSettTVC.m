//
//  GraphSettTVC.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphSettTVC.h"


@interface GraphSettTVC (Private)
@end

@implementation GraphSettTVC


- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
		mAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		assert(mAppDelegate);
		GA_TRACK_PAGE(@"GraphSettTVC");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Graph Settings",nil);
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	mAppDelegate.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	if (mAppDelegate.adWhirlView) {	// Ad ON
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1.2];
		mAppDelegate.adWhirlView.frame = CGRectMake(0, 700, 320, 50);  // GAD_SIZE_320x50
		mAppDelegate.adWhirlView.hidden = YES;
		[UIView commitAnimations];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	// Return the number of rows in the section.
	if (section==0) {
		return 1;
	} else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: return  55;	// Goal
	}
    return 44; // Default
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *sysCellSubtitle = @"sysCellSubtitle"; //システム既定セル

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
	switch (indexPath.section*100 + indexPath.row) 
	{
		case 0: {	// Goal
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sysCellSubtitle];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sysCellSubtitle];
			}
			cell.textLabel.text = NSLocalizedString(@"Graph SettGoal",nil);
			cell.detailTextLabel.text = NSLocalizedString(@"Graph SettGoal detail",nil);
			if ([userDefaults boolForKey:GUD_bGoal]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
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
		case 0: {  // Goal
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			if ([userDefaults boolForKey:GUD_bGoal]) {
				[userDefaults setBool: NO forKey:GUD_bGoal];
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				[userDefaults setBool: YES forKey:GUD_bGoal];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			[userDefaults synchronize];
		} break;
	}
}


@end
