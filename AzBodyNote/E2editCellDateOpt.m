//
//  E2editCellDateOpt.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//
#import "E2editCellDateOpt.h"

@implementation E2editCellDateOpt
@synthesize delegate = __delegate;
@synthesize ppE2record = __E2record;


- (void)buttonDraw
{
	for (int ii = 0; ii < ibSegment.numberOfSegments; ii++) {
		if (ii == ibSegment.selectedSegmentIndex) {
			switch (ii) {
				case 0: //起床後
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-WakeUp"] forSegmentAtIndex:ii];
					break;
				case 2: //就寝前
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-ForSleep"] forSegmentAtIndex:ii];
					break;
				default:
					[ibSegment setImage:nil forSegmentAtIndex:ii];
					[ibSegment setTitle:[mTitles objectAtIndex:ii] forSegmentAtIndex:ii];
					break;
			}
		} else {
			[ibSegment setImage:nil forSegmentAtIndex:ii];
			[ibSegment setTitle:[mTitles objectAtIndex:ii] forSegmentAtIndex:ii];
		}
	}
}

- (IBAction)ibSegmentChange:(UISegmentedControl *)sender
{
	__E2record.nDateOpt = [NSNumber numberWithInteger:ibSegment.selectedSegmentIndex];
	[self buttonDraw];

	if ([__delegate respondsToSelector:@selector(editUpdate)]) { // E2editTVC:<delegate>
		[__delegate editUpdate];  // 変更あり
	}
}

- (void)drawRect:(CGRect)rect
{
	if (mTitles==nil) {
		mTitles = [NSArray arrayWithObjects:
				   NSLocalizedString(@"DateOpt Wake-up",nil),
				   NSLocalizedString(@"DateOpt Active",nil),
				   NSLocalizedString(@"DateOpt For-sleep",nil),
				   nil];
	}
	
	ibSegment.selectedSegmentIndex = [__E2record.nDateOpt integerValue];
	[self buttonDraw];
}

@end
