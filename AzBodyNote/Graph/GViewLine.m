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
@synthesize ppE2records, ppPage, ppFont, ppRecordWidth;
@synthesize ppEntityKey;
@synthesize ppGoalKey;
@synthesize ppDec;
@synthesize ppMin;
@synthesize ppMax;


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
		if (iS_iPAD) {
			mPadScale = 1.5;
		} else {
			mPadScale = 1.0;
		}
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
		CGContextSelectFont (cgc, "Helvetica", FONT_SIZE*mPadScale, kCGEncodingMacRoman);
		CGContextSetTextDrawingMode (cgc, kCGTextFill);
		CGContextSetGrayFillColor(cgc, 0, 1);
		
		size_t  slen = strlen(cc);
#ifdef NG_SLANT_TYPE
		// 回転	// 45度
		CGAffineTransform  myTextTransform =  CGAffineTransformMakeRotation( 3.1415/4.0 );
		CGContextSetTextMatrix (cgc, myTextTransform); 
		// 文字原点
		if (self.bounds.size.height < po.y+(10+(FONT_SIZE*slen/2.0))*mPadScale) {	//点の左下へ
			po.x -= ((FONT_SIZE*slen/2.5) - 8.0)*mPadScale;
			po.y -= ((FONT_SIZE*slen/2.5) + 10.0)*mPadScale;
		} else {	//点の右上へ
			//po.x += 0.0;
			po.y += 7.0*mPadScale;
		}
#else
		//[0.10] 水平のみにした。＜＜文字が傾くのは見難いとの要望より
		// 文字原点
		po.x -= ((FONT_SIZE*slen/4.0) + 2.0)*mPadScale;
		if (self.bounds.size.height < po.y+14.0*mPadScale) {	//点の下へ
			po.y -= 15.0*mPadScale;
		} else {	//点の上へ
			po.y += 5.0*mPadScale;
		}
#endif
		CGContextShowTextAtPoint (cgc, po.x, po.y, cc, slen);
	}
	CGContextRestoreGState(cgc); //POP
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// E2record
	if ([self.ppE2records count] < 1) {
		return;
	}
	//NSLog(@"__E2records=%@", __E2records);

	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	BOOL bGoal = [kvs boolForKey:KVS_bGoal];
	NSInteger iGoal = [[kvs objectForKey: self.ppGoalKey] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	
	//--------------------------------------------------------------------------集計しながらMinMaxを求める
	//Goal
	if (self.ppMin<=iGoal  &&  iGoal<=self.ppMax) {
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
	for (E2record *e2 in self.ppE2records) 
	{
		NSInteger iVal = [[e2 valueForKey:self.ppEntityKey] integerValue];
	
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

	CGFloat fSpaceY = SPACE_Y * mPadScale;	//縦棒の上下余白
	CGFloat fYstep = (rect.size.height - fSpaceY*2.0) / (pValMax - pValMin);  // 1あたりのポイント数
	CGPoint po;
	po.x = self.bounds.size.width - self.ppRecordWidth/2;
	
	if (self.ppPage==0) {
		//Goal
		if (bGoal && 0 < pValGoal) {
			po.y = fSpaceY + fYstep * (CGFloat)(pValGoal - pValMin);
			[self drawPoint:cgc po:po value:pValGoal valueType:self.ppDec];
		}
		po.x -= self.ppRecordWidth;
	}
	
	//Record
	CGPoint	poLine[GRAPH_PAGE_LIMIT+GRAPH_DAYS_SAFE+1];
	int  iCntLine = 0;
	for (int ii = 0; ii < pValueCount; ii++) {
		if (po.x <= 0) break;
		po.y = fSpaceY + fYstep * (CGFloat)(pValue[ ii ] - pValMin);
		if (0 < pValue[ ii ]) { // 有効な点だけにする
			poLine[iCntLine++] = po;
			[self drawPoint:cgc po:po value:pValue[ii] valueType:self.ppDec];
		}
		po.x -= self.ppRecordWidth;
	}
	//------------------------------------------------------------------------------時系列折れ線
	CGContextSetLineWidth(cgc, 1.0); //太さ
	CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.4);
	CGContextAddLines(cgc, poLine, iCntLine);
	CGContextStrokePath(cgc);
}


@end
