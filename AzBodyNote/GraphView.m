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
#import "AppDelegate.h"
#import "MocEntity.h"
#import "MocFunctions.h"


@implementation GraphView
{
	IBOutlet UISegmentedControl	*ibSegType;

	BOOL			bDrowRect_;
}
@synthesize RaE2records = aE2records_;
//@synthesize iOverLeft = iOverLeft_;
//@synthesize iOverRight = iOverRight_;


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

- (void)graphDrawDate:(CGContextRef)cgc 
				count:(int)count
			   points:(const CGPoint *)points  
			   values:(const long *)values		//= month*1000000 + day*10000 + hour*100 + minute  //=0:The GOAL
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman); // ＜＜日本語NG
	//CGRect rc;
	for (int iNo=0; iNo < count; iNo++) 
	{
		CGPoint po = points[ iNo ];
		// 数値
		long val = values[ iNo ];
		//NSLog(@"graphDrawDate: [ %d ]=%ld=(%.2f, %.2f)", iNo, val, po.x, po.y);
		// 文字列 カラー設定(0.0-1.0でRGBAを指定する)
		CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
		CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
		const char *cc;
		if (val < 1000000) {
			//cc = [[NSString stringWithString:NSLocalizedString(@"TheGoal",nil)] UTF8String]; ＜＜日本語NG
			cc = [[NSString stringWithString:@"GOAL"] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+14, cc, strlen(cc)); //P.1
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+14+self.bounds.size.height, cc, strlen(cc)); //P.2
		}
		else {
			int iMonth = val / 1000000;
			val -= iMonth * 1000000;
			int iDay = val / 10000;
			val -= iDay * 10000;
			int iHour = val / 100;
			val -= iHour * 100;
			int iMinute = val;
			
			cc = [[NSString stringWithFormat:@"%d/%d", iMonth, iDay] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+20, cc, strlen(cc));
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+20+self.bounds.size.height, cc, strlen(cc));
			
			cc = [[NSString stringWithFormat:@"%02d:%02d", iHour, iMinute] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+8, cc, strlen(cc));
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+8+self.bounds.size.height, cc, strlen(cc));
		}

#ifdef xxxNONxxxx
		// タテ軸　カラー設定
		CGContextSetRGBFillColor(cgc, 0.5, 0.5, 0.5, 0.3);
		rc = CGRectMake(po.x-1, 0, 2, po.y+3);
		CGContextAddRect(cgc, rc);
		//画面に描画
		CGContextFillPath(cgc); // パスを塗り潰す
#endif
	}
}

- (void)graphDrawOne:(CGContextRef)cgc 
			   count:(int)count
			  points:(const CGPoint *)points  
			  values:(const long *)values  
			valueType:(int)valueType					// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
			pointLower:(CGFloat)pointLower		// Y座標の最小値： 数値文字がこれ以下に描画されるならば、上側に表示する
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.8); // 折れ線の色
#ifdef YES
	// 折れ線
	CGContextAddLines(cgc, points, count);	
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
		if (po.y-13 <= pointLower) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-10, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-10, po.y-13, cc, strlen(cc));
		}
	}
	//CGContextStrokePath(cgc);
	//CGContextFillPath(cgc); // パスを塗り潰す
}

- (void)graphDraw:(CGContextRef)cgc
{
	NSLog(@"graphDraw: frame=(%f, %f)-(%f, %f) ", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, self.bounds);
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.2);

	//--------------------------------------------------------------------------------------- 背景を描く
	CGFloat fHeight = self.bounds.size.height - 3 - 15;  // 上下の余白を除いた有効な高さ
	CGRect rc;
	
	//P.1
	// Temp領域 (H:2/8)
	CGRect rcTemp = self.bounds;
	rcTemp.origin.y = 3.0 + SEPARATE_HEIGHT;	// Y開始
	rcTemp.size.height = fHeight *  2/8 - SEPARATE_HEIGHT;		// 高さ
	// Puls領域  (H:2/8)
	CGRect rcPuls = self.bounds;
	rcPuls.origin.y = rcTemp.origin.y + rcTemp.size.height + SEPARATE_HEIGHT;		// Y開始
	rcPuls.size.height = fHeight * 2/8 - SEPARATE_HEIGHT;		// 高さ
	// BpHi,Lo領域  (H:3/8)
	CGRect rcBp = self.bounds;
	rcBp.origin.y = rcPuls.origin.y + rcPuls.size.height + SEPARATE_HEIGHT;				// Y開始
	rcBp.size.height = fHeight * 3/8 - SEPARATE_HEIGHT;				// 高さ
	// Date領域  (H:1/8)
	CGRect rcDate = self.bounds;
	rcDate.origin.y = rcBp.origin.y + rcBp.size.height + SEPARATE_HEIGHT;				// Y開始
	rcDate.size.height = fHeight * 1/8 - SEPARATE_HEIGHT;				// 高さ

	//P.2
	// SkMuscle領域 (H:1.5/8)
	CGRect rcSkMuscle = self.bounds;
	rcSkMuscle.origin.y = 3.0 + SEPARATE_HEIGHT - self.bounds.size.height;	// Y開始
	rcSkMuscle.size.height = fHeight *  1.5/8 - SEPARATE_HEIGHT;		// 高さ
	// BodyFat領域  (H:1.5/8)
	CGRect rcBodyFat = self.bounds;
	rcBodyFat.origin.y = rcSkMuscle.origin.y + rcSkMuscle.size.height + SEPARATE_HEIGHT;		// Y開始
	rcBodyFat.size.height = fHeight * 1.5/8 - SEPARATE_HEIGHT;		// 高さ
	// Pedometer領域  (H:1.5/8)
	CGRect rcPedometer = self.bounds;
	rcPedometer.origin.y = rcBodyFat.origin.y + rcBodyFat.size.height + SEPARATE_HEIGHT;		// Y開始
	rcPedometer.size.height = fHeight * 1.5/8 - SEPARATE_HEIGHT;		// 高さ
	// Weight領域 (H:1.9/8)
	CGRect rcWeight = self.bounds;
	rcWeight.origin.y = rcPedometer.origin.y + rcPedometer.size.height + SEPARATE_HEIGHT;		// Y開始
	rcWeight.size.height = fHeight * 1.9/8 - SEPARATE_HEIGHT;		// 高さ
	// Date2領域  (H:1/8)
	//CGRect rcDate2 = self.bounds;
	//rcDate2.origin.y = rcWeight.origin.y + rcWeight.size.height + SEPARATE_HEIGHT;				// Y開始
	//rcDate2.size.height = fHeight * 1/8 - SEPARATE_HEIGHT;				// 高さ
	
	// 区切り線
	//CGContextSetRGBFillColor(cgc, 0.8, 0.8, 0.8, 0.3); // Gray
	//CGContextSetRGBFillColor(cgc, 0.592, 0.313, 0.302, 0.3); //Azukid Color
	CGContextSetRGBFillColor(cgc, 1, 1, 1, 0.3); //White
	//P.1
	rc = CGRectMake(0, 0, self.bounds.size.width, SEPARATE_HEIGHT);	// self.bounds=正味グラフ描画領域
	rc.origin.y = rcWeight.origin.y - SEPARATE_HEIGHT;	CGContextAddRect(cgc, rc);
	rc.origin.y = rcPuls.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcBp.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcDate.origin.y - SEPARATE_HEIGHT;		CGContextAddRect(cgc, rc);
	//P.2
	rc.origin.y = rcSkMuscle.origin.y - SEPARATE_HEIGHT;	CGContextAddRect(cgc, rc);
	rc.origin.y = rcBodyFat.origin.y - SEPARATE_HEIGHT;		CGContextAddRect(cgc, rc);
	rc.origin.y = rcPedometer.origin.y - SEPARATE_HEIGHT;	CGContextAddRect(cgc, rc);
	rc.origin.y = rcWeight.origin.y - SEPARATE_HEIGHT;		CGContextAddRect(cgc, rc);
	//rc.origin.y = rcDate2.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	
	//画面に描画
	CGContextFillPath(cgc); // パスを塗り潰す

	// 右端の設定領域について
	//rc = ibSegType.frame;
	//rc.origin.x = self.bounds.size.width - MARGIN_WIDTH + 25;
	//ibSegType.frame = rc;
	

	// E2record
	if ([aE2records_ count] < 1) {
		aE2records_ = nil;
		return;
	}
	//NSLog(@"aE2records_=%@", aE2records_);
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	NSInteger iGoalBpHi		= [[kvs objectForKey:Goal_nBpHi_mmHg] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	NSInteger iGoalBpLo		= [[kvs objectForKey:Goal_nBpLo_mmHg] integerValue];
	NSInteger iGoalPuls			= [[kvs objectForKey:Goal_nPulse_bpm] integerValue];
	NSInteger iGoalTemp		= [[kvs objectForKey:Goal_nTemp_10c] integerValue];
	NSInteger iGoalWeight	= [[kvs objectForKey:Goal_nWeight_10Kg] integerValue];
	NSInteger iGoalPedo		= [[kvs objectForKey:Goal_nPedometer] integerValue];
	NSInteger iGoalBodyFat	= [[kvs objectForKey:Goal_nBodyFat_10p] integerValue];
	NSInteger iGoalSkMusc	= [[kvs objectForKey:Goal_nSkMuscle_10p] integerValue];

	// Min, Max
	NSInteger iMaxBp			= 0;
	NSInteger iMinBp				= 999;
	NSInteger iMaxPuls			= 0;
	NSInteger iMinPuls			= 999;
	NSInteger iMaxTemp		= 0;
	NSInteger iMinTemp		= 999;
	NSInteger iMaxWeight	= 0;
	NSInteger iMinWeight		= 9999;
	NSInteger iMaxPedo		= 0;
	NSInteger iMinPedo			= 9999;
	NSInteger iMaxBodyFat	= 0;
	NSInteger iMinBodyFat	= 9999;
	NSInteger iMaxSkMusc	= 0;
	NSInteger iMinSkMusc	= 9999;
	NSInteger ii;
	
	if (E2_nBpHi_MIN<=iGoalBpHi			&& iGoalBpHi<=E2_nBpHi_MAX)			iMaxBp = iGoalBpHi;
	if (E2_nBpLo_MIN<=iGoalBpLo			&& iGoalBpLo<=E2_nBpLo_MAX)			iMinBp = iGoalBpLo;
	if (E2_nPuls_MIN<=iGoalPuls				&& iGoalPuls<=E2_nPuls_MAX)				iMaxPuls = iGoalPuls,			iMinPuls = iGoalPuls;
	if (E2_nTemp_MIN<=iGoalTemp		&& iGoalTemp<=E2_nTemp_MAX)		iMaxTemp = iGoalTemp,		iMinTemp = iGoalTemp;
	if (E2_nWeight_MIN<=iGoalWeight		&& iGoalWeight<=E2_nWeight_MAX)	iMaxWeight = iGoalWeight, iMinWeight = iGoalWeight;
	if (E2_nPedometer_MIN<=iGoalPedo		&& iGoalPuls<=E2_nPedometer_MAX)	iMaxPedo = iGoalPedo,	iMinPedo = iGoalPedo;
	if (E2_nBodyFat_MIN<=iGoalBodyFat	&& iGoalPuls<=E2_nBodyFat_MAX)		iMaxBodyFat = iGoalBodyFat,	 iMinBodyFat = iGoalBodyFat;
	if (E2_nSkMuscle_MIN<=iGoalSkMusc	&& iGoalPuls<=E2_nSkMuscle_MAX)		iMaxSkMusc = iGoalSkMusc,	iMinSkMusc = iGoalSkMusc;
		
	for (E2record *e2 in aE2records_)
	{	// 最新日から過去へ遡る
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
		
		if (e2.nPulse_bpm) {
			ii = [e2.nPulse_bpm integerValue];
			if (E2_nPuls_MIN<=ii && ii<=E2_nPuls_MAX) {
				if (ii < iMinPuls) iMinPuls = ii;	
				if (iMaxPuls < ii) iMaxPuls = ii;
			}
		}
		
		if (e2.nTemp_10c) {
			ii = [e2.nTemp_10c integerValue];
			if (E2_nTemp_MIN<=ii && ii<=E2_nTemp_MAX) {
				if (ii < iMinTemp) iMinTemp = ii;	
				if (iMaxTemp < ii) iMaxTemp = ii;
			}
		}
		
		if (e2.nWeight_10Kg) {
			ii = [e2.nWeight_10Kg integerValue];
			if (E2_nWeight_MIN<=ii && ii<=E2_nWeight_MAX) {
				if (ii < iMinWeight) iMinWeight = ii;	
				if (iMaxWeight < ii) iMaxWeight = ii;
			}
		}
		
		if (e2.nPedometer) {
			ii = [e2.nPedometer integerValue];
			if (E2_nPedometer_MIN<=ii && ii<=E2_nPedometer_MAX) {
				if (ii < iMinPedo) iMinPedo = ii;	
				if (iMaxPedo < ii) iMaxPedo = ii;
			}
		}
		
		if (e2.nBodyFat_10p) {
			ii = [e2.nBodyFat_10p integerValue];
			if (E2_nBodyFat_MIN<=ii && ii<=E2_nBodyFat_MAX) {
				if (ii < iMinBodyFat) iMinBodyFat = ii;	
				if (iMaxBodyFat < ii) iMaxBodyFat = ii;
			}
		}
		
		if (e2.nSkMuscle_10p) {
			ii = [e2.nSkMuscle_10p integerValue];
			if (E2_nSkMuscle_MIN<=ii && ii<=E2_nSkMuscle_MAX) {
				if (ii < iMinSkMusc) iMinSkMusc = ii;	
				if (iMaxSkMusc < ii) iMaxSkMusc = ii;
			}
		}
	}
	
	CGFloat fYstep;
	CGPoint po;
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.5);

	CGPoint	pointsArray[GRAPH_PAGE_LIMIT+20+1];
	long			valuesArray[GRAPH_PAGE_LIMIT+20+1];
	int			arrayNo;
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する

	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	po.x = fXgoal;
	po.y = rcDate.origin.y + GRAPH_H_GAP;
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = 0;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.dateTime) {
			pointsArray[ arrayNo ] = po;
			NSDateComponents *comp = [calendar components:unitFlags fromDate:e2.dateTime];
			valuesArray[ arrayNo ] = comp.month * 1000000 + comp.day * 10000 + comp.hour * 100 + comp.minute;
			//NSLog(@"valuesArray[ %d ]=%ld", arrayNo, valuesArray[ arrayNo ]);
			arrayNo++;
			assert(arrayNo < GRAPH_PAGE_LIMIT+20+1);
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawDate:cgc count:arrayNo points:pointsArray values:valuesArray];	
	
	//-------------------------------------------------------------------------------------- BpHi グラフ描画
	if (iMinBp==iMaxBp) {
		iMinBp--;
		iMaxBp++;
	}
	fYstep = (rcBp.size.height - GRAPH_H_GAP*2) / (iMaxBp - iMinBp);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcBp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalBpHi - iMinBp);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBpHi;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nBpHi_mmHg) {
			ii = [e2.nBpHi_mmHg integerValue];
			if (E2_nBpHi_MIN<=ii && ii<=E2_nBpHi_MAX) {
				po.y = rcBp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcBp.origin.y];
	
	//-------------------------------------------------------------------------------------- BpLo グラフ描画
	po.x = fXgoal;
	po.y = rcBp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalBpLo - iMinBp);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBpLo;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nBpLo_mmHg) {
			ii = [e2.nBpLo_mmHg integerValue];
			if (E2_nBpLo_MIN<=ii && ii<=E2_nBpLo_MAX) {
				po.y = rcBp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinBp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcBp.origin.y];
	
	//-------------------------------------------------------------------------------------- Puls グラフ描画
	if (iMinPuls==iMaxPuls) {
		iMinPuls--;
		iMaxPuls++;
	}
	fYstep = (rcPuls.size.height - GRAPH_H_GAP*2) / (iMaxPuls - iMinPuls);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcPuls.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalPuls - iMinPuls);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalPuls;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nPulse_bpm) {
			ii = [e2.nPulse_bpm integerValue];
			if (E2_nPuls_MIN<=ii && ii<=E2_nPuls_MAX) {
				po.y = rcPuls.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinPuls);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcPuls.origin.y];

	//-------------------------------------------------------------------------------------- Temp グラフ描画
	if (iMinTemp==iMaxTemp) {
		iMinTemp--;
		iMaxTemp++;
	}
	fYstep = (rcTemp.size.height - GRAPH_H_GAP*2) / (iMaxTemp - iMinTemp);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcTemp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalTemp - iMinTemp);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalTemp;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nTemp_10c) {
			ii = [e2.nTemp_10c integerValue];
			if (E2_nTemp_MIN<=ii && ii<=E2_nTemp_MAX) {
				po.y = rcTemp.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinTemp);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcTemp.origin.y];

	//-------------------------------------------------------------------------------------- Weight グラフ描画
	if (iMinWeight==iMaxWeight) {
		iMinWeight--;
		iMaxWeight++;
	}
	fYstep = (rcWeight.size.height - GRAPH_H_GAP*2) / (iMaxWeight - iMinWeight);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcWeight.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalWeight - iMinWeight);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalWeight;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nWeight_10Kg) {
			ii = [e2.nWeight_10Kg integerValue];
			if (E2_nWeight_MIN<=ii && ii<=E2_nWeight_MAX) {
				po.y = rcWeight.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinWeight);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcWeight.origin.y];

	//-------------------------------------------------------------------------------------- Pedometer グラフ描画
	if (iMinPedo==iMaxPedo) {
		iMinPedo--;
		iMaxPedo++;
	}
	fYstep = (rcPedometer.size.height - GRAPH_H_GAP*2) / (iMaxPedo - iMinPedo);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcPedometer.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalPedo - iMinPedo);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBodyFat;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nPedometer) {
			ii = [e2.nPedometer integerValue];
			if (E2_nPedometer_MIN<=ii && ii<=E2_nPedometer_MAX) {
				po.y = rcPedometer.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinPedo);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcPedometer.origin.y];

	//-------------------------------------------------------------------------------------- BodyFat グラフ描画
	if (iMinBodyFat==iMaxBodyFat) {
		iMinBodyFat--;
		iMaxBodyFat++;
	}
	fYstep = (rcBodyFat.size.height - GRAPH_H_GAP*2) / (iMaxBodyFat - iMinBodyFat);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcBodyFat.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalBodyFat - iMinBodyFat);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalBodyFat;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nBodyFat_10p) {
			ii = [e2.nBodyFat_10p integerValue];
			if (E2_nBodyFat_MIN<=ii && ii<=E2_nBodyFat_MAX) {
				po.y = rcBodyFat.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinBodyFat);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcBodyFat.origin.y];

	//-------------------------------------------------------------------------------------- SkMuscle グラフ描画
	if (iMinSkMusc==iMaxSkMusc) {
		iMinSkMusc--;
		iMaxSkMusc++;
	}
	fYstep = (rcSkMuscle.size.height - GRAPH_H_GAP*2) / (iMaxSkMusc - iMinSkMusc);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = rcSkMuscle.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(iGoalSkMusc - iMinSkMusc);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoalSkMusc;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in aE2records_) {
		if (po.x <= 0) break;
		if (e2.nSkMuscle_10p) {
			ii = [e2.nSkMuscle_10p integerValue];
			if (E2_nSkMuscle_MIN<=ii && ii<=E2_nSkMuscle_MAX) {
				po.y = rcSkMuscle.origin.y + GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMinSkMusc);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcSkMuscle.origin.y];

	//CGContextFlush(cgc);
}


// 親側から再描画させたいときには、setNeedsDisplay を使うこと。さもなくば、CGContextRefが正しく取得できない
- (void)drawRect:(CGRect)rect
{
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);
	
	/*NG* 縮小されてしまう不具合あり
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // 非同期処理
		[self graphDraw:cgc];
	});
	 */
	[self graphDraw:cgc];
}


#pragma mark - IBAction

- (IBAction)ibSegTypeChange:(UISegmentedControl *)seg
{
	self.alpha = 0;
	// アニメ準備
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:2.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(hide_after_dissmiss)]; //アニメーション終了後に呼び出す＜＜setAnimationDelegate必要
	// アニメ終了状態
	[self drawRect:self.frame];		// タイプを変えて再描画
	self.alpha = 1;
	// アニメ実行
	[UIView commitAnimations];

}

@end

