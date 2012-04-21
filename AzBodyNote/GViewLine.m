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
			   cR:(CGFloat)colRed
			   cG:(CGFloat)colGreen
			   cB:(CGFloat)colBlue
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	CGContextSetRGBStrokeColor(cgc, colRed, colGreen, colBlue, 0.5); // Bp夜の折れ線の色
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
	
/*	// 移動平均スプライン曲線
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
		CGContextSetRGBStrokeColor(cgc, 1, 1, 1, 0.5); // 折れ線の色
		CGContextAddLines(cgc, splineArray, iNo-1);	
		CGContextStrokePath(cgc);
	}
 */
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman);
	CGContextSetRGBStrokeColor(cgc, colRed, colGreen, colBlue, 1.0);	// 文字の色
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, colRed, colGreen, colBlue, 1.0); // Black
	// 記録プロット
	for (int iNo=0; iNo < count; iNo++) 
	{
		CGPoint po = points[ iNo ];
		if (iNo==0) {	//[0]Goal! 目標
			//---------------------------------------------Goal! 目標ヨコ軸
			CGContextSetRGBFillColor(cgc, 0.9, 0.9, 1, 0.2); // White
			CGContextAddRect(cgc, CGRectMake(RECORD_WIDTH/2, po.y-6, po.x-RECORD_WIDTH/2, 12));
			CGContextFillPath(cgc); // パスを塗り潰す
			CGContextSetRGBFillColor (cgc, colRed, colGreen, colBlue, 1.0);
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
	NSInteger iGoal = [[kvs objectForKey: __GoalKey] integerValue];  // NSNullならば "<null>"文字列となり数値化して0になる
	NSInteger iBloodHour = [[kvs objectForKey: @"BloodHour"] integerValue];
	if (iBloodHour <= 0) iBloodHour = 12;

	int iMode = 0; // 既定モード： 平均
	if ([__EntityKey isEqualToString:E2_nBpHi_mmHg] 
		OR [__EntityKey isEqualToString:E2_nBpLo_mmHg]) {
		iMode = 1; // 血圧モード： 朝夜別平均
	}
	else if ([__EntityKey isEqualToString:E2_nPedometer]) {
		iMode = 2; // 歩数モード： 合計
	}
		
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0, iHour;

	// 丸め指定
	NSDecimalNumberHandler *decBehavior = [[NSDecimalNumberHandler alloc]
										initWithRoundingMode: NSRoundBankers		// 偶数丸め
										scale: 0									// 丸めた後の桁数　　0=整数化
										raiseOnExactness: YES			// 精度
										raiseOnOverflow: YES				// オーバーフロー
										raiseOnUnderflow: YES			// アンダーフロー
										raiseOnDivideByZero: YES ];	// アンダーフロー

	//--------------------------------------------------------------------------集計
	long			valuesArray[GRAPH_PAGE_LIMIT+20+1];
	long			valuesArray2[GRAPH_PAGE_LIMIT+20+1];
	NSInteger iMax = 0;
	NSInteger iMin = 9999;
	if (__Min<=iGoal  &&  iGoal<=__Max) {
		iMin = iGoal, iMax = iGoal;
		valuesArray[0] = iGoal;
		valuesArray2[0] = iGoal;
	}
	
	NSInteger  iVal, iValSum=0, iCnt=0;
	NSInteger  iVal2, iValSum2=0, iCnt2=0;
	int	arrayCnt = 1;		//[0]Goal  [1]〜Record
	for (E2record *e2 in __E2records) 
	{
		if ([e2 valueForKey:__EntityKey]) 
		{
			// 日次集計											月									日									時
			comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit
							   fromDate:e2.dateTime];
			if (iMode != 1) {
				iHour = 0;
			} else if (comp.hour < iBloodHour) {
				iHour = 1; //朝
			} else {
				iHour = 2; //夜
			}
			if (iPrevMonth==0) {	// 最初1度だけ初期化
				iPrevMonth = comp.month;
				iPrevDay = comp.day;
			}
			else if (iPrevMonth != comp.month OR iPrevDay != comp.day) {
				NSLog(@"%d/%d  arrayCnt=%d,  iValSum=%ld/%d, %ld/%d",
					  iPrevMonth, iPrevDay, arrayCnt, (long)iValSum, iCnt, (long)iValSum2, iCnt2);
				if (iMode != 2) {		//(2)歩数でない⇒歩数は合計のまま
					if (0 < iValSum && 1 < iCnt) {
						// 平均　（偶数丸め整数化）
						NSNumber *nVal = [NSNumber numberWithInteger:iValSum];
						NSDecimalNumber* decVal = [NSDecimalNumber decimalNumberWithDecimal:
												   [nVal decimalValue]];
						NSNumber *nCnt = [NSNumber numberWithInteger:iCnt];
						NSDecimalNumber* decCnt = [NSDecimalNumber decimalNumberWithDecimal:
												   [nCnt decimalValue]];
						NSDecimalNumber* decAns = [decVal decimalNumberByDividingBy:decCnt
																		  withBehavior:decBehavior]; //÷
						iVal = (NSInteger)[decAns doubleValue];
					} else {
						iVal = iValSum;
					}
					
					if (0 < iValSum2 && 1 < iCnt2) {
						// 平均　（偶数丸め整数化）
						NSNumber *nVal = [NSNumber numberWithInteger:iValSum2];
						NSDecimalNumber* decVal = [NSDecimalNumber decimalNumberWithDecimal:
													[nVal decimalValue]];
						NSNumber *nCnt = [NSNumber numberWithInteger:iCnt2];
						NSDecimalNumber* decCnt = [NSDecimalNumber decimalNumberWithDecimal:
												   [nCnt decimalValue]];
						NSDecimalNumber* decAns = [decVal decimalNumberByDividingBy:decCnt
																			withBehavior:decBehavior]; //÷
						iVal2 = (NSInteger)[decAns doubleValue];
					} else {
						iVal2 = iValSum2;
					}
				} else {
					iVal = iValSum;
					iVal2 = iValSum2;
				}
				NSLog(@"         -----> iVal=%ld, %ld / %d", (long)iVal, (long)iVal2, iCnt);
				if (__Min<=iVal && iVal<=__Max) {
					if (iVal < iMin) iMin = iVal;
					if (iMax < iVal) iMax = iVal;
					valuesArray[ arrayCnt ] = iVal;	// 各平均値、　　歩数は合計
				} else {
					valuesArray[ arrayCnt ] = 0;
				}
				if (__Min<=iVal2 && iVal2<=__Max) { // Bp夜のみ
					if (iVal2 < iMin) iMin = iVal2;
					if (iMax < iVal2) iMax = iVal2;
					valuesArray2[ arrayCnt ] = iVal2;		//Bp夜の平均値
				} else {
					valuesArray2[ arrayCnt ] = 0;
				}
				arrayCnt++;
				if (GRAPH_PAGE_LIMIT < arrayCnt) break; // OK
				iPrevMonth = comp.month;
				iPrevDay = comp.day;
				iValSum = 0;
				iValSum2 = 0;
				iCnt = 0;	//平均の母数
				iCnt2 = 0;	//平均の母数
			}
			// 合計
			if (iHour==2) { //Bp夜
				iValSum2 += [[e2 valueForKey:__EntityKey] integerValue];
				iCnt2++;	//平均の母数
			} else {
				iValSum += [[e2 valueForKey:__EntityKey] integerValue];
				iCnt++;	//平均の母数
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
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	
	//--------------------------------------------------------------------------プロット
	if (iMin==iMax) {
		iMin--;
		iMax++;
	}
	fYstep = (rect.size.height - GRAPH_H_GAP*2) / (iMax - iMin);  // 1あたりのポイント数
	po.x = fXgoal;
	po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - iMin);
	pointsArray[0] = po;	// The GOAL
	po.x -= RECORD_WIDTH;
	for (int ii = 1; ii < arrayCnt; ii++) {
		if (po.x <= 0) break;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(valuesArray[ ii ] - iMin);
		pointsArray[ ii ] = po;
		po.x -= RECORD_WIDTH;
	}
	// valuesArray[]<=0 を除外する
	CGPoint	points[GRAPH_PAGE_LIMIT+20+1];
	long			values[GRAPH_PAGE_LIMIT+20+1];
	points[0] = pointsArray[0];
	values[0] = valuesArray[0];
	int iCount = 1;
	for (int ii=1; ii < arrayCnt; ii++) {
		if (0 < valuesArray[ii]) {
			values[iCount] = valuesArray[ii];
			points[iCount] = pointsArray[ii];
			iCount++;
		}
	}
	//描画
	if (iMode==1) {
		[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec	 cR:1 cG:1 cB:1];
	} else {
		[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec cR:0 cG:0 cB:1];
	}

	if (iMode==1) {	// values2: Bp夜の平均値
		po.x = fXgoal;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - iMin);
		pointsArray[0] = po;	// The GOAL
		po.x -= RECORD_WIDTH;
		for (int ii = 1; ii < arrayCnt; ii++) {
			if (po.x <= 0) break;
			po.y = GRAPH_H_GAP + fYstep * (CGFloat)(valuesArray2[ ii ] - iMin);//Bp夜の平均値
			pointsArray[ ii ] = po;
			po.x -= RECORD_WIDTH;
		}
		// valuesArray[]<=0 を除外する
		iCount = 1;
		for (int ii=1; ii < arrayCnt; ii++) {
			if (0 < valuesArray2[ii]) {
				values[iCount] = valuesArray2[ii];
				points[iCount] = pointsArray[ii];
				iCount++;
			}
		}
		//描画
		[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec cR:0 cG:0 cB:0];
	}
}


@end
