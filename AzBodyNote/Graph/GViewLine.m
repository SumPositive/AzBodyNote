//
//  GViewLine.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewLine.h"
#import "GraphVC.h"

#define SPACE_Y			10.0		// グラフの最大および最小の極限余白
#define FONT_SIZE			14.0

@implementation GViewLine
@synthesize ppE2records = __E2records;
@synthesize ppPage = __Page;
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
    }
    return self;
}

- (void)drawPoint:(CGContextRef)cgc 
		   po:(CGPoint)po
		   value:(NSInteger)value  
		valueType:(int)valueType		// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
{
	const char *cc;
	switch (valueType) {
		case 1:	// Temp(999⇒99.9℃)  // Weight(9999⇒999.9Kg)
			cc = [[NSString stringWithFormat:@"%0.1f", (float)value / 10.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
			break;
		default:
			cc = [[NSString stringWithFormat:@"%ld", (long)value] UTF8String];
			break;
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
		// 回転	// 45度
		CGAffineTransform  myTextTransform =  CGAffineTransformMakeRotation( 3.1415/4.0 );
		CGContextSetTextMatrix (cgc, myTextTransform); 
		// 文字描画
		size_t  slen = strlen(cc);
		if (self.bounds.size.height < po.y+10+(FONT_SIZE*slen/2.0)) {	//点の左下へ
			po.x -= (FONT_SIZE*slen/2.5) - 8.0;
			po.y -= (FONT_SIZE*slen/2.5) + 10.0;
		} else {	//点の右上へ
			//po.x += 0.0;
			po.y += 7.0;
		}
		CGContextShowTextAtPoint (cgc, po.x, po.y, cc, slen);
	}
	CGContextRestoreGState(cgc); //POP
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
	BOOL bGoal = [kvs boolForKey:KVS_bGoal];
	NSInteger iGoal = [[kvs objectForKey: __GoalKey] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる

	//--------------------------------------------------------------------------集計しながらMinMaxを求める
	//Goal
	if (__Min<=iGoal  &&  iGoal<=__Max) {
		pValMin = iGoal;
		pValMax = iGoal;
		pValGoal = iGoal;
	} else {
		pValMin = 9999;
		pValMax = 0;
		pValGoal = 0;
	}
	
	//Record
	pValueCount = 0;
	for (E2record *e2 in __E2records) 
	{
		NSInteger iVal = [[e2 valueForKey:__EntityKey] integerValue];
	
		if (0 < iVal && iVal < pValMin) pValMin = iVal;
		if (pValMax < iVal) pValMax = iVal;
		
		pValue[pValueCount] = iVal;
		pValueCount++;
		//NG//if (GRAPH_PAGE_LIMIT <= pValueCount) break; // OK
	}

	// 描画開始
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);	//Y座標(-1)反転
	//　全域クリア
	//CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextSetGrayFillColor(cgc, 0.67, 1.0); // スクロール領域外と同じグレー

	CGContextFillRect(cgc, rect);
	// 領域の下線
	CGRect rc = rect; //self.bounds;
	rc.origin.y = 1;  //rc.size.height - 3;
	rc.size.height = 3;
	CGContextSetGrayFillColor(cgc, 0.75, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, rc);
	
	//--------------------------------------------------------------------------Line折れ線
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.8);
	//--------------------------------------------------------------------------プロット
	if (pValMin==pValMax) {
		pValMin--;
		pValMax++;
	}

	CGFloat fYstep = (rect.size.height - SPACE_Y*2) / (pValMax - pValMin);  // 1あたりのポイント数
	CGPoint po;
	po.x = self.bounds.size.width - RECORD_WIDTH/2;
	
	if (__Page==0) {
		//Goal
		if (bGoal && 0 < pValGoal) {
			po.y = SPACE_Y + fYstep * (CGFloat)(pValGoal - pValMin);
			[self drawPoint:cgc po:po value:pValGoal valueType:__Dec];
		}
		po.x -= RECORD_WIDTH;
	}
	
	//Record
	CGPoint	poLine[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
	int  iCntLine = 0;
	for (int ii = 0; ii < pValueCount; ii++) {
		if (po.x <= 0) break;
		po.y = SPACE_Y + fYstep * (CGFloat)(pValue[ ii ] - pValMin);
		if (0 < pValue[ ii ]) { // 有効な点だけにする
			poLine[iCntLine++] = po;
			[self drawPoint:cgc po:po value:pValue[ii] valueType:__Dec];
		}
		po.x -= RECORD_WIDTH;
	}
	//------------------------------------------------------------------------------時系列折れ線
	CGContextSetLineWidth(cgc, 1.0); //太さ
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.4);
	CGContextAddLines(cgc, poLine, iCntLine);
	CGContextStrokePath(cgc);
}


@end
