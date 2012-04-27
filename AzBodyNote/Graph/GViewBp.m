//
//  GViewBp.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewBp.h"
#import "GraphVC.h"


#define SPACE_Y			  8.0		// グラフの最大および最小の極限余白 > LINE_WID/2.0
#define LINE_WID			15.0		// BpHi と BpLo を結ぶ縦線の太さ   < SPACE_Y*2.0


@implementation GViewBp
@synthesize ppE2records = __E2records;



//ここでは時系列に原始データのままプロットする。ゆえに平均などの統計は無意味。
//float				pValAvg[bpEnd]; //[optEnd];
//CGPoint		poAvg[bpEnd]; //[optEnd];

NSInteger	pValGoal[bpEnd];
CGPoint		poValGoal[bpEnd ];

NSInteger	pValMin, pValMax;
NSInteger	pValue[bpEnd][GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
CGPoint		poValue[bpEnd][GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
DateOpt		pDtOpValue[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
NSInteger	pValueCount = 0;


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


- (void)imageGraph:(CGContextRef)cgc center:(CGPoint)po  DtOp:(DateOpt)dtop
{
	UIImage *img = nil;
	switch (dtop) {
		case DtOpWake:	//Wake-up
			img = [UIImage imageNamed:@"Icon20-Wake"];
			break;
		case DtOpRest:
			img = [UIImage imageNamed:@"Icon20-Rest"];
			break;
		case DtOpDown:
			img = [UIImage imageNamed:@"Icon20-Down"];
			break;
		case DtOpSleep:	//For-sleep
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

- (void)strokeColor:(CGContextRef)cgc DtOp:(DateOpt)dtop
{
	switch (dtop) {
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

- (void)graphDraw:(CGContextRef)cgc 
{
	CGPoint po;
	
	//文字列の設定

	//------------------------------------------------------------------------------ BpHi と BpLo を結ぶ縦線
	// カラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 0.5); // 塗り潰し色　Black
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.5);	// 文字の色
	CGContextSetLineWidth(cgc, 1.0); //線の太さ
	CGContextSetLineCap(cgc, kCGLineCapRound);	//線分の端の形状指定: 端を丸くする

	//--------------------------------------------------- Goal
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	if ([kvs boolForKey:GUD_bGoal]) {
		if (0<pValGoal[bpHi] && 0<pValGoal[bpLo]) 
		{	//文字を上層にすべく、このタテ棒を先に描画する
			CGContextSetLineWidth(cgc, LINE_WID); //太さ
			po = poValGoal[bpHi];
			CGContextMoveToPoint(cgc, po.x, po.y);
			po = poValGoal[bpLo];
			CGContextAddLineToPoint(cgc, po.x, po.y);
			CGContextStrokePath(cgc);
		}
		if (0<pValGoal[bpHi]) {
			po = poValGoal[bpHi];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			po.y += LINE_WID;
			[self bpValueDraw:cgc value:pValGoal[bpHi] po:po isHi:YES];
		}
		if (0<pValGoal[bpLo]) {
			po = poValGoal[bpLo];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			po.y -= LINE_WID;
			[self bpValueDraw:cgc value:pValGoal[bpLo] po:po isHi:NO];		}
	}

	//--------------------------------------------------- Record
	BOOL bLine;
	for (int ii=0; ii<pValueCount; ii++) 
	{
		if (0<pValue[bpHi][ii] && 0<pValue[bpLo][ii])
		{	//文字を上層にすべく、このタテ棒を先に描画する
			CGContextSetLineWidth(cgc, LINE_WID); //太さ
			po = poValue[bpHi][ii];
			CGContextMoveToPoint(cgc, po.x, po.y);
			po = poValue[bpLo][ii];
			CGContextAddLineToPoint(cgc, po.x, po.y);
			CGContextStrokePath(cgc);
			bLine = YES;
		} else {
			bLine = NO;
		}
		if (0<pValue[bpHi][ii]) {
			if (bLine==NO) {
				CGContextSetLineWidth(cgc, LINE_WID); //太さ
				po = poValue[bpHi][ii];
				CGContextMoveToPoint(cgc, po.x, po.y);
				po.y -= 100;
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
			}
			po = poValue[bpHi][ii];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			[self bpValueDraw:cgc value:pValue[bpHi][ii] po:po isHi:YES];
		}
		if (0<pValue[bpLo][ii]) {
			if (bLine==NO) {  // 平均線まで引く
				CGContextSetLineWidth(cgc, LINE_WID); //太さ
				po = poValue[bpLo][ii];
				CGContextMoveToPoint(cgc, po.x, po.y);
				po.y += 100;
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
			}
			po = poValue[bpLo][ii];
			CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
			[self bpValueDraw:cgc value:pValue[bpLo][ii] po:po isHi:NO];
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
	pValGoal[bpHi] = [[kvs objectForKey: Goal_nBpHi_mmHg] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	pValGoal[bpLo] = [[kvs objectForKey: Goal_nBpLo_mmHg] integerValue];
	
	//mGraphDays = [[kvs objectForKey:GUD_SettGraphDays] integerValue];

/*	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0;
*/

	//--------------------------------------------------------------------------日次集計
	// Record
	pValMax = E2_nBpLo_MIN;
	pValMin = E2_nBpHi_MAX;
	NSInteger valHi, valLo, val;
	pValueCount = 0; //Init
	for (E2record *e2 in __E2records) 
	{
		valHi = [e2.nBpHi_mmHg integerValue];
		valLo = [e2.nBpLo_mmHg integerValue];
		if (valHi < valLo) {
			val = valHi;
			valHi = valLo;
			valLo = val;
		}
		if (pValMax < valHi) pValMax = valHi;
		if (valLo < pValMin) pValMin = valLo;
		//
		pValue[bpHi][pValueCount] = valHi;
		pValue[bpLo][pValueCount] = valLo;
		pValueCount++;
		if (GRAPH_PAGE_LIMIT <= pValueCount) break; // OK
	}
	if (pValMax - pValMin < 10.0) {
		pValMin -= 5;
		pValMax += 5;
	}
	assert(pValMin < pValMax);
	
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
	CGFloat fYstep = (rect.size.height - SPACE_Y*2) / (pValMax - pValMin);  //上下余白を考慮したＹ座標スケール
	CGPoint po;	// 描画範囲(rect)に収まるようにプロットした座標
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;
	
	for (bpType bp=0; bp<bpEnd; bp++)
	{
		po.x = fXgoal;
		po.y = SPACE_Y + fYstep * (CGFloat)(pValGoal[bp] - pValMin);
		poValGoal[bp] = po;
		//
		for (int ii=0; ii<pValueCount; ii++) {
			po.x -= RECORD_WIDTH;	//1日づつ
			if (po.x <= 0) break;
			po.y = SPACE_Y + fYstep * (CGFloat)(pValue[bp][ ii ] - pValMin);
			poValue[bp][ii] = po;
		}
	}
	//ここまでで、pVal**パラメータがセット完了。
	//pVal**パラメータを使って self.view へ描画する。
	[self graphDraw:cgc];
}


@end
