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


@implementation GraphView
{
	IBOutlet UISegmentedControl	*ibSegType;

	BOOL			bDrowRect_;
}
@synthesize RaE2records = aE2records_;


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
	assert(count <= RECORD_LIMIT);
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
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
			cc = [[NSString stringWithString:NSLocalizedString(@"TheGoal",nil)] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+14, cc, strlen(cc));
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
			
			cc = [[NSString stringWithFormat:@"%02d:%02d", iHour, iMinute] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+8, cc, strlen(cc));
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
	//CGContextStrokePath(cgc);
	//CGContextFillPath(cgc); // パスを塗り潰す
}

- (void)graphDrawOne:(CGContextRef)cgc 
			   count:(int)count
			  points:(const CGPoint *)points  
			  values:(const long *)values  
			valueType:(int)valueType					// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
			pointLower:(CGFloat)pointLower		// Y座標の最小値： 数値文字がこれ以下に描画されるならば、上側に表示する
{
	assert(count <= RECORD_LIMIT);
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
		if (iNo==0) {	//[0]目標
			// 目標ヨコ軸
			CGContextSetRGBFillColor(cgc, 0.9, 0.9, 1, 0.2); // White
			CGContextAddRect(cgc, CGRectMake(MARGIN_WIDTH, po.y-6, po.x - MARGIN_WIDTH, 12));
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
	// Temp領域 (H:1/8)
	CGRect rcTemp = self.bounds;
	rcTemp.origin.y = 3.0 + SEPARATE_HEIGHT;	// Y開始
	rcTemp.size.height = fHeight *  1 / 8 - SEPARATE_HEIGHT;		// 高さ
	//lb = (UILabel*)[self.superview viewWithTag:ViewTAG_Temp];	// GraphVC:にあるラベルを配置する //NG//固定配置にした。
	//rc = lb.frame;	rc.origin.y = rcTemp.origin.y + rcTemp.size.height/2;		
	//lb.frame = rc;
	// Weight領域 (H:2/8)
	CGRect rcWeight = self.bounds;
	rcWeight.origin.y = rcTemp.origin.y + rcTemp.size.height + SEPARATE_HEIGHT;		// Y開始
	rcWeight.size.height = fHeight * 2 / 8 - SEPARATE_HEIGHT;		// 高さ
	// Puls領域  (H:1/8)
	CGRect rcPuls = self.bounds;
	rcPuls.origin.y = rcWeight.origin.y + rcWeight.size.height + SEPARATE_HEIGHT;		// Y開始
	rcPuls.size.height = fHeight * 1 / 8.0 - SEPARATE_HEIGHT;		// 高さ
	// BpHi,Lo領域  (H:3/8)
	CGRect rcBp = self.bounds;
	rcBp.origin.y = rcPuls.origin.y + rcPuls.size.height + SEPARATE_HEIGHT;				// Y開始
	rcBp.size.height = fHeight * 3 / 8 - SEPARATE_HEIGHT;				// 高さ
	// Date領域  (H:1/8)
	CGRect rcDate = self.bounds;
	rcDate.origin.y = rcBp.origin.y + rcBp.size.height + SEPARATE_HEIGHT;				// Y開始
	rcDate.size.height = fHeight * 1 / 8 - SEPARATE_HEIGHT;				// 高さ
/*	// 区切り線
	//CGContextSetRGBFillColor(cgc, 0.8, 0.8, 0.8, 0.3); // Gray
	CGContextSetRGBFillColor(cgc, 0.592, 0.313, 0.302, 0.3); //Azukid Color
	rc = CGRectMake(MARGIN_WIDTH, 0, self.bounds.size.width - MARGIN_WIDTH*2 + 20, SEPARATE_HEIGHT);
	rc.origin.y = rcWeight.origin.y - SEPARATE_HEIGHT;	CGContextAddRect(cgc, rc);
	rc.origin.y = rcPuls.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcBp.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcDate.origin.y - SEPARATE_HEIGHT;		CGContextAddRect(cgc, rc);
	//画面に描画
	CGContextFillPath(cgc); // パスを塗り潰す
*/
	// 右端の設定領域について
	rc = ibSegType.frame;
	rc.origin.x = self.bounds.size.width - MARGIN_WIDTH + 25;
	ibSegType.frame = rc;
	

	// E2record
	if ([aE2records_ count] < 1) {
		aE2records_ = nil;
		return;
	}
	//NSLog(@"aE2records_=%@", aE2records_);
	
	// Min, Max
	NSInteger iMaxBp = 0;
	NSInteger iMinBp = 999;
	NSInteger iMaxPuls = 0;
	NSInteger iMinPuls = 999;
	NSInteger iMaxWeight = 0;
	NSInteger iMinWeight = 9999;
	NSInteger iMaxTemp = 0;
	NSInteger iMinTemp = 999;
	NSInteger ii;
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
		
		if (e2.nWeight_10Kg) {
			ii = [e2.nWeight_10Kg integerValue];
			if (E2_nWeight_MIN<=ii && ii<=E2_nWeight_MAX) {
				if (ii < iMinWeight) iMinWeight = ii;	
				if (iMaxWeight < ii) iMaxWeight = ii;
			}
		}
		
		if (e2.nTemp_10c) {
			ii = [e2.nTemp_10c integerValue];
			if (E2_nTemp_MIN<=ii && ii<=E2_nTemp_MAX) {
				if (ii < iMinTemp) iMinTemp = ii;	
				if (iMaxTemp < ii) iMaxTemp = ii;
			}
		}
	}
	
	CGFloat fYstep;
	CGPoint po;
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.5);

	CGPoint	pointsArray[RECORD_LIMIT+1];
	long			valuesArray[RECORD_LIMIT+1];
	int			arrayNo;

	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	po.x = self.bounds.size.width - MARGIN_WIDTH; // 最新日の描画位置
	po.y = rcDate.origin.y + GRAPH_H_GAP;
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
		if (e2.dateTime) {
			pointsArray[ arrayNo ] = po;
			if ([e2.nYearMM integerValue]==E2_nYearMM_GOAL) {
				valuesArray[ arrayNo ] = 0; // The GOAL
			} else {
				NSDateComponents *comp = [calendar components:unitFlags fromDate:e2.dateTime];
				valuesArray[ arrayNo ] = comp.month * 1000000 + comp.day * 10000 + comp.hour * 100 + comp.minute;
			}
			//NSLog(@"valuesArray[ %d ]=%ld", arrayNo, valuesArray[ arrayNo ]);
			arrayNo++;
		}
		po.x -= RECORD_WIDTH;
		if (po.x <= 0) break;
	}
	[self graphDrawDate:cgc count:arrayNo points:pointsArray values:valuesArray];	
	
	//-------------------------------------------------------------------------------------- BpHi グラフ描画
	if (iMinBp==iMaxBp) {
		iMinBp--;
		iMaxBp++;
	}
	fYstep = (rcBp.size.height - GRAPH_H_GAP*2) / (iMaxBp - iMinBp);  // 1あたりのポイント数
	po.x = self.bounds.size.width - MARGIN_WIDTH; // 最新日の描画位置
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
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
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcBp.origin.y];
	
	//-------------------------------------------------------------------------------------- BpLo グラフ描画
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
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
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcBp.origin.y];
	
	//-------------------------------------------------------------------------------------- Puls グラフ描画
	if (iMinPuls==iMaxPuls) {
		iMinPuls--;
		iMaxPuls++;
	}
	fYstep = (rcPuls.size.height - GRAPH_H_GAP*2) / (iMaxPuls - iMinPuls);  // 1あたりのポイント数
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
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
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:0  pointLower:rcPuls.origin.y];

	//-------------------------------------------------------------------------------------- Weight グラフ描画
	if (iMinWeight==iMaxWeight) {
		iMinWeight--;
		iMaxWeight++;
	}
	fYstep = (rcWeight.size.height - GRAPH_H_GAP*2) / (iMaxWeight - iMinWeight);  // 1あたりのポイント数
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
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
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcWeight.origin.y];

	//-------------------------------------------------------------------------------------- Temp グラフ描画
	if (iMinTemp==iMaxTemp) {
		iMinTemp--;
		iMaxTemp++;
	}
	fYstep = (rcTemp.size.height - GRAPH_H_GAP*2) / (iMaxTemp - iMinTemp);  // 1あたりのポイント数
	po.x = self.bounds.size.width - 160;
	arrayNo = 0;
	for (E2record *e2 in aE2records_) {
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
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:1  pointLower:rcTemp.origin.y];

	//CGContextFlush(cgc);
}


// 親側から再描画させたいときには、setNeedsDisplay を使うこと。さもなくば、CGContextRefが正しく取得できない
- (void)drawRect:(CGRect)rect
{
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);
	//
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

