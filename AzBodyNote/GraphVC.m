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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		mVolume = nil;
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

	if (!mVolume) {
		mVolume = [[AZVolume alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
		mVolume.mVolume = 0;
		mVolume.mVolumeMin = -1000;
		mVolume.mVolumeMax = 1000;
		mVolume.mVolumeStep = 1;
		mVolume.delegate = self;
		[self.view addSubview:mVolume];
	}
}

- (void)volumeChanged:(NSInteger)volume
{
	ibLbVolume.text = [NSString stringWithFormat:@"%ld", volume];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
