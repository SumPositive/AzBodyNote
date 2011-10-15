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
		mDial = nil;
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

	if (!mDial) {
		mDial = [[AZDial alloc] initWithFrame:CGRectMake(20, 100, 200, 44) 
									 delegate:self dial:50 min:0 max:300 step:1 stepper:YES];
		[self.view addSubview:mDial];
		mDial.backgroundColor = [UIColor greenColor]; //self.view.backgroundColor;
	}
}

- (void)volumeChanged:(id)sender dial:(NSInteger)dial
{
	ibLbVolume.text = [NSString stringWithFormat:@"%ld", dial];
	//ibLbVolume.backgroundColor = [UIColor yellowColor];
}

- (void)volumeDone:(id)sender dial:(NSInteger)dial
{
	ibLbVolume.text = [NSString stringWithFormat:@"%ld", dial];
	//ibLbVolume.backgroundColor = [UIColor blueColor];
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
