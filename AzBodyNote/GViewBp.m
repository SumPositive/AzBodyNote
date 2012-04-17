//
//  GViewBp.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "Global.h"
#import "MocEntity.h"
#import "GraphVC.h"
#import "GViewBp.h"

@implementation GViewBp
@synthesize ppE2records = __E2records;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)graphDraw:(CGContextRef)cgc 
			   count:(int)count
			  points:(const CGPoint *)points  
			  values:(const long *)values  
		   valueType:(int)valueType		// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.8); // 折れ線の色
#ifdef YES
	// 折れ線
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:GUD_bGoal]) {
		CGContextAddLines(cgc, points, count);	
	} else {
		// Goalを結ばない  [0]を除き[1]から描画する
		CGContextAddLines(cgc, &points[1], count-1);	
	}
#else
	// スプライン曲線
#endif
	CGContextStrokePath(cgc);
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);	// 文字の色
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0); // Black
	// 記録プロット
	for (int iNo=0; iNo < count; iNo++) 
	{
		CGPoint po = points[ iNo ];
		if (iNo==0) {	//[0]Goal! 目標
			//---------------------------------------------Goal! 目標ヨコ軸
			CGContextSetRGBFillColor(cgc, 0.9, 0.9, 1, 0.2); // White
			CGContextAddRect(cgc, CGRectMake(RECORD_WIDTH/2, po.y-6, po.x-RECORD_WIDTH/2, 12));
			CGContextFillPath(cgc); // パスを塗り潰す
			CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
		}
		// 端点
		CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
		// 数値
		const char *cc;
		switch (valueType) {
			case 1:	// Temp(999⇒99.9℃)  // Weight(9999⇒999.9Kg)
				cc = [[NSString stringWithFormat:@"%0.1f", (float)values[ iNo ] / 10.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
			default:
				cc = [[NSString stringWithFormat:@"%ld", values[ iNo ]] UTF8String];
				//cc = [[NSString stringWithFormat:@"%ld", values[ iNo ]] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
		}
		if (po.y-13 <= 0) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-10, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-10, po.y-13, cc, strlen(cc));
		}
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// E2record
	if ([__E2records count] < 1) {
		return;
	}
	//NSLog(@"__E2records=%@", __E2records);
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	NSInteger iGoalBpHi		= [[kvs objectForKey:Goal_nBpHi_mmHg] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	NSInteger iGoalBpLo		= [[kvs objectForKey:Goal_nBpLo_mmHg] integerValue];
	NSInteger iMaxBp			= 0;
	NSInteger iMinBp				= 999;
	if (E2_nBpHi_MIN<=iGoalBpHi			&& iGoalBpHi<=E2_nBpHi_MAX)			iMaxBp = iGoalBpHi;
	if (E2_nBpLo_MIN<=iGoalBpLo			&& iGoalBpLo<=E2_nBpLo_MAX)			iMinBp = iGoalBpLo;

	NSInteger ii;
	for (E2record *e2 in __E2records) {
		if (e2.nBpHi_mmHg) {
			ii = [e2.nBpHi_mmHg integerValue];
			if (E2_nBpHi_MIN<=ii && ii<=E2_nBpHi_MAX) {
				if (ii < iMinBp) iMinBp = ii;	//NG// else if (iMaxBp < ii) iMaxBp = ii; 1件だけのとき不具合
				if (iMaxBp < ii) iMaxBp = ii;
			}
		}

		if (e2.nBpLo_mmHg) {
			ii = [e2.nBpLo_mmHg integerValue];
			if (E2_nBpLo_MIN<=ii && ii<=E2_nBpLo_MAX) {
				if (ii < iMinBp) iMinBp = ii;	
				if (iMaxBp < ii) iMaxBp = ii;
			}
		}
	}

	// 描画開始
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, self.bounds);
	
	CGFloat fYstep;
	CGPoint po;
	CGPoint	pointsArray[GRAPH_PAGE_LIMIT+20+1];
	long			valuesArray[GRAPH_PAGE_LIMIT+20+1];
	int			arrayNo;
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	
	//-------------------------------------------------------------------------------------- BpHi グラフ描画
	if (iMinBp==iMaxBp) {
		iMinBp--;
		iMaxBp++;
	}
	fYstep = (rect.size.height - GRAPH_H_GAP*2) / (iMaxBp - iMinBp);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoalBpHi - iMinBp);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBpHi;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in __E2records) {
		if (po.x <= 0) break;
		if (e2.nBpHi_mmHg) {
			ii = [e2.nBpHi_mmHg integerValue];
			if (E2_nBpHi_MIN<=ii && ii<=E2_nBpHi_MAX) {
				po.y = GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDraw:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0];
	
	//-------------------------------------------------------------------------------------- BpLo グラフ描画
	po.x = fXgoal;
	po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoalBpLo - iMinBp);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBpLo;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in __E2records) {
		if (po.x <= 0) break;
		if (e2.nBpLo_mmHg) {
			ii = [e2.nBpLo_mmHg integerValue];
			if (E2_nBpLo_MIN<=ii && ii<=E2_nBpLo_MAX) {
				po.y = GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDraw:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0];
}


@end