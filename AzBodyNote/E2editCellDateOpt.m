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
	for (DateOpt opt=0; opt < ibSegment.numberOfSegments; opt++) {
		if (opt == ibSegment.selectedSegmentIndex) {
			switch (opt) {
				case DtOpWake: //起床後
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-Wake"] forSegmentAtIndex:opt];
					break;
				case DtOpRest: //安静時
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-Rest"] forSegmentAtIndex:opt];
					break;
				case DtOpDown: //運動後
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-Down"] forSegmentAtIndex:opt];
					break;
				case DtOpSleep: //就寝前
					[ibSegment setImage:[UIImage imageNamed:@"Icon20-Sleep"] forSegmentAtIndex:opt];
					break;
				default:
					[ibSegment setImage:nil forSegmentAtIndex:opt];
					[ibSegment setTitle:[mTitles objectAtIndex:opt] forSegmentAtIndex:opt];
					break;
			}
		} else {
			[ibSegment setImage:nil forSegmentAtIndex:opt];
			[ibSegment setTitle:[mTitles objectAtIndex:opt] forSegmentAtIndex:opt];
		}
	}
}

- (IBAction)ibSegmentChange:(UISegmentedControl *)sender
{
	__E2record.nDateOpt = [NSNumber numberWithInteger:ibSegment.selectedSegmentIndex];
	[self buttonDraw];

	if ([__delegate respondsToSelector:@selector(delegateDateOptChange)]) { // E2editTVC:<delegate>
		[__delegate delegateDateOptChange];  // 変更あり
	}
}

- (void)drawRect:(CGRect)rect
{
	if (mTitles==nil) {
		mTitles = [NSArray arrayWithObjects:
				   NSLocalizedString(@"DateOpt Wake",nil),
				   NSLocalizedString(@"DateOpt Rest",nil),
				   NSLocalizedString(@"DateOpt Down",nil),
				   NSLocalizedString(@"DateOpt Sleep",nil),
				   nil];
	}
	
	if (__E2record.nDateOpt) {
		ibSegment.selectedSegmentIndex = [__E2record.nDateOpt integerValue];
	} else {
		ibSegment.selectedSegmentIndex = 1; //Warm-up
	}
	[self buttonDraw];
}

@end
