//
//  GViewBp.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewBp.h"
#import "GraphVC.h"


#define SPACE_Y			14.0		// グラフの最大および最小の極限余白 > LINE_WID/2.0
#define LINE_WID			24.0		// BpHi と BpLo を結ぶ縦線の太さ   < SPACE_Y*2.0
#define FONT_SIZE			14.0


@implementation GViewBp
@synthesize ppE2records = __E2records;
@synthesize ppPage = __Page;



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


- (void)drawPoint:(CGContextRef)cgc  value:(float)value  po:(CGPoint)po  isHi:(BOOL)isHi
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

	CGContextSaveGState(cgc); //PUSH
	{
		// 端点
		CGContextSetGrayFillColor(cgc, 0, 0.7);
		CGContextFillEllipseInRect(cgc, CGRectMake(po.x-3, po.y-3, 6, 6));	//円Fill
		// 数値	// 文字列の設定
		CGContextSelectFont (cgc, "Helvetica", FONT_SIZE, kCGEncodingMacRoman);
		CGContextSetTextDrawingMode (cgc, kCGTextFill);
		CGContextSetGrayFillColor(cgc, 0, 1);
		// 回転	// 90度
		CGAffineTransform  myTextTransform =  CGAffineTransformMakeRotation( 3.1415/2.0 );
		CGContextSetTextMatrix (cgc, myTextTransform); 
		if (isHi) {
			// BpHi
			po.x += 5.0;
			po.y -= (7.0 + strlen(cc) * (FONT_SIZE/2.0));
		} else {
			// BpLo
			po.x += 5.0;
			po.y += 7.0;
		}
	CGContextShowTextAtPoint (cgc, po.x, po.y, cc, strlen(cc));
	}
	CGContextRestoreGState(cgc); //POP
}

- (void)graphDraw:(CGContextRef)cgc 
{
	CGPoint po;
	
	//------------------------------------------------------------------------------ BpHi と BpLo を結ぶ縦線
	//CGContextSetRGBFillColor (cgc, 0.3, 0.3, 0.3, 0.6); // 塗り潰し色　Black
	CGContextSetLineCap(cgc, kCGLineCapRound);	//線分の端の形状指定: 端を丸くする
	CGContextSetLineWidth(cgc, LINE_WID); //太さ
	CGContextSetGrayStrokeColor(cgc, 0.5, 0.5);
	
	if (__Page==0) {
		//--------------------------------------------------- Goal
		NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
		if ([kvs boolForKey:GUD_bGoal]) {
			if (0<pValGoal[bpHi] && 0<pValGoal[bpLo]) 
			{	//文字を上層にすべく、このタテ棒を先に描画する
				po = poValGoal[bpHi];
				CGContextMoveToPoint(cgc, po.x, po.y);
				po = poValGoal[bpLo];
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
			}
			if (0<pValGoal[bpHi]) {
				[self drawPoint:cgc value:pValGoal[bpHi] po:poValGoal[bpHi] isHi:YES];
			}
			if (0<pValGoal[bpLo]) {
				[self drawPoint:cgc value:pValGoal[bpLo] po:poValGoal[bpLo] isHi:NO];		
			}
		}
	}

	//--------------------------------------------------- Record
	CGPoint	poBpHi[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
	CGPoint	poBpLo[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
	int  iCntBpHi = 0, iCntBpLo = 0;
	BOOL bLine;
	CGFloat fy;
	for (int ii=0; ii<pValueCount; ii++) 
	{
		if (0<pValue[bpHi][ii] && 0<pValue[bpLo][ii])
		{	//文字を上層にすべく、このタテ棒を先に描画する
			po = poValue[bpHi][ii];
			CGContextMoveToPoint(cgc, po.x, po.y);
			fy = po.y;
			po = poValue[bpLo][ii];
			CGContextAddLineToPoint(cgc, po.x, po.y);
			CGContextStrokePath(cgc);
			if (IMAGE_GAP_MIN <= fy - po.y) {
				po.y += (fy - po.y)/2.0;
				[self imageGraph:cgc center:po DtOp:pDtOpValue[ii]];
			}
			bLine = YES;
		} else {
			bLine = NO;
		}
		if (0<pValue[bpHi][ii]) {
			if (bLine==NO) {
				CGContextSetLineWidth(cgc, LINE_WID); //太さ
				po = poValue[bpHi][ii];
				CGContextMoveToPoint(cgc, po.x, po.y);
				fy = po.y;
				po.y -= IMAGE_GAP_MIN;
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
				if (IMAGE_GAP_MIN <= fy - po.y) {
					po.y += (fy - po.y)/2.0;
					[self imageGraph:cgc center:po DtOp:pDtOpValue[ii]];
				}
			}
			poBpHi[iCntBpHi++] = poValue[bpHi][ii];	//時系列折れ線のため
			[self drawPoint:cgc value:pValue[bpHi][ii] po:poValue[bpHi][ii] isHi:YES];
		}
		if (0<pValue[bpLo][ii]) {
			if (bLine==NO) {
				CGContextSetLineWidth(cgc, LINE_WID); //太さ
				po = poValue[bpLo][ii];
				CGContextMoveToPoint(cgc, po.x, po.y);
				fy = po.y;
				po.y += IMAGE_GAP_MIN;
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
				if (IMAGE_GAP_MIN <= fy - po.y) {
					po.y += (fy - po.y)/2.0;
					[self imageGraph:cgc center:po DtOp:pDtOpValue[ii]];
				}
			}
			poBpLo[iCntBpLo++] = poValue[bpLo][ii];	//時系列折れ線のため
			[self drawPoint:cgc value:pValue[bpLo][ii] po:poValue[bpLo][ii] isHi:NO];
		}
	}
	//------------------------------------------------------------------------------時系列折れ線
	//BpHi
	CGContextSetLineWidth(cgc, 1.0); //太さ
	CGContextSetRGBStrokeColor(cgc, 1, 0, 0, 0.6);
	CGContextAddLines(cgc, poBpHi, iCntBpHi);
	CGContextStrokePath(cgc);
	// BpLo
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.6);
	CGContextAddLines(cgc, poBpLo, iCntBpLo);
	CGContextStrokePath(cgc);
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
	
	//--------------------------------------------------------------------------日次集計
	// Record
	pValMax = E2_nBpLo_MIN;
	pValMin = E2_nBpHi_MAX;
	NSInteger valHi, valLo;
	pValueCount = 0; //Init
	for (E2record *e2 in __E2records) 
	{
		valHi = [e2.nBpHi_mmHg integerValue];		//=0:未定の場合があることに注意
		valLo = [e2.nBpLo_mmHg integerValue];	//=0:未定の場合があることに注意

		if (pValMax < valHi) pValMax = valHi;
		if (0 < valLo && valLo < pValMin) pValMin = valLo;
		//
		pValue[bpHi][pValueCount] = valHi;
		pValue[bpLo][pValueCount] = valLo;
		pDtOpValue[pValueCount] = [e2.nDateOpt integerValue];	
		pValueCount++;
		//NG//if (GRAPH_PAGE_LIMIT <= pValueCount) break; // OK
	}
	if (pValMax - pValMin < 10.0) {
		pValMin -= 5;
		pValMax += 5;
	}
	NSLog(@"pValMin=%ld < pValMax=%ld", (long)pValMin, (long)pValMax);
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
	rc.size.height = 3;
	CGContextSetGrayFillColor(cgc, 0.75, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, rc);
	
	//--------------------------------------------------------------------------プロット
	CGFloat fYstep = (rect.size.height - SPACE_Y*2.0) / (pValMax - pValMin);  //上下余白を考慮したＹ座標スケール
	CGPoint po;	// 描画範囲(rect)に収まるようにプロットした座標
	CGFloat	fXstart = self.bounds.size.width - RECORD_WIDTH/2.0;
	
	for (bpType bp=0; bp<bpEnd; bp++)
	{
		po.x = fXstart;
		if (__Page==0) {
			po.y = SPACE_Y + fYstep * (CGFloat)(pValGoal[bp] - pValMin);
			poValGoal[bp] = po;
			po.x -= RECORD_WIDTH;	//1日づつ
		}
		//
		for (int ii=0; ii<pValueCount; ii++) {
			if (po.x <= 0) break;
			po.y = SPACE_Y + fYstep * (CGFloat)(pValue[bp][ ii ] - pValMin);
			poValue[bp][ii] = po;
			po.x -= RECORD_WIDTH;	//1日づつ
		}
	}
	//ここまでで、pVal**パラメータがセット完了。
	//pVal**パラメータを使って self.view へ描画する。
	[self graphDraw:cgc];
}


@end
