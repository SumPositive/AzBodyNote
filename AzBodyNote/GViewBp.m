//
//  GViewBp.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewBp.h"
#import "GraphVC.h"


@implementation GViewBp
@synthesize ppE2records = __E2records;

enum {
	bpHi		= 0,
	bpLo	= 1,
	bpEnd	= 2 //End count
};
typedef NSInteger bpType;

enum {
	optWake		= 0,
	optActive	= 1,
    optSleep		= 2,
	optEnd			= 3 //End count
};
typedef NSInteger optType;

NSInteger	pValMin[bpEnd], pValMax[bpEnd];
NSInteger	pDaySum[bpEnd][optEnd];
NSInteger	pDayCnt[bpEnd][optEnd];

NSInteger	pValGoal[bpEnd];
CGPoint		poGoal[bpEnd ];

float				pValAvg[bpEnd][optEnd];
CGPoint		poAvg[bpEnd][optEnd];

float				pValues[bpEnd][optEnd][VA_REC+GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
CGPoint		poValues[bpEnd][optEnd][VA_REC+GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
NSInteger	pValuesCount = 0;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		// 丸め指定
		if (mBehaviorDec0==nil) {
			mBehaviorDec0 = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode: NSRoundBankers		// 偶数丸め
							scale: 0									// 丸めた後の桁数　　0=整数化
							raiseOnExactness: YES			// 精度
							raiseOnOverflow: YES				// オーバーフロー
							raiseOnUnderflow: YES			// アンダーフロー
							raiseOnDivideByZero: YES ];	// アンダーフロー
		}
		if (mBehaviorDec1==nil) {
			mBehaviorDec1 = [[NSDecimalNumberHandler alloc]
							 initWithRoundingMode: NSRoundBankers		// 偶数丸め
							 scale: 1									// 丸めた後の桁数　　0=整数化
							 raiseOnExactness: YES			// 精度
							 raiseOnOverflow: YES				// オーバーフロー
							 raiseOnUnderflow: YES			// アンダーフロー
							 raiseOnDivideByZero: YES ];	// アンダーフロー
		}
    }
    return self;
}


- (void)imageGraph:(CGContextRef)cgc center:(CGPoint)po  opt:(optType)opt
{
	UIImage *img = nil;
	switch (opt) {
		case optWake:	//Wake-up
			img = [UIImage imageNamed:@"Icon20-WakeUp"];
			break;
		case optSleep:	//For-sleep
			img = [UIImage imageNamed:@"Icon20-ForSleep"];
			break;
		default:
			return;
	}
	CGRect rc = CGRectMake(po.x-img.size.width/2.0, po.y-img.size.height/2.0, 
						   img.size.width, img.size.height);
	
	CGContextSaveGState(cgc); //PUSH
	{
		CGContextSetAlpha(cgc, 0.7);
		CGContextDrawImage(cgc, rc, img.CGImage);
	}
	CGContextRestoreGState(cgc); //POP
}

#define HILO_WID		15.0		// BpHi と BpLo を結ぶ縦線の太さ

- (void)bpValueDraw:(CGContextRef)cgc  value:(float)value  center:(CGPoint)cpo
{
	const char *cc;
	long lg = (long)(value * 10);
	if (value == (float)lg) {
		//　小数なし
		cc = [[NSString stringWithFormat:@"%0.0f", value] UTF8String];
	} else {
		// 小数あり
		cc = [[NSString stringWithFormat:@"%0.1f", value] UTF8String];
	}
	CGContextSaveGState(cgc); //PUSH
	{
		CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);	// 文字の色
		CGContextShowTextAtPoint (cgc, cpo.x, cpo.y, cc, strlen(cc));
	}
	CGContextRestoreGState(cgc); //POP
}

- (void)graphDraw:(CGContextRef)cgc 
{
	CGPoint po;
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);

	//------------------------------------------------------------------------------ BpHi と BpLo を結ぶ縦線
	// カラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 0.5); // 塗り潰し色　Black
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.5);	// 文字の色
	CGContextSetLineWidth(cgc, 1.0); //線の太さ

	//--------------------------------------------------- Goal
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	if ([kvs boolForKey:GUD_bGoal]) {
		if (0<pValGoal[bpHi]) {
			po = poGoal[bpHi];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			po.y += HILO_WID;
			[self bpValueDraw:cgc value:pValGoal[bpHi] center:po];
		}
		if (0<pValGoal[bpLo]) {
			po = poGoal[bpLo];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			po.y -= HILO_WID;
			[self bpValueDraw:cgc value:pValGoal[bpLo] center:po];
		}
		if (0<pValGoal[bpHi] && 0<pValGoal[bpLo]) {
			CGContextSetLineWidth(cgc, HILO_WID); //太さ
			po = poGoal[bpHi];
			CGContextMoveToPoint(cgc, po.x, po.y);
			po = poGoal[bpLo];
			CGContextAddLineToPoint(cgc, po.x, po.y);
			CGContextStrokePath(cgc);
		}
	}
	//--------------------------------------------------- Avg
	for (optType opt=optWake; opt<optEnd; opt++) {
		switch (opt) {
			case optWake:	//Wake-up
				CGContextSetRGBFillColor (cgc, 1, 1, 0, 0.4); //Yellow
				CGContextSetRGBStrokeColor(cgc, 1, 1, 0, 0.4);	// 文字の色
				break;
			case optSleep:	//For-sleep
				CGContextSetRGBFillColor (cgc, 0, 0, 0, 0.4); //Black
				CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.4);	// 文字の色
				break;
			default:	//Active
				CGContextSetRGBFillColor (cgc, 0, 0, 1, 0.4); //Blue
				CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.4);	// 文字の色
				break;
		}
		if (0<pValAvg[bpHi][opt]) {
			po = poAvg[bpHi][opt];
			po.x += (HILO_WID * (opt-1));
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			//平均水平線
			CGContextSaveGState(cgc); //PUSH
			{
				CGFloat len[]={1.0, 5.0}; //点線の形状指定　　={描画ピクセル数, 空白ピクセル数}
				CGContextSetLineDash(cgc, 0, len, sizeof(len)/sizeof(len[0]));  //点線の形状指定
				CGContextSetLineWidth(cgc, 2.0); //太さ
				CGContextMoveToPoint(cgc, po.x, po.y);
				CGContextAddLineToPoint(cgc, poValues[bpHi][opt][pValuesCount-1].x, po.y);
				CGContextStrokePath(cgc);
			}
			CGContextRestoreGState(cgc); //POP
			po.y += HILO_WID;
			[self bpValueDraw:cgc value:pValAvg[bpHi][opt] center:po];
		}
		if (0<pValAvg[bpLo][opt]) {
			po = poAvg[bpLo][opt];
			po.x += (HILO_WID * (opt-1));
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			//平均水平線
			CGContextSaveGState(cgc); //PUSH
			{
				CGFloat len[]={1.0, 5.0}; //点線の形状指定　　={描画ピクセル数, 空白ピクセル数}
				CGContextSetLineDash(cgc, 0, len, sizeof(len)/sizeof(len[0]));  //点線の形状指定
				CGContextSetLineWidth(cgc, 1.0); //太さ
				CGContextMoveToPoint(cgc, po.x, po.y);
				CGContextAddLineToPoint(cgc, poValues[bpLo][opt][pValuesCount-1].x, po.y);
				CGContextStrokePath(cgc);
			}
			CGContextRestoreGState(cgc); //POP
			po.y -= HILO_WID;
			[self bpValueDraw:cgc value:pValAvg[bpLo][opt] center:po];
		}
		if (0<pValAvg[bpHi][opt] && 0<pValAvg[bpLo][opt]) {
			CGContextSetLineWidth(cgc, HILO_WID); //太さ
			po = poAvg[bpHi][opt];
			po.x += (HILO_WID * (opt-1));
			CGContextMoveToPoint(cgc, po.x, po.y);
			po = poAvg[bpLo][opt];
			po.x += (HILO_WID * (opt-1));
			CGContextAddLineToPoint(cgc, po.x, po.y);
			CGContextStrokePath(cgc);
			// 朝夕アイコン表示
			po.y = poAvg[bpHi][opt].y/2 + poAvg[bpLo][opt].y/2;
			[self imageGraph:cgc center:po opt:opt];
		}
	}

	//--------------------------------------------------- Record
	for (int ii=0; ii<pValuesCount; ii++) {
		for (optType opt=optWake; opt<optEnd; opt++) {
			switch (opt) {
				case optWake:	//Wake-up
					CGContextSetRGBFillColor (cgc, 1, 1, 0, 0.4); //Yellow
					CGContextSetRGBStrokeColor(cgc, 1, 1, 0, 0.4);	// 文字の色
					break;
				case optSleep:	//For-sleep
					CGContextSetRGBFillColor (cgc, 0, 0, 0, 0.4); //Black
					CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.4);	// 文字の色
					break;
				default:	//Active
					CGContextSetRGBFillColor (cgc, 0, 0, 1, 0.4); //Blue
					CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.4);	// 文字の色
					break;
			}
			if (0<pValues[bpHi][opt][ii]) {
				po = poValues[bpHi][opt][ii];
				po.x += (HILO_WID * (opt-1));
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
				po.y += HILO_WID;
				[self bpValueDraw:cgc value:pValues[bpHi][opt][ii] center:po];
			}
			if (0<pValues[bpLo][opt][ii]) {
				po = poValues[bpLo][opt][ii];
				po.x += (HILO_WID * (opt-1));
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
				po.y -= HILO_WID;
				[self bpValueDraw:cgc value:pValues[bpLo][opt][ii] center:po];
			}
			if (0<pValues[bpHi][opt][ii] && 0<pValues[bpLo][opt][ii]) {
				CGContextSetLineWidth(cgc, HILO_WID); //太さ
				po = poValues[bpHi][opt][ii];
				po.x += (HILO_WID * (opt-1));
				CGContextMoveToPoint(cgc, po.x, po.y);
				po = poValues[bpLo][opt][ii];
				po.x += (HILO_WID * (opt-1));
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
			}
		}
	}
}

- (NSInteger)integerAverage:(NSInteger)iValSum count:(NSInteger)iCnt
{
	assert(mBehaviorDec0);
	if (iCnt<=0) {
		return 0;
	}
	NSNumber *nVal = [NSNumber numberWithInteger:iValSum];
	NSDecimalNumber* decVal = [NSDecimalNumber decimalNumberWithDecimal:
							   [nVal decimalValue]];
	NSNumber *nCnt = [NSNumber numberWithInteger:iCnt];
	NSDecimalNumber* decCnt = [NSDecimalNumber decimalNumberWithDecimal:
							   [nCnt decimalValue]];
	NSDecimalNumber* decAns = [decVal decimalNumberByDividingBy:decCnt
												   withBehavior:mBehaviorDec0]; //÷
	return (NSInteger)[decAns doubleValue];
}

- (float)floatAverage:(float)fValSum count:(NSInteger)iCnt
{
	assert(mBehaviorDec1);
	if (iCnt<=0) {
		return 0.0;
	}
	NSNumber *nVal = [NSNumber numberWithFloat:fValSum];
	NSDecimalNumber* decVal = [NSDecimalNumber decimalNumberWithDecimal:
							   [nVal decimalValue]];
	NSNumber *nCnt = [NSNumber numberWithInteger:iCnt];
	NSDecimalNumber* decCnt = [NSDecimalNumber decimalNumberWithDecimal:
							   [nCnt decimalValue]];
	NSDecimalNumber* decAns = [decVal decimalNumberByDividingBy:decCnt
												   withBehavior:mBehaviorDec1]; //÷
	return (float)[decAns doubleValue];
}

- (void)pValuesForDay
{	// 1日分を集計して平均値(pDaySum/pDayCnt)を求める
	assert(0 <= pValuesCount);
	// 平均　（偶数丸め整数化）
	NSLog(@"pValuesCount=%ld", (long)pValuesCount);
	for (int bp=0; bp<bpEnd; bp++) {
		for (int opt=0; opt<optEnd; opt++) {
			// 偶数丸めによる平均化
			pValues[bp][opt][pValuesCount] = [self floatAverage:pDaySum[bp][opt] count:pDayCnt[bp][opt]];
			NSLog(@"	pValues[%d][%d][%ld]=%.2f", bp, opt, (long)pValuesCount, pValues[bp][opt][pValuesCount]);
			// 次の日のためにクリア
			pDaySum[bp][opt] = 0;
			pDayCnt[bp][opt] = 0;
		}
	}
	pValuesCount++;
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

	pValMin[bpHi] = E2_nBpHi_MIN;
	pValMin[bpLo] = E2_nBpLo_MIN;
	pValMax[bpHi] = E2_nBpHi_MAX;
	pValMax[bpLo] = E2_nBpLo_MAX;
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	pValGoal[bpHi] = [[kvs objectForKey: Goal_nBpHi_mmHg] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	pValGoal[bpLo] = [[kvs objectForKey: Goal_nBpLo_mmHg] integerValue];
	
	mGraphDays = [[kvs objectForKey:GUD_SettGraphDays] integerValue];
	//BOOL bGoal = [kvs boolForKey:GUD_bGoal];

	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0;

	//--------------------------------------------------------------------------日次集計
	// Record
	pValuesCount = 0; //Init
	for (E2record *e2 in __E2records) 
	{
#ifdef DEBUG
		// 日次集計											月									日									時
		comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit
						   fromDate:e2.dateTime];
		NSLog(@"<<<%d/%d : %d>>>[%ld]", comp.month, comp.day, comp.hour, (long)pValuesCount);
#else
		// 日次集計											月									日		
		comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit
						   fromDate:e2.dateTime];
#endif
		if (iPrevMonth==0) {	// 最初1度だけ初期化
			iPrevMonth = comp.month;
			iPrevDay = comp.day;
		}
		else if (iPrevMonth != comp.month OR iPrevDay != comp.day) {
			NSLog(@"<<%d/%d>>  mValuesCount=%d", iPrevMonth, iPrevDay, pValuesCount);
			iPrevMonth = comp.month;
			iPrevDay = comp.day;
			// 日付が変わったので、前日の集計処理する
			[self pValuesForDay];
			if (mGraphDays <= pValuesCount) break; // OK
		}
		// 集計
		optType opt = [e2.nDateOpt integerValue];
		NSInteger val[bpEnd];
		val[bpHi] = [e2.nBpHi_mmHg integerValue];
		val[bpLo] = [e2.nBpLo_mmHg integerValue];
		for (bpType bp=0; bp<bpEnd; bp++) {
			if (pValMin[bp]<=val[bp] && val[bp]<=pValMax[bp]) {
				pDaySum[bp][opt] += val[bp]; //合計
				pDayCnt[bp][opt]++;	//母数
			}
		}
	}
	//終端
	NSLog(@"<<%d/%d>>LAST  mValuesCount=%d", iPrevMonth, iPrevDay, pValuesCount);
	// 最終日の集計処理する
	[self pValuesForDay];

	float  fValMin = E2_nBpHi_MAX;	//プロット範囲の下限
	float  fValMax = E2_nBpLo_MIN;	//プロット範囲の上限
	// 期間の平均値(pValAvg)を求める
	float fv;
	for (bpType bp=0; bp<bpEnd; bp++) {
		fv = pValMin[bp];
		pValMin[bp] = pValMax[bp];	//初期最大値にする
		pValMax[bp] = fv;	//初期最小値にする
		for (optType opt=0; opt<optEnd; opt++) {
			NSInteger iSum = 0;
			NSInteger iCnt = 0;
			for (int ii=0; ii<pValuesCount; ii++) {
				fv = pValues[bp][opt][ii];
				if (0.0 < fv) {
					iSum += fv;
					iCnt++;
					// MinMax
					if (fValMax < fv) {
						fValMax = fv;
					}
					else if (fv < fValMin) {
						fValMin = fv;
					}
				}
			}
			if (1 < iCnt) {
				pValAvg[bp][opt] = [self floatAverage:(float)iSum count:iCnt];
			} else {
				pValAvg[bp][opt] = (float)iSum;
			}
			NSLog(@"	pValAvg[%d][%d]=%.2f", bp, opt, pValAvg[bp][opt]);
		}
	}
	
	// 描画開始
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);	//Y座標(-1)反転
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, rect);
	// 領域の下線
	CGRect rc = rect; //self.bounds;
	rc.origin.y = 1;  //rc.size.height - 3;
	rc.size.height = 2;
	CGContextSetRGBFillColor (cgc, 0.75, 0.75, 0.75, 1.0);
	CGContextFillRect(cgc, rc);
	
	
	//--------------------------------------------------------------------------プロット
	CGFloat fYstep;
	CGPoint po;	// 描画範囲(rect)に収まるようにプロットした座標
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;

	//CGPoint	pointsArray[GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
	//CGPoint	points[GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
	//float			values[GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
	//int iCount = 1;
	
	for (bpType bp=0; bp<bpEnd; bp++)
	{
		if (fValMax - fValMin < 10.0) {
			fValMin -= 10;
			fValMax += 10;
		}
		assert(fValMin < fValMax);
		// 描画範囲(rect)の高さに収まるようにＹ軸スケールを調整する
		fYstep = (rect.size.height - GRAPH_H_GAP*2) / (fValMax - fValMin);  // Ｙ座標スケール
		//
		po.x = fXgoal;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(pValGoal[bp] - fValMin);
		poGoal[bp] = po;
		//
		for (optType opt=optWake; opt<optEnd; opt++)
		{
			po.x = fXgoal - RECORD_WIDTH;
			po.y = GRAPH_H_GAP + fYstep * (CGFloat)(pValAvg[bp][opt] - fValMin);
			poAvg[bp][opt] = po;
			po.x -= RECORD_WIDTH;	//左へ
			//
			for (int ii=0; ii<pValuesCount; ii++) {
				if (po.x <= 0) break;
				po.y = GRAPH_H_GAP + fYstep * (CGFloat)(pValues[bp][opt][ ii ] - fValMin);
				poValues[bp][opt][ii] = po;
				po.x -= RECORD_WIDTH;	//1日づつ
			}
		}
	}
	//ここまでで、以下のパラメータがセット完了。
	//NSInteger	pValGoal[bpEnd];
	//CGPoint		poGoal[bpEnd ];
	//float				pValAvg[bpEnd][optEnd];
	//CGPoint		poAvg[bpEnd][optEnd];
	//float				pValues[bpEnd][optEnd][VA_REC+GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
	//CGPoint		poValues[bpEnd][optEnd][VA_REC+GRAPH_DAYS_MAX+GRAPH_DAYS_SAFE+1];
	//NSInteger	pValuesCount = 0;
	//以上のパラメータを使って self.view へ描画する。
	[self graphDraw:cgc];
}


@end
