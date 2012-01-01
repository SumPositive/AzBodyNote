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
	
	AzBodyNoteAppDelegate		*appDelegate_;
	MocFunctions							*mocFunc_;
	
	NSUInteger								uiActivePage_;
	NSUInteger								uiActivePageMax_;
	UIActivityIndicatorView			*actIndicator_;
}

/*** XIB利用時には呼ばれません。
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate_ = [[UIApplication sharedApplication] delegate];
		assert(appDelegate_);
		mocFunc_ = appDelegate_.mocBase; // Read Only
		assert(mocFunc_);
    }
    return self;
}
*/

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
	self.title = NSLocalizedString(@"TabGraph",nil);

	appDelegate_ = (AzBodyNoteAppDelegate*)[[UIApplication sharedApplication] delegate];
	assert(appDelegate_);
	mocFunc_ = appDelegate_.mocBase; // Read Only
	assert(mocFunc_);
	
	if (appDelegate_.gud_bPaid==NO) {
		uiActivePageMax_ = 0; // 0ページ制限
	}

	// listen to our app delegates notification that we might want to refresh our detail view
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(refreshAllViews:) 
												 name:NFM_REFRESH_ALL_VIEWS 
											   object:[[UIApplication sharedApplication] delegate]];
	
	// ibLbBpHi.backgroundColor = self.view.backgroundColor とする。スクロール範囲外になったとき見えなくするため
	ibLbBpHi.text = NSLocalizedString(@"BpHi Name",nil);		
	ibLbBpLo.text = NSLocalizedString(@"BpLo Name",nil);
	ibLbPuls.text = NSLocalizedString(@"Pulse Name",nil);
	ibLbWeight.text = NSLocalizedString(@"Weight Name",nil);
	ibLbTemp.text = NSLocalizedString(@"Temp Name",nil);
	
	ibScrollView.delegate = self; // <UIScrollViewDelegate>

	if (actIndicator_==nil) {
		actIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		actIndicator_.frame = CGRectMake(0, 0, 50, 50);
		[actIndicator_ stopAnimating];
		[ibScrollView addSubview:actIndicator_];
	}
}

- (void)graphViewPage:(NSUInteger)page
{
	if (uiActivePageMax_ < page) return;

	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	NSArray *e2recs = [mocFunc_ select: @"E2record"
									limit: GRAPH_PAGE_LIMIT
									offset: (GRAPH_PAGE_LIMIT * page)
									where: [NSPredicate predicateWithFormat: E2_nYearMM @" > 200000"] // 未保存を除外する
									sort: sortDesc]; // 最新日付から抽出

	if ([e2recs count] < GRAPH_PAGE_LIMIT) {
		uiActivePageMax_ = uiActivePage_;  // 最終ページ判明
	}
	
	ibGraphView.RaE2records = e2recs;
	
	// GraphView サイズを決める
	CGRect rc = ibScrollView.bounds;
	CGFloat fWhalf = rc.size.width / 2.0; // 表示幅の半分（画面中央）
	int iCount = [e2recs count];
	if (iCount < 2) iCount = 2; // 1だとスクロール出来なくなる
	//                     (                 左余白                 ) + (               レコード               ) + (                 右余白                 ); 
	rc.size.width = (fWhalf - RECORD_WIDTH/2) + (RECORD_WIDTH * iCount) + (fWhalf - RECORD_WIDTH/2);
	ibScrollView.contentSize = rc.size;
	rc.origin.x = (fWhalf - RECORD_WIDTH/2); // 左余白
	rc.size.width = RECORD_WIDTH * iCount;	// レコード
	ibGraphView.frame = rc;
	
	//[ibGraphView drawRect:self.view.frame];  NG//これだと不具合発生する
	[ibGraphView setNeedsDisplay]; //drawRect:が呼び出される

	if (page < uiActivePage_) {	// [ibGraphView setNeedsDisplay]より先にスクロールさせること
		// 左端を画面中央に表示する
		ibScrollView.contentOffset = CGPointMake(0, 0);  
	} else {
		// 右端を画面中央に表示する
		ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);  
	}
	uiActivePage_ = page;
}

- (void)graphViewPage:(NSUInteger)page animated:(BOOL)animated
{
	if (animated) {
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:@"Graph" context:context];
		[UIView setAnimationDuration:1.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animation_after)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	}
	// アニメ終了状態
	[self graphViewPage:page];// この中で、uiActivePage_が更新される

	if (animated) {
		// アニメ実行
		[UIView commitAnimations];
	} else {
		[actIndicator_ stopAnimating];
	}
}

- (void)animation_after
{
	[actIndicator_ stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	uiActivePageMax_ = 999; // この時点で最終ページは不明
	[self graphViewPage:0 animated:YES];

	// 最初、GOALを画面中央に表示する
	//ibScrollView.contentOffset = CGPointMake(ibScrollView.contentSize.width - ibScrollView.bounds.size.width, 0);  
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
    //if (note) {
		//[self.tableView reloadData];
		[self viewWillAppear:NO]; // NO によりrefreshであることを知らせている。
		// この後、viewDidAppear: は呼ばれないことに注意！
    //}
}


#pragma mark - <UIScrollViewDelegate> Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	// スクロール中に呼ばれる
	//NSLog(@"scrollViewDidScroll: .contentOffset.x=%f", scrollView.contentOffset.x);
	if (appDelegate_.gud_bPaid) {
/*		if (scrollView.contentOffset.x < -50) {
			// 前ページへ予告表示
			if (lbPagePrev_.tag != 1) {
				lbPagePrev_.tag = 1;
				lbPagePrev_.text = NSLocalizedString(@"PagePrevGo",nil);
			}
		} else {
			if (lbPagePrev_.tag != 0) {
				lbPagePrev_.tag = 0;
				lbPagePrev_.text = NSLocalizedString(@"PagePrev",nil);
			}
		}*/
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	// スクロール終了時（指を離した時）に呼ばれる
	NSLog(@"scrollViewDidEndDragging: .contentOffset.x=%f  decelerate=%d", scrollView.contentOffset.x, decelerate);
	if (appDelegate_.gud_bPaid) {
		if (scrollView.contentOffset.x < -50) {
			// PREV（過去）ページへ
			if (uiActivePage_ < uiActivePageMax_) {
				NSLog(@"scrollViewDidEndDragging: PREV uiActivePage_=%d + 1", uiActivePage_);
				// 画面左側にインジケータ表示
				[actIndicator_ setFrame:CGRectMake(80, ibScrollView.frame.size.height/2-25, 50, 50)];
				[actIndicator_ startAnimating];
				[self graphViewPage:uiActivePage_ + 1 animated:YES];
			}
		}
		else if (scrollView.contentSize.width - ibScrollView.bounds.size.width + 50 < scrollView.contentOffset.x) {
			// NEXT（未来）ページへ
			if (0 < uiActivePage_) {
				NSLog(@"scrollViewDidEndDragging: NEXT uiActivePage_=%d - 1", uiActivePage_);
				// 画面右側にインジケータ表示
				[actIndicator_ setFrame:CGRectMake(ibScrollView.contentSize.width-80-50, ibScrollView.frame.size.height/2-25, 50, 50)];
				[actIndicator_ startAnimating];
				[self graphViewPage:uiActivePage_ - 1 animated:YES];
			}
		}
	/*	else {
			NSLog(@"scrollViewDidEndDragging: scrollView.contentSize.width=%f  scrollView.contentSize.width=%f", 
												scrollView.contentSize.width, scrollView.contentSize.width);
		}*/
	}
}



@end
