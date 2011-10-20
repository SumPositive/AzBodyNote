//
//  GraphView.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/17.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#include <stdlib.h>			// arc4random()
#import "GraphView.h"

@implementation GraphView
{
	NSArray *maDate;
	NSArray *maBpHi;
	NSArray *maBpLo;
	NSArray *maPuls;
	NSArray *maWeight;
	NSArray *maTemp;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// X軸: 1dot = 1Hour
// Y軸: 1dot

- (void)graphDraw:(CGContextRef)cgc frame:(CGRect)frame
{
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.2);
	
	CGFloat fHeight = frame.size.height - 3 - 15;  // 上下の余白を除いた有効な高さ
	// Temp領域 (H:1/8)
	CGRect rcTemp = frame;
	rcTemp.origin.y = 3.0;													// Y開始
	rcTemp.size.height = fHeight / 8.0;				// 高さ
	//CGContextSetRGBFillColor(cgc, 0.0, 0.6, 0.6, 1.0);
	//CGContextAddRect(cgc, rcTemp);
	//CGContextFillPath(cgc);
	
	// Weight領域 (H:1/4)
	CGRect rcWeight = frame;
	rcWeight.origin.y = rcTemp.origin.y + rcTemp.size.height;		// Y開始
	rcWeight.size.height = fHeight / 4.0;						// 高さ
	//CGContextSetRGBFillColor(cgc, 0.6, 0.0, 0.6, 1.0);
	//CGContextAddRect(cgc, rcWeight);
	//CGContextFillPath(cgc);

	// Puls領域  (H:1/8)
	CGRect rcPuls = frame;
	rcPuls.origin.y = rcWeight.origin.y + rcWeight.size.height;		// Y開始
	rcPuls.size.height = fHeight / 8.0;							// 高さ
	//CGContextSetRGBFillColor(cgc, 0.6, 0.6, 0.0, 1.0);
	//CGContextAddRect(cgc, rcPuls);
	//CGContextFillPath(cgc);
	
	// BpHi,Lo領域  (H:1/2)
	CGRect rcBp = frame;
	rcBp.origin.y = rcPuls.origin.y + rcPuls.size.height;				// Y開始
	rcBp.size.height = fHeight / 2.0;							// 高さ
	//CGContextSetRGBFillColor(cgc, 0.6, 0.6, 0.6, 1.0);
	//CGContextAddRect(cgc, rcBp);
	//CGContextFillPath(cgc);


	NSInteger iMaxBp = 0;
	NSInteger iMinBp = 999;
	NSInteger iMaxPuls = 0;
	NSInteger iMinPuls = 999;
	NSInteger iMaxWeight = 0;
	NSInteger iMinWeight = 999;
	NSInteger iMaxTemp = 0;
	NSInteger iMinTemp = 999;
	NSInteger index = [maDate count] - 1;
	NSInteger ii;

	// 準備
	for (CGFloat fx=frame.size.width ; 0.0 < fx && 0<=index ; fx -= (W_HOUR * 24), index--) 
	{	// 日付線
		CGContextMoveToPoint(cgc, fx, frame.origin.y);
		CGContextAddLineToPoint(cgc, fx, frame.origin.y + frame.size.height);
			
		ii = [[maBpHi objectAtIndex:index] integerValue];
		if (ii < iMinBp) iMinBp = ii;	else if (iMaxBp < ii) iMaxBp = ii;
		
		ii = [[maBpLo objectAtIndex:index] integerValue];
		if (ii < iMinBp) iMinBp = ii;	else if (iMaxBp < ii) iMaxBp = ii;
		
		ii = [[maPuls objectAtIndex:index] integerValue];
		if (ii < iMinPuls) iMinPuls = ii;	else if (iMaxPuls < ii) iMaxPuls = ii;
	
	}
	//画面に描画
	CGContextStrokePath(cgc);

	//CGFloat fx, fy, f1x,f1y, f2x,f2y;
	CGFloat fYstep;
	CGPoint po;
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.5);

	// BpHi グラフ描画
	fYstep = rcBp.size.height / (iMaxBp - iMinBp + H_GAP*2);  // 1あたりのポイント数
	index = [maDate count] - 1;
	po.x = frame.size.width;
	po.y = rcBp.origin.y + H_GAP + ((iMaxBp - iMinBp)/2 * fYstep);  //<<<<<目標値にする
	CGContextMoveToPoint(cgc, po.x, po.y);		// 始点
#ifdef YES
		// 折れ線
		for ( ; 0.0 < po.x && 0<=index; po.x -= (W_HOUR * 24), index--) 
		{
			po.y = rcBp.origin.y + H_GAP + fYstep * (CGFloat)([[maBpHi objectAtIndex:index] integerValue] - iMinBp);
			CGContextAddLineToPoint(cgc, po.x, po.y);
		}
#else
		// スプライン曲線
#endif
	CGContextStrokePath(cgc);
	
	// BpLo グラフ描画
	//fYstep = rcBp.size.height / (iMaxBp - iMinBp + H_GAP*2);  // 1あたりのポイント数
	index = [maDate count] - 1;
	po.x = frame.size.width;
	po.y = rcBp.origin.y + H_GAP + ((iMaxBp - iMinBp)/2 * fYstep);  //<<<<<目標値にする
	CGContextMoveToPoint(cgc, po.x, po.y);
	for ( ; 0.0 < po.x && 0<=index; po.x -= (W_HOUR * 24), index--) 
	{
		po.y = rcBp.origin.y + H_GAP + fYstep * (CGFloat)([[maBpLo objectAtIndex:index] integerValue] - iMinBp);
		CGContextAddLineToPoint(cgc, po.x, po.y);
	}
	CGContextStrokePath(cgc);
	
	// Puls グラフ描画
	fYstep = rcPuls.size.height / (iMaxPuls - iMinPuls + H_GAP*2);  // 1あたりのポイント数
	index = [maDate count] - 1;
	po.x = frame.size.width;
	po.y = rcPuls.origin.y + H_GAP + ((iMaxPuls - iMinPuls)/2 * fYstep);  //<<<<<目標値にする
	CGContextMoveToPoint(cgc, po.x, po.y);
	for ( ; 0.0 < po.x && 0<=index; po.x -= (W_HOUR * 24), index--) 
	{
		po.y = rcPuls.origin.y + H_GAP + fYstep * (CGFloat)([[maPuls objectAtIndex:index] integerValue] - iMinPuls);
		CGContextAddLineToPoint(cgc, po.x, po.y);
	}
	CGContextStrokePath(cgc);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	
	//現在のグラフィックスコンテキストを取得
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
    CGContextTranslateCTM(cgc, 0, rect.size.height);
    CGContextScaleCTM(cgc, 1.0, -1.0);

	
	NSMutableArray *mua = [NSMutableArray new];
	
	for (int ii=0; ii<100; ii++) {
		[mua addObject: [NSDate dateWithTimeIntervalSinceNow: -24*60*60*ii]];
	}
	maDate = [NSArray arrayWithArray:mua];
	
	[mua removeAllObjects];
	for (int ii=0; ii<100; ii++) {
		NSInteger iVal = 110 + arc4random() % 30;
		[mua addObject: [NSNumber numberWithInteger: iVal]];
	}
	maBpHi = [NSArray arrayWithArray:mua];

	[mua removeAllObjects];
	for (int ii=0; ii<100; ii++) {
		NSInteger iVal = 65 + arc4random() % 40;
		[mua addObject: [NSNumber numberWithInteger: iVal]];
	}
	maBpLo = [NSArray arrayWithArray:mua];

	[mua removeAllObjects];
	for (int ii=0; ii<100; ii++) {
		NSInteger iVal = 55 + arc4random() % 40;
		[mua addObject: [NSNumber numberWithInteger: iVal]];
	}
	maPuls = [NSArray arrayWithArray:mua];

	[mua removeAllObjects];
	for (int ii=0; ii<100; ii++) {
		NSInteger iVal = 65 + arc4random() % 40;
		[mua addObject: [NSNumber numberWithInteger: iVal]];
	}
	maWeight = [NSArray arrayWithArray:mua];

	[mua removeAllObjects];
	for (int ii=0; ii<100; ii++) {
		NSInteger iVal = 350 + arc4random() % 30;
		[mua addObject: [NSNumber numberWithInteger: iVal]];
	}
	maTemp = [NSArray arrayWithArray:mua];
	
	[self graphDraw:cgc frame:self.bounds];
	
	return;

	
	
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 2.0);
	//カレントポイントから指定した座標に向けて線を引く
	CGContextStrokeEllipseInRect(cgc, CGRectMake(0.0, 0.0,100.0,100.0));
	//パスに円を追加
	CGContextAddEllipseInRect(cgc, CGRectMake(0.0, 0.0, 600.0, 600.0));
	//画面に描画
	CGContextStrokePath(cgc);
	
	//
	CGContextSetRGBStrokeColor(cgc, 1.0, 0.0, 0.0, 1.0);
	CGPoint lines[] =
	{
		CGPointMake(  0.0,   0.0),
		CGPointMake(70.0, 60.0),
		CGPointMake(130.0, 100.0),
		CGPointMake(190.0, 70.0),
		CGPointMake(250.0, 90.0),
		CGPointMake(310.0, 50.0)
	};
	CGContextAddLines(cgc, lines, (sizeof(lines)/sizeof(lines[0])));
	//画面に描画
	CGContextStrokePath(cgc);
	

	CGContextSetRGBFillColor(cgc, 1.0, 0.5, 0.0, 1.0);
    CGContextSetRGBStrokeColor(cgc, 1.0, 0.0, 0.5, 1.0);
    CGContextSetLineWidth(cgc, 10.0);
	
    CGRect r1 = CGRectMake(20.0 , 20.0, 100.0, 100.0);
    CGContextAddEllipseInRect(cgc,r1);
    CGContextFillPath(cgc);
	
    CGContextMoveToPoint(cgc, 50, 100);
    CGContextAddLineToPoint(cgc, 150, 100);
    CGContextAddLineToPoint(cgc, 50, 200);
    CGContextAddLineToPoint(cgc, 150, 200);
    CGContextStrokePath(cgc);
	
    CGContextMoveToPoint(cgc,50, 250);
    CGContextAddCurveToPoint(cgc, 
							 100, 250, 100, 200, 150, 250);
    CGContextAddCurveToPoint(cgc, 
							 200, 350, 50, 250, 50, 350);
    CGContextStrokePath(cgc);
}

@end

