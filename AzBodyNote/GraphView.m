//
//  GraphView.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/17.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

//#include <stdlib.h>			// arc4random()
#include <string.h>		// memcpy()
#import "Global.h"
#import "GraphVC.h"
#import "GraphView.h"
#import "AzBodyNoteAppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"

#define GRAPH_MAX		100
#define W_HOUR		2.0		// 1時間分の横ポイント数
#define H_GAP			2.0		// グラフの最大および最小の余白ポイント数


@implementation GraphView
{
	//NSArray *maDate;
	//NSArray *maBpHi;
	//NSArray *maBpLo;
	//NSArray *maPuls;
	//NSArray *maWeight;
	//NSArray *maTemp;
	
	BOOL			bDrowRect_;
	NSArray		*aE2records_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		bDrowRect_ = NO;
    }
    return self;
}


// X軸: 1dot = 1Hour
// Y軸: 1dot

- (void)graphDrawOne:(CGContextRef)cgc 
			   count:(int)count
			  points:(const CGPoint *)points  
			  values:(const long *)values  
			valueDec:(int)valueDec
			pointLower:(CGFloat)pointLower		// Y座標の最小値： 数値文字がこれ以下に描画されるならば、上側に表示する
{
	assert(count <= GRAPH_MAX);
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 1.0);
#ifdef YES
	// 折れ線
	CGContextAddLines(cgc, points, count);	
#else
	// スプライン曲線
#endif
	CGContextStrokePath(cgc);
	
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
	for (int iNo=0; iNo < count; iNo++) {
		// 端点
		CGPoint po = points[ iNo ];
		CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
		// 数値
		const char *cc;
		switch (valueDec) {
			case 2:
				cc = [[NSString stringWithFormat:@"%0.2f", (float)values[ iNo ] / 100.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
			case 1:
				cc = [[NSString stringWithFormat:@"%0.1f", (float)values[ iNo ] / 10.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
			default:
				cc = [[NSString stringWithFormat:@"%ld", values[ iNo ]] UTF8String];
				//cc = [[NSString stringWithFormat:@"%ld", values[ iNo ]] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
		}
		if (po.y-13 <= pointLower) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-5, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-5, po.y-13, cc, strlen(cc));
		}
	}
	CGContextStrokePath(cgc);
}

- (void)graphDraw:(CGContextRef)cgc
{
	NSLog(@"graphDraw: frame=(%f, %f)-(%f, %f) ", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.2);
	
	CGFloat fHeight = self.bounds.size.height - 3 - 15;  // 上下の余白を除いた有効な高さ
	// Temp領域 (H:1/8)
	CGRect rcTemp = self.bounds;
	rcTemp.origin.y = 3.0;													// Y開始
	rcTemp.size.height = fHeight / 8.0;				// 高さ
	CGContextSetRGBFillColor(cgc, 0.0, 0.6, 0.6, 1.0);
	CGContextAddRect(cgc, rcTemp);
	CGContextFillPath(cgc);
	
	// Weight領域 (H:1/4)
	CGRect rcWeight = self.bounds;
	rcWeight.origin.y = rcTemp.origin.y + rcTemp.size.height;		// Y開始
	rcWeight.size.height = fHeight / 4.0;						// 高さ
	CGContextSetRGBFillColor(cgc, 0.6, 0.0, 0.6, 1.0);
	CGContextAddRect(cgc, rcWeight);
	CGContextFillPath(cgc);

	// Puls領域  (H:1/8)
	CGRect rcPuls = self.bounds;
	rcPuls.origin.y = rcWeight.origin.y + rcWeight.size.height;		// Y開始
	rcPuls.size.height = fHeight / 8.0;							// 高さ
	CGContextSetRGBFillColor(cgc, 0.6, 0.6, 0.0, 1.0);
	CGContextAddRect(cgc, rcPuls);
	CGContextFillPath(cgc);
	
	// BpHi,Lo領域  (H:1/2)
	CGRect rcBp = self.bounds;
	rcBp.origin.y = rcPuls.origin.y + rcPuls.size.height;				// Y開始
	rcBp.size.height = fHeight / 2.0;							// 高さ
	CGContextSetRGBFillColor(cgc, 0.6, 0.6, 0.6, 1.0);
	CGContextAddRect(cgc, rcBp);
	CGContextFillPath(cgc);

	//画面に描画
	CGContextStrokePath(cgc);


	aE2records_ = nil; 
	// Sort条件
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
	NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
	
	aE2records_ = [MocFunctions select: @"E2record"
								 limit: GRAPH_MAX
								offset: 0
								 where: nil
								  sort: sortDesc]; // 最新日付から抽出
	
	if ([aE2records_ count] < 1) {
		aE2records_ = nil;
		return;
	}
	
	// Min, Max
	NSInteger iMaxBp = 0;
	NSInteger iMinBp = 999;
	NSInteger iMaxPuls = 0;
	NSInteger iMinPuls = 999;
	NSInteger iMaxWeight = 0;
	NSInteger iMinWeight = 999;
	NSInteger iMaxTemp = 0;
	NSInteger iMinTemp = 999;
	NSInteger ii;
	for (E2record *e2 in aE2records_)
	{	// 最新日から過去へ遡る
		if (e2.nBpHi_mmHg) {
			ii = [e2.nBpHi_mmHg integerValue];
			if (E2_nBpHi_MIN<=ii && ii<=E2_nBpHi_MAX) {
				if (ii < iMinBp) iMinBp = ii;	else if (iMaxBp < ii) iMaxBp = ii;
			}
		}

		if (e2.nBpLo_mmHg) {
			ii = [e2.nBpLo_mmHg integerValue];
			if (E2_nBpLo_MIN<=ii && ii<=E2_nBpLo_MAX) {
				if (ii < iMinBp) iMinBp = ii;	else if (iMaxBp < ii) iMaxBp = ii;
			}
		}
		
		if (e2.nPulse_bpm) {
			ii = [e2.nPulse_bpm integerValue];
			if (E2_nPuls_MIN<=ii && ii<=E2_nPuls_MAX) {
				if (ii < iMinPuls) iMinPuls = ii;	else if (iMaxPuls < ii) iMaxPuls = ii;
			}
		}
		
		if (e2.nWeight_g) {
			ii = [e2.nWeight_g integerValue];
			if (E2_nWeight_MIN<=ii && ii<=E2_nWeight_MAX) {
				if (ii < iMinWeight) iMinWeight = ii;	else if (iMaxWeight < ii) iMaxWeight = ii;
			}
		}
		
		if (e2.nTemp_10c) {
			ii = [e2.nTemp_10c integerValue];
			if (E2_nTemp_MIN<=ii && ii<=E2_nTemp_MAX) {
				if (ii < iMinTemp) iMinTemp = ii;	else if (iMaxTemp < ii) iMaxTemp = ii;
			}
		}
	}
	
	CGFloat fYstep;
	CGPoint po;
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.5);
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);

	CGPoint	pointsArray[GRAPH_MAX+1];
	long			valuesArray[GRAPH_MAX+1];
	int			arrayNo;

	//-------------------------------------------------------------------------------------- BpHi グラフ描画
	// 端点、数値　ストロークカラー設定(0.0-1.0でRGBAを指定する)
	//CGContextSetRGBStrokeColor(cgc, 1, 1, 0, 1.0);
	//CGContextSetRGBFillColor (cgc, 1, 1, 0, 1.0);
	fYstep = rcBp.size.height / (iMaxBp - iMinBp + H_GAP*2);  // 1あたりのポイント数
	po.x = self.bounds.size.width - 160; // 最新日の描画位置
	arrayNo = 0;
	for (E2record *e2 in aE2records_)
	{
		if (e2.nBpHi_mmHg) {
			ii = [e2.nBpHi_mmHg integerValue];
			if (E2_nBpHi_MIN<=ii && ii<=E2_nBpHi_MAX) {
				po.y = rcBp.origin.y + H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
				// 端点
				//CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
				// 数値
				//const char *c = [[NSString stringWithFormat:@"%d", ii] UTF8String];
				//CGContextShowTextAtPoint (cgc, po.x-10, po.y-13, c, sizeof(c)-1);
			}
		}
		po.x -= (W_HOUR * 24);
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueDec:0  pointLower:rcBp.origin.y];
	//CGContextStrokePath(cgc);
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	//CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
	//CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
#ifdef YES
	// 折れ線
	//CGContextAddLines(cgc, pointsArray, pointNo);	
#else
	// スプライン曲線
#endif
	//CGContextStrokePath(cgc);
	
	//-------------------------------------------------------------------------------------- BpLo グラフ描画
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_)
	{
		if (e2.nBpLo_mmHg) {
			ii = [e2.nBpLo_mmHg integerValue];
			if (E2_nBpLo_MIN<=ii && ii<=E2_nBpLo_MAX) {
				po.y = rcBp.origin.y + H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= (W_HOUR * 24);
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueDec:0  pointLower:rcBp.origin.y];
	
	//-------------------------------------------------------------------------------------- Puls グラフ描画
	fYstep = rcPuls.size.height / (iMaxPuls - iMinPuls + H_GAP*2);  // 1あたりのポイント数
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_)
	{
		if (e2.nPulse_bpm) {
			ii = [e2.nPulse_bpm integerValue];
			if (E2_nPuls_MIN<=ii && ii<=E2_nPuls_MAX) {
				po.y = rcPuls.origin.y + H_GAP + fYstep * (CGFloat)(ii - iMinPuls);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= (W_HOUR * 24);
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueDec:0  pointLower:rcPuls.origin.y];

	// Weight グラフ描画

	// Temp グラフ描画

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	if (bDrowRect_) {	// 初期化時に通さないため
		//現在のグラフィックスコンテキストを取得
		CGContextRef cgc = UIGraphicsGetCurrentContext();
		// CoreGraphicsの原点が左下なので原点を合わせる
		CGContextTranslateCTM(cgc, 0, rect.size.height);
		CGContextScaleCTM(cgc, 1.0, -1.0);
		
		[self graphDraw:cgc];
	}
	bDrowRect_ = YES;
}


#ifdef xxxxxxxxxSampleCodexxxxxxxxx
{
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
#endif

@end

