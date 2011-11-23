//
//  GraphVC.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "Global.h"
#import "GraphVC.h"


@implementation GraphVC
{
	IBOutlet UIScrollView		*ibScrollView;
	IBOutlet UIView				*ibGraphView;
	
	NSArray *bodyNotes_;
	
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
	
	CGRect rc = ibScrollView.bounds;
	rc.size.width *= 10;
	ibScrollView.contentSize = rc.size;
	ibGraphView.frame = rc;

	ibScrollView.contentOffset = CGPointMake(rc.size.width - ibScrollView.frame.size.width, 0);  // 右端（当日）を表示する
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[ibGraphView drawRect:self.view.frame];
	self.view.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (self.view.alpha != 1) {
		[super viewDidAppear:animated];
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDuration:1.5];
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
