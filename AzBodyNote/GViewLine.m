//
//  GViewLine.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewLine.h"
#import "GraphVC.h"


@implementation GViewLine
@synthesize ppE2records = __E2records;
@synthesize ppEntityKey = __EntityKey;
@synthesize ppGoalKey = __GoalKey;
@synthesize ppDec = __Dec;
@synthesize ppMin = __Min;
@synthesize ppMax = __Max;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)graphDraw:(CGContextRef)cgc 
			count:(int)count
		   points:(const CGPoint *)points  
		   values:(const long *)values  
		valueType:(int)valueType		// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.9); // 折れ線の色
#ifdef YES
	// 折れ線
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:GUD_bGoal]) {
		CGContextAddLines(cgc, points, count);	
	} else {
		// Goalを結ばない  [0]を除き[1]から描画する
		CGContextAddLines(cgc, &points[1], count-1);	
	}
#else
	// スプライン曲線
#endif
	CGContextStrokePath(cgc);
	
	// 移動平均スプライン曲線
	CGPoint	splineArray[GRAPH_PAGE_LIMIT+20+1];
	int splineCnt = 0;
	int iCnt = 5;
	int iNo;
	for (iNo=1; iNo < count - iCnt; iNo++) 
	{
		CGFloat fy = 0.0;
		for (int ii=0; ii<iCnt; ii++)
		{
			fy += points[ iNo+ii ].y;
		}
		splineArray[splineCnt++] = CGPointMake(points[iNo].x, (fy / (CGFloat)iCnt)); //過去iCnt個の平均値
	}	
	if (2<iNo) {
		//CGContextAddCurveToPoint
		CGContextSetRGBStrokeColor(cgc, 1, 1, 1, 0.7); // 折れ線の色
		CGContextAddLines(cgc, splineArray, iNo-1);	
		CGContextStrokePath(cgc);
	}
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);
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
		if (po.y-13 <= 0) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-10, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-10, po.y-13, cc, strlen(cc));
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

/*	// グラデーション
	CAGradientLayer *pageGradient = [CAGradientLayer layer];
    pageGradient.frame = rect;
	id c1 = (id)[UIColor colorWithRed:151/255 green:80/255 blue:77/255 alpha:0.3].CGColor;  //端色
	id c2 = (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3].CGColor;		//中央色
    pageGradient.colors = [NSArray arrayWithObjects: c1, c2, c2, c2, c1, nil];
    [self.layer insertSublayer:pageGradient atIndex:0]; //一番下に追加
*/
	
	//--------------------------------------------------------------------------------------- iCloud KVS GOAL!
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	NSInteger iGoal = [[kvs objectForKey:__GoalKey] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	NSInteger iMax = 0;
	NSInteger iMin = 9999;
	if (__Min<=iGoal  &&  iGoal<=__Max) iMin = iGoal, iMax = iGoal;
	
	NSInteger ii;
	for (E2record *e2 in __E2records) {
		if ([e2 valueForKey:__EntityKey]) {
			ii = [[e2 valueForKey:__EntityKey] integerValue];
			if (__Min<=ii && ii<=__Max) {
				if (ii < iMin) iMin = ii;	//NG// else if (iMaxBp < ii) iMaxBp = ii; 1件だけのとき不具合
				if (iMax < ii) iMax = ii;
			}
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
	
	CGFloat fYstep;
	CGPoint po;
	CGPoint	pointsArray[GRAPH_PAGE_LIMIT+20+1];
	long			valuesArray[GRAPH_PAGE_LIMIT+20+1];
	int			arrayNo;
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	
	//-------------------------------------------------------------------------------------- グラフ描画
	if (iMin==iMax) {
		iMin--;
		iMax++;
	}
	fYstep = (rect.size.height - GRAPH_H_GAP*2) / (iMax - iMin);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - iMin);
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = iGoal;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in __E2records) {
		if (po.x <= 0) break;
		if ([e2 valueForKey:__EntityKey]) {
			ii = [[e2 valueForKey:__EntityKey] integerValue];
			if (__Min<=ii && ii<=__Max) {
				po.y = GRAPH_H_GAP + fYstep * (CGFloat)(ii - iMin);
				pointsArray[ arrayNo ] = po;
				valuesArray[ arrayNo ] = ii;
				arrayNo++;
			}
		}
		po.x -= RECORD_WIDTH;
	}
	[self graphDraw:cgc count:arrayNo  points:pointsArray  values:valuesArray  valueType:__Dec];
}


@end
