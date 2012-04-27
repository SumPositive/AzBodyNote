//
//  GViewLine.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewLine.h"
#import "GraphVC.h"

#define SPACE_Y				5.0


@implementation GViewLine
@synthesize ppE2records = __E2records;
@synthesize ppEntityKey = __EntityKey;
@synthesize ppGoalKey = __GoalKey;
@synthesize ppDec = __Dec;
@synthesize ppMin = __Min;
@synthesize ppMax = __Max;

NSInteger	pValGoal;
CGPoint		poValGoal;
NSInteger	pValMin, pValMax;
NSInteger	pValue[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
CGPoint		poValue[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
NSInteger	pValueCount;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
/*		// 丸め指定
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
		}*/
    }
    return self;
}

//[self drawPoint:cgc po:po value:pValGoal valueType:__Dec];
- (void)drawPoint:(CGContextRef)cgc 
		   po:(CGPoint)po
		   value:(NSInteger)value  
		valueType:(int)valueType		// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	//CGFloat fColR, fColG, fColB, fAlpha;
	//CGFloat fXoffset = 0;
/*	switch (lineNo) {
		case 1:	//Wake-up
			fColR=1, fColG=1, fColB=0, fAlpha=0.5; //Yellow
			fXoffset = -10;
			break;
		case 3:	//For-sleep
			fColR=0, fColG=0, fColB=0, fAlpha=0.5; //Black
			fXoffset = +10;
			break;
		default:	//Active
			fColR=0, fColG=0, fColB=1, fAlpha=0.5; //Blue
			break;
	}*/

	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0); // Black

	// 端点
	CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
	// 数値
	const char *cc;
	switch (valueType) {
		case 1:	// Temp(999⇒99.9℃)  // Weight(9999⇒999.9Kg)
			cc = [[NSString stringWithFormat:@"%0.1f", value / 10.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
			break;
		default:
			cc = [[NSString stringWithFormat:@"%0.0f", value] UTF8String];
			break;
	}
	// 右側に表示
	CGContextShowTextAtPoint (cgc, po.x+5, po.y-4, cc, strlen(cc));
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
	BOOL bGoal = [kvs boolForKey:GUD_bGoal];
	NSInteger iGoal = [[kvs objectForKey: __GoalKey] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる

	//mGraphDays = [[kvs objectForKey:GUD_SettGraphDays] integerValue];
	//BOOL bGoal = [kvs boolForKey:GUD_bGoal];

/*	mValuesMode = 0;  //DateOptモード： 3本値
	if ([__EntityKey isEqualToString:E2_nPedometer]) {
		mValuesMode = 1; // 合計
	}
	else if ([__EntityKey isEqualToString:E2_nWeight_10Kg] 
		OR [__EntityKey isEqualToString:E2_nBodyFat_10p]
		OR [__EntityKey isEqualToString:E2_nSkMuscle_10p]) {
		mValuesMode = 2; // 平均
	}*/
		
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	//NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//NSDateComponents* comp;
	//int iPrevMonth = 0, iPrevDay = 0;

	//--------------------------------------------------------------------------集計しながらMinMaxを求める
	//Goal
	if (__Min<=iGoal  &&  iGoal<=__Max) {
		pValMin = iGoal;
		pValMax = iGoal;
		pValGoal = iGoal;
	} else {
		pValMax = 0;
		pValMin = 9999;
		pValGoal = 0;
	}
	
	//Record
	pValueCount = 0;
	for (E2record *e2 in __E2records) 
	{
		NSInteger iVal = [[e2 valueForKey:__EntityKey] integerValue];
	
		if (iVal < pValMin) pValMin = iVal;
		if (pValMax < iVal) pValMax = iVal;
		
		pValue[pValueCount] = iVal;
		pValueCount++;
		if (GRAPH_PAGE_LIMIT <= pValueCount) break; // OK
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
	
	CGFloat fYstep;
	CGPoint po;
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;
	
	//--------------------------------------------------------------------------プロット
	if (pValMin==pValMax) {
		pValMin--;
		pValMax++;
	}
	fYstep = (rect.size.height - SPACE_Y*2) / (pValMax - pValMin);  // 1あたりのポイント数
	
	BOOL bStart = YES;
	//Goal
	po.x = fXgoal;
	if (bGoal) {
		CGContextMoveToPoint(cgc, po.x, po.y);
		bStart = NO;
		[self drawPoint:cgc po:po value:pValGoal valueType:__Dec];
	}
	
	//Record
	for (int ii = 0; ii < pValueCount; ii++) {
		po.x -= RECORD_WIDTH;
		if (po.x <= 0) break;
		po.y = SPACE_Y + fYstep * (CGFloat)(pValue[ ii ] - pValMin);
		if (0 < po.y) { // 有効な点だけにする
			if (bStart) {
				CGContextMoveToPoint(cgc, po.x, po.y);
				bStart = NO;
			} else {
				CGContextAddLineToPoint(cgc, po.x, po.y);
			}
			[self drawPoint:cgc po:po value:pValue[ii] valueType:__Dec];
		}
	}
	CGContextStrokePath(cgc);
}


@end
