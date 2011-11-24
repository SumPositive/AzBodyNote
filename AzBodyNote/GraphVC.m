//
//  GraphVC.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "GraphVC.h"
#import "GraphView.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"


@implementation GraphVC
{
	IBOutlet UIScrollView		*ibScrollView;
	IBOutlet GraphView			*ibGraphView;
	
	NSArray		*aE2records_;
	
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

/*XIB
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:@"RefreshAllViews" 
											   object:[[UIApplication sharedApplication] delegate]];
	
	// ibLbBpHi.backgroundColor = self.view.backgroundColor とする。スクロール範囲外になったとき見えなくするため
	ibLbBpHi.text = NSLocalizedString(@"BpHi Name",nil);		
	ibLbBpLo.text = NSLocalizedString(@"BpLo Name",nil);
	ibLbPuls.text = NSLocalizedString(@"Pulse Name",nil);
	ibLbWeight.text = NSLocalizedString(@"Weight Name",nil);
	ibLbTemp.text = NSLocalizedString(@"Temp Name",nil);
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	// E2record 取得
	aE2records_ = nil; 
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	aE2records_ = [MocFunctions select: @"E2record"
								 limit: RECORD_LIMIT
								offset: 0
								 where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
								  sort: sortDesc]; // 最新日付から抽出
	
	if ([aE2records_ count] < 1) {
		aE2records_ = nil;
		ibGraphView.RaE2records = aE2records_;
		return;
	}
	
	ibGraphView.RaE2records = aE2records_;
	
	// GraphView サイズを決める
	CGRect rc = ibScrollView.bounds;
	rc.origin.x = 0;
	rc.size.width = RECORD_WIDTH * [aE2records_ count] + MARGIN_WIDTH*2;
	ibScrollView.contentSize = rc.size;
	ibGraphView.frame = rc;
	ibScrollView.contentOffset = CGPointMake(rc.size.width - ibScrollView.bounds.size.width, 0);  // 右端（当日）を表示する

	//[ibGraphView drawRect:self.view.frame];  NG//これだと不具合発生する
	[ibGraphView setNeedsDisplay]; //drawRect:が呼び出される
	
	self.view.alpha = 0;
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
		//[UIView setAnimationDelegate:self];
		//[UIView setAnimationDidStopSelector:@selector(hide_after_dissmiss)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
		// アニメ終了状態
		self.view.alpha = 1;
		// アニメ実行
		[UIView commitAnimations];
	}
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - iCloud
- (void)refreshAllViews:(NSNotification*)note 
{	// iCloud-CoreData に変更があれば呼び出される
    if (note) {
		//[self.tableView reloadData];
		[self viewWillAppear:YES];
    }
}


@end
