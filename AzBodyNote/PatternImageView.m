//
//  PatternImageView.m
//  AzPackList
//
//  Created by Sum Positive on 12/01/07.
//  Copyright (c) 2012 Azukid. All rights reserved.
//

#import "PatternImageView.h"

@implementation PatternImageView


- (id)initWithFrame:(CGRect)frame  patternImage:(UIImage*)image 
{
	self = [super init];
	if (self) {
		self.frame = frame;
		mImage = image;
	}
	return self;
}

- (void)drawRect:(CGRect)rect 
{
	[mImage drawAsPatternInRect:self.bounds];	// タイル描画
}

@end

