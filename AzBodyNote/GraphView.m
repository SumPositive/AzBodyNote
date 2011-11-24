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
	IBOutlet UISegmentedControl	*ibSegType;

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

- (void)graphDrawDate:(CGContextRef)cgc 
				count:(int)count
			   points:(const CGPoint *)points  
			   values:(const long *)values		//= month*1000000 + day*10000 + hour*100 + minute
{
	assert(count <= GRAPH_MAX);
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
	for (int iNo=0; iNo < count; iNo++) 
	{
		CGPoint po = points[ iNo ];
		// 数値
		long val = values[ iNo ];
		int iMonth = val / 1000000;
		val -= iMonth * 1000000;
		int iDay = val / 10000;
		val -= iDay * 10000;
		int iHour = val / 100;
		val -= iHour * 100;
		int iMinute = val;

		const char *cc;
		cc = [[NSString stringWithFormat:@"%d/%d", iMonth, iDay] UTF8String];
		CGContextShowTextAtPoint (cgc, po.x-15, po.y+20, cc, strlen(cc));

		cc = [[NSString stringWithFormat:@"%02d:%02d", iHour, iMinute] UTF8String];
		CGContextShowTextAtPoint (cgc, po.x-15, po.y+8, cc, strlen(cc));
	}
	//CGContextStrokePath(cgc);
	//CGContextFillPath(cgc); // パスを塗り潰す
}

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
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
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
	//CGContextStrokePath(cgc);
	//CGContextFillPath(cgc); // パスを塗り潰す
}

#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ
#define WIDTH_OFFSET			160		// 右端の余白（ラベルや設定ボタンを設置する）
- (void)graphDraw:(CGContextRef)cgc
{
	NSLog(@"graphDraw: frame=(%f, %f)-(%f, %f) ", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	
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
	// 区切り線
	CGContextSetRGBFillColor(cgc, 0.8, 0.8, 0.8, 0.4);
	rc = CGRectMake(0, 0, self.bounds.size.width - WIDTH_OFFSET + 20, SEPARATE_HEIGHT);
	rc.origin.y = rcWeight.origin.y - SEPARATE_HEIGHT;	CGContextAddRect(cgc, rc);
	rc.origin.y = rcPuls.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcBp.origin.y - SEPARATE_HEIGHT;			CGContextAddRect(cgc, rc);
	rc.origin.y = rcDate.origin.y - SEPARATE_HEIGHT;		CGContextAddRect(cgc, rc);
	//画面に描画
	CGContextFillPath(cgc); // パスを塗り潰す
	
	// 右端の設定領域について
	rc = ibSegType.frame;
	rc.origin.x = self.bounds.size.width - WIDTH_OFFSET + 25;
	ibSegType.frame = rc;
	
	
	// E2record 取得
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
	NSLog(@"aE2records_=%@", aE2records_);
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

	CGPoint	pointsArray[GRAPH_MAX+1];
	long			valuesArray[GRAPH_MAX+1];
	int			arrayNo;

	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	po.x = self.bounds.size.width - WIDTH_OFFSET; // 最新日の描画位置
	po.y = rcDate.origin.y + H_GAP;
	arrayNo = 0;
	for (E2record *e2 in aE2records_)
	{
		if (e2.dateTime) 
		{
			pointsArray[ arrayNo ] = po;
			NSDateComponents *comp = [calendar components:unitFlags fromDate:e2.dateTime];
			valuesArray[ arrayNo ] = comp.month * 1000000 + comp.day * 10000 + comp.hour * 100 + comp.minute;
			arrayNo++;
		}
		po.x -= (W_HOUR * 24);
		if (po.x <= 0) break;
	}
	[self graphDrawDate:cgc count:arrayNo points:pointsArray values:valuesArray];	
	
	//-------------------------------------------------------------------------------------- BpHi グラフ描画
	fYstep = rcBp.size.height / (iMaxBp - iMinBp + H_GAP*2);  // 1あたりのポイント数
	po.x = self.bounds.size.width - WIDTH_OFFSET; // 最新日の描画位置
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
			}
		}
		po.x -= (W_HOUR * 24);
		if (po.x <= 0) break;
	}
	[self graphDrawOne:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueDec:0  pointLower:rcBp.origin.y];
	
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
	static CGContextRef cgc = nil;
	
	if (bDrowRect_) {	// 初期化時に通さないため
		//現在のグラフィックスコンテキストを取得
		if (cgc==nil) {
			cgc = UIGraphicsGetCurrentContext();
			// CoreGraphicsの原点が左下なので原点を合わせる
			CGContextTranslateCTM(cgc, 0, rect.size.height);
			CGContextScaleCTM(cgc, 1.0, -1.0);
		}
		[self graphDraw:cgc];
		//CGContextRelease(cgc);
	}
	bDrowRect_ = YES;
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

