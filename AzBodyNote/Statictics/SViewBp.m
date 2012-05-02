//
//  SViewBp.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "SViewBp.h"
#import "StatisticsVC.h"


#define SPACE_Y			  8.0		// グラフの最大および最小の極限余白 > LINE_WID/2.0
#define LINE_WID			15.0		// BpHi と BpLo を結ぶ縦線の太さ   < SPACE_Y*2.0


@implementation SViewBp
@synthesize ppE2records = __E2records;
@synthesize ppSelectedSegmentIndex = __SelectedSegmentIndex;


NSInteger	pValMin[bpEnd], pValMax[bpEnd];
DateOpt		pDateOpt[STAT_DAYS_MAX+STAT_DAYS_SAFE+1]; //DateOpt
CGPoint		poStatHiLo[STAT_DAYS_MAX+STAT_DAYS_SAFE+1]; //BpHi,Lo分布
CGPoint		poStat24[bpEnd][STAT_DAYS_MAX+STAT_DAYS_SAFE+1]; //Bp24時間分布
NSInteger	pStatCount = 0;


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


- (void)imageGraph:(CGContextRef)cgc center:(CGPoint)po  opt:(DateOpt)opt
{
	UIImage *img = nil;
	switch (opt) {
		case DtOpWake:
			img = [UIImage imageNamed:@"Icon20-Wake"];
			break;
		case DtOpRest:
			img = [UIImage imageNamed:@"Icon20-Rest"];
			break;
		case DtOpDown:
			img = [UIImage imageNamed:@"Icon20-Down"];
			break;
		case DtOpSleep:
			img = [UIImage imageNamed:@"Icon20-Sleep"];
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


- (void)bpValueDraw:(CGContextRef)cgc  value:(float)value  po:(CGPoint)po  isHi:(BOOL)isHi
{
	const char *cc;
	long lg = (long)(value * 10.0);
	if (lg==(lg/10)*10) {
		//　小数なし
		cc = [[NSString stringWithFormat:@"%0.0f", value] UTF8String];
	} else {
		// 小数あり
		cc = [[NSString stringWithFormat:@"%0.1f", value] UTF8String];
	}
	if (isHi) {
		// BpHi
		po.x += 5.0;
		po.y -= (5.0 + strlen(cc) * 7.0);
	} else {
		// BpLo
		po.x += 5.0;
		po.y += 5.0;
	}
	CGContextSaveGState(cgc); //PUSH
	{
		CGContextSelectFont (cgc, "Helvetica", 14.0, kCGEncodingMacRoman);
		CGContextSetTextDrawingMode (cgc, kCGTextFill);
		CGContextSetRGBFillColor (cgc, 1, 1, 1, 1.0); // 塗り潰し色　Black
		//CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);	// 文字の色
		CGAffineTransform  myTextTransform =  CGAffineTransformMakeRotation( 3.1415/2.0 );
		CGContextSetTextMatrix (cgc, myTextTransform); 
		CGContextShowTextAtPoint (cgc, po.x, po.y, cc, strlen(cc));
	}
	CGContextRestoreGState(cgc); //POP
}

- (void)strokeColor:(CGContextRef)cgc opt:(DateOpt)opt
{
	switch (opt) {
		case DtOpWake:
			CGContextSetRGBStrokeColor (cgc, 0.9, 0.9, 0.0, 0.7); //Yellow
			break;
		case DtOpRest:
			CGContextSetRGBStrokeColor (cgc, 0.0, 0.0, 0.0, 1.0); //Black
			break;
		case DtOpDown:
			CGContextSetRGBStrokeColor (cgc, 0.0, 0.0, 1.0, 1.0); //Blue
			break;
		case DtOpSleep:
			CGContextSetRGBStrokeColor (cgc, 0.3, 0.3, 0.3, 0.7); //Black
			break;
		default:
			CGContextSetRGBStrokeColor (cgc, 0.0, 0.5, 0.0, 0.3); //Blue
			break;
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// E2record
	if ([__E2records count] < 1) {
		return;
	}
	//NSLog(@"__E2records=%@", __E2records);

	pValMin[bpHi] = E2_nBpHi_MAX;
	pValMax[bpHi] = E2_nBpHi_MIN;
	pValMin[bpLo] = E2_nBpLo_MAX;
	pValMax[bpLo] = E2_nBpLo_MIN;
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mStatDays = [[kvs objectForKey:GUD_SettStatDays] integerValue];

	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;

	//--------------------------------------------------------------------------集計
	// Record
	NSInteger iHi, iLo;
	CGPoint	po;
	pStatCount = 0; //Init
	for (E2record *e2 in __E2records) 
	{
		// 日次集計											時										分
		comp = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:e2.dateTime];
		//NSLog(@"<<<%d : %d>>>[%ld]", comp.hour, comp.minute, (long)pValuesCount);
		
		iHi = [e2.nBpHi_mmHg integerValue];
		if (E2_nBpHi_MIN<=iHi && iHi<=E2_nBpHi_MAX) {
			if (E2_nBpLo_MIN<=iHi && iHi<pValMin[bpHi]) pValMin[bpHi] = iHi;
			if (pValMax[bpHi] < iHi) pValMax[bpHi] = iHi;
		} else {
			iHi = 0;
		}

		iLo = [e2.nBpLo_mmHg integerValue];
		if (E2_nBpLo_MIN<=iLo && iLo<=E2_nBpLo_MAX) {
			if (E2_nBpLo_MIN<=iLo && iLo<pValMin[bpLo]) pValMin[bpLo] = iLo;
			if (pValMax[bpLo] < iLo) pValMax[bpLo] = iLo;
		} else {
			iLo = 0;
		}

		pDateOpt[pStatCount] = [e2.nDateOpt integerValue];
		
		po.x = comp.hour * 60 + comp.minute; //分
		po.y = iHi;
		poStat24[bpHi][pStatCount] = po;
		po.y = iLo;
		poStat24[bpLo][pStatCount] = po;
		
		po.x = iLo;
		po.y = iHi;
		poStatHiLo[pStatCount] = po;
		
		pStatCount++;
	}
	//
	pValMin[bpHi] = (pValMin[bpHi] / 10) * 10;
	pValMax[bpHi] = 10 + (pValMax[bpHi] / 10) * 10;
	if (pValMax[bpHi] <= pValMin[bpHi]) {
		pValMin[bpHi] = 100;
		pValMax[bpHi] = 200;
	}
	pValMax[bpHi] += 3;
	NSLog(@"pValMin[bpHi]=%ld, pValMax[bpHi]=%ld", (long)pValMin[bpHi], (long)pValMax[bpHi]);
	pValMin[bpLo] = (pValMin[bpLo] / 10) * 10;
	pValMax[bpLo] = 10 + (pValMax[bpLo] / 10) * 10;
	if (pValMax[bpLo] <= pValMin[bpLo]) {
		pValMin[bpLo] = 50;
		pValMax[bpLo] = 150;
	}
	pValMax[bpLo] += 3;
	NSLog(@"pValMin[bpLo]=%ld, pValMax[bpLo]=%ld", (long)pValMin[bpLo], (long)pValMax[bpLo]);
	
	// 描画開始
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);	//Y座標(-1)反転
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, rect);
	// プロット領域
	CGRect rc = rect; //self.bounds;
	rc.origin.x = 50;
	rc.origin.y = 50;
	rc.size.width -= rc.origin.x;
	rc.size.height -= rc.origin.y;
	CGContextSetRGBFillColor (cgc, 1, 0.5, 0.5, 1.0);
	CGContextFillRect(cgc, rc);
	
	CGFloat fXstep = rc.size.width / (pValMax[bpLo] - pValMin[bpLo]);	//BpLo
	CGFloat fYstep = rc.size.height / (pValMax[bpHi] - pValMin[bpHi]); //BpHi
	NSLog(@"rect.size.width=%0.2f, pValMin=%ld, pValMax=%ld", rect.size.width, (long)pValMin, (long)pValMax);
	CGFloat fStep;
	if (fXstep < fYstep) {	// 縦:横=1:1 にするため小さい方に合わせる
		fStep = fXstep;
	} else {
		fStep = fYstep;
	}
	//--------------------------------------------------------------------------座標
	CGFloat fGap = 10.0 * fStep;
	// エリア：高血圧 中等症
	CGContextSetRGBFillColor (cgc, 0.9, 0.7, 0.7, 1);
	CGContextFillRect(cgc, CGRectMake(50, 50, fStep*(100-pValMin[bpLo]), fStep*(160-pValMin[bpHi])));
	// エリア：正常血圧
	CGContextSetRGBFillColor (cgc, 0.7, 0.7, 0.9, 1);
	CGContextFillRect(cgc, CGRectMake(50, 50, fStep*(85-pValMin[bpLo]), fStep*(130-pValMin[bpHi])));
	// ヨコ軸
	CGContextSetGrayStrokeColor(cgc, 0.5, 1);
	for (CGFloat fy=50; fy<=rect.size.height; fy += fGap) {
		CGContextMoveToPoint(cgc, 50, fy); //原点
		CGContextAddLineToPoint(cgc, rect.size.width, fy);
		CGContextStrokePath(cgc);
	}
	// タテ軸
	CGContextSetGrayStrokeColor(cgc, 0.5, 0.5);
	for (CGFloat fx=50; fx<=rect.size.width; fx += fGap) {
		CGContextMoveToPoint(cgc, fx, 50); //原点
		CGContextAddLineToPoint(cgc, fx, rect.size.height);
		CGContextStrokePath(cgc);
	}

	//--------------------------------------------------------------------------プロット HiLo
	for (bpType bp=0; bp<bpEnd; bp++)
	{
		for (NSInteger ii=0; ii < pStatCount; ii++) 
		{
			po = poStatHiLo[ii];
			if (0<po.x && 0<po.y) {
				po.x = 50 + (po.x - pValMin[bpLo]) * fStep;
				po.y = 50 + (po.y - pValMin[bpHi]) * fStep;
				switch (pDateOpt[ii]) {
					case DtOpWake:
						CGContextSetRGBFillColor (cgc, 1.0, 1.0, 0.0, 1); // 塗り潰し色
						break;
					case DtOpRest:
						CGContextSetRGBFillColor (cgc, 1.0, 1.0, 1.0, 1); // 塗り潰し色
						break;
					case DtOpDown:
						CGContextSetRGBFillColor (cgc, 0.3, 0.3, 0.9, 1); // 塗り潰し色
						break;
					case DtOpSleep:
						CGContextSetRGBFillColor (cgc, 0, 0, 0, 1); // 塗り潰し色
						break;
					default:
						CGContextSetRGBFillColor (cgc, 0, 0, 0, 0); // 塗り潰し色
						return;
				}
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
			}
		}
	}
}


@end
