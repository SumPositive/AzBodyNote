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
		// 丸め指定
		if (mDecBehavior==nil) {
			mDecBehavior = [[NSDecimalNumberHandler alloc]
							initWithRoundingMode: NSRoundBankers		// 偶数丸め
							scale: 0									// 丸めた後の桁数　　0=整数化
							raiseOnExactness: YES			// 精度
							raiseOnOverflow: YES				// オーバーフロー
							raiseOnUnderflow: YES			// アンダーフロー
							raiseOnDivideByZero: YES ];	// アンダーフロー
		}
    }
    return self;
}


- (void)imageGraph:(CGContextRef)cgc center:(CGPoint)po  lineNo:(int)lineNo
{
	UIImage *img = nil;
	switch (lineNo) {
		case 1:	//Wake-up
			img = [UIImage imageNamed:@"Icon20-WakeUp"];
			break;
		case 3:	//For-sleep
			img = [UIImage imageNamed:@"Icon20-ForSleep"];
			break;
		default:
			return;
	}
	CGRect rc = CGRectMake(po.x-img.size.width/2.0, po.y-img.size.height/2.0, 
						   img.size.width, img.size.height);
	CGContextDrawImage(cgc, rc, img.CGImage);
}

- (void)graphDraw:(CGContextRef)cgc 
			count:(int)count
		   points:(const CGPoint *)points  
		   values:(const long *)values  
		valueType:(int)valueType		// 0=Integer  1=Temp(999⇒99.9℃)　　2=Weight(999999g⇒999.99Kg)
		   lineNo:(int)lineNo
{
	//assert(count <= GRAPH_PAGE_LIMIT + );
	CGFloat fColR, fColG, fColB, fAlpha;
	CGFloat fXoffset = 0;
	switch (lineNo) {
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
	}
	CGContextSetRGBStrokeColor(cgc, fColR, fColG, fColB, fAlpha);

	// 折れ線
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults boolForKey:GUD_bGoal]) {
		CGContextAddLines(cgc, points, count);	
	} else {
		// Goalを結ばない  [0]を除き[1]から描画する
		CGContextAddLines(cgc, &points[1], count-1);	
	}
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
	CGContextSetRGBStrokeColor(cgc, fColR, fColG, fColB, 1.0);	// 文字の色
	// グラフ ストロークカラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, fColR, fColG, fColB, 1.0); // Black
	//---------------------------------------------Goal!
	CGPoint po = points[0];
	if (lineNo==2) {
		//目標ヨコ軸
		CGContextSetRGBFillColor(cgc, 0.9, 0.9, 1, 0.2); // White
		CGContextAddRect(cgc, CGRectMake(RECORD_WIDTH/2, po.y-6, po.x-RECORD_WIDTH/2, 12));
		CGContextFillPath(cgc); // パスを塗り潰す
		CGContextSetRGBFillColor (cgc, fColR, fColG, fColB, 1.0);
		// 端点
		CGContextFillEllipseInRect(cgc, CGRectMake(po.x-1.5, po.y-1.5, 3, 3));	//円Fill
		// 数値
		const char *cc;
		switch (valueType) {
			case 1:	// Temp(999⇒99.9℃)  // Weight(9999⇒999.9Kg)
				cc = [[NSString stringWithFormat:@"%0.1f", (float)values[0] / 10.0] cStringUsingEncoding:NSMacOSRomanStringEncoding];
				break;
			default:
				cc = [[NSString stringWithFormat:@"%ld", values[0]] UTF8String];
				break;
		}
		if (po.y-13 <= 0) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-10, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-10, po.y-13, cc, strlen(cc));
		}
	}
	//---------------------------------------------朝夕アイコン表示
	if (lineNo==1 OR lineNo==3) {
		if (1<count && 0<values[1]) {
			[self imageGraph:cgc center:points[1] lineNo:lineNo];
		}
	}
	
	//---------------------------------------------記録プロット
	for (int iNo=1; iNo < count; iNo++) 
	{
		po = points[ iNo ];
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
				break;
		}
		if (po.y-13 <= 0) {	// 上側に表示
			CGContextShowTextAtPoint (cgc, po.x-10+fXoffset, po.y+5, cc, strlen(cc));
		} else {
			CGContextShowTextAtPoint (cgc, po.x-10+fXoffset, po.y-13, cc, strlen(cc));
		}
	}
}

- (NSInteger)integerAverage:(NSInteger)iValSum count:(NSInteger)iCnt
{
	assert(mDecBehavior);
	NSNumber *nVal = [NSNumber numberWithInteger:iValSum];
	NSDecimalNumber* decVal = [NSDecimalNumber decimalNumberWithDecimal:
							   [nVal decimalValue]];
	NSNumber *nCnt = [NSNumber numberWithInteger:iCnt];
	NSDecimalNumber* decCnt = [NSDecimalNumber decimalNumberWithDecimal:
							   [nCnt decimalValue]];
	NSDecimalNumber* decAns = [decVal decimalNumberByDividingBy:decCnt
												   withBehavior:mDecBehavior]; //÷
	return (NSInteger)[decAns doubleValue];
}

NSInteger	mValMin, mValMax;
NSInteger	mVal1, mValSum1, mValCnt1;
NSInteger	mVal2, mValSum2, mValCnt2;
NSInteger	mVal3, mValSum3, mValCnt3;
long				mValues1[GRAPH_DAYS_MAX+20+1];
long				mValues2[GRAPH_DAYS_MAX+20+1];
long				mValues3[GRAPH_DAYS_MAX+20+1];
int				mValuesCount;		//[0]Goal  [1]〜Record
int				mValuesMode;		//(0)3本平均  (1)1本合計  (2)1本平均

- (void)mValuesMake
{
	if (mValuesMode==1) {	//(1)合計
		mVal1 = mValSum1;
		mVal2 = mValSum2;
		mVal3 = mValSum3;
	}
	else {				//(0)(2) 平均　（偶数丸め整数化）
		if (0 < mValSum1 && 1 < mValCnt1) {
			mVal1 = [self integerAverage:mValSum1 count:mValCnt1];
		} else {
			mVal1 = mValSum1;
		}
		
		if (0 < mValSum2 && 1 < mValCnt2) {
			mVal2 = [self integerAverage:mValSum2 count:mValCnt2];
		} else {
			mVal2 = mValSum2;
		}
		
		if (0 < mValSum3 && 1 < mValCnt3) {
			mVal3 = [self integerAverage:mValSum3 count:mValCnt3];
		} else {
			mVal3 = mValSum3;
		}
	}
	
	NSLog(@" 　　mValuesMake:  %ld/%d=%ld,  %ld/%d=%ld,  %ld/%d=%ld",
		  (long)mValSum1, mValCnt1, (long)mVal1, 
		  (long)mValSum2, mValCnt2, (long)mVal2,
		  (long)mValSum3, mValCnt3, (long)mVal3);
	
	if (__Min<=mVal1 && mVal1<=__Max) {
		if (mVal1 < mValMin) mValMin = mVal1;
		if (mValMax < mVal1) mValMax = mVal1;
		mValues1[ mValuesCount ] = mVal1;	// 各平均値、　　歩数は合計
	} else {
		mValues1[ mValuesCount ] = 0;
	}
	
	if (__Min<=mVal2 && mVal2<=__Max) { // Bp夜のみ
		if (mVal2 < mValMin) mValMin = mVal2;
		if (mValMax < mVal2) mValMax = mVal2;
		mValues2[ mValuesCount ] = mVal2;		//Bp夜の平均値
	} else {
		mValues2[ mValuesCount ] = 0;
	}
	
	if (__Min<=mVal3 && mVal3<=__Max) {
		if (mVal3 < mValMin) mValMin = mVal3;
		if (mValMax < mVal3) mValMax = mVal3;
		mValues3[ mValuesCount ] = mVal3;	// 各平均値、　　歩数は合計
	} else {
		mValues3[ mValuesCount ] = 0;
	}
	
	mValuesCount++;
	mValSum1 = 0;
	mValSum2 = 0;
	mValSum3 = 0;
	mValCnt1 = 0;	//平均の母数
	mValCnt2 = 0;	//平均の母数
	mValCnt3 = 0;	//平均の母数
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

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	mGraphDays = [[userDefaults objectForKey:GUD_SettGraphDays] integerValue];

	mValuesMode = 0;  //DateOptモード： 3本値
	if ([__EntityKey isEqualToString:E2_nPedometer]) {
		mValuesMode = 1; // 合計
	}
	else if ([__EntityKey isEqualToString:E2_nWeight_10Kg] 
		OR [__EntityKey isEqualToString:E2_nBodyFat_10p]
		OR [__EntityKey isEqualToString:E2_nSkMuscle_10p]) {
		mValuesMode = 2; // 平均
	}
		
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0;

	//--------------------------------------------------------------------------日次集計
	if (__Min<=iGoal  &&  iGoal<=__Max) {
		mValMin = iGoal;
		mValMax = iGoal;
		mValues1[0] = iGoal;
		mValues2[0] = iGoal;
		mValues3[0] = iGoal;
	} else {
		mValMax = 0;
		mValMin = 9999;
		mValues1[0] = 0;
		mValues2[0] = 0;
		mValues3[0] = 0;
	}
	
	mValuesCount = 1;		//[0]Goal  [1]〜Record
	for (E2record *e2 in __E2records) 
	{
#ifdef DEBUG
		// 日次集計											月									日									時
		comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit
						   fromDate:e2.dateTime];
		NSLog(@"<<<%d/%d : %d>>>[%ld]", comp.month, comp.day, comp.hour, (long)mValuesCount);
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
			NSLog(@"<<%d/%d>>  mValuesCount=%d", iPrevMonth, iPrevDay, mValuesCount);
			iPrevMonth = comp.month;
			iPrevDay = comp.day;
			// 日付が変わったので、前日の集計処理する
			[self mValuesMake];
			if (mGraphDays < mValuesCount) break; // OK
		}
		// 合計
		if ([e2 valueForKey:__EntityKey]) {
			if (mValuesMode==0) {	// 3本：平均
				switch ([e2.nDateOpt integerValue]) {
					case 0: //Wake-up(1)
						mValSum1 += [[e2 valueForKey:__EntityKey] integerValue];
						mValCnt1++;	//平均の母数
						break;
					case 2: //For-sleep(3)
						mValSum3 += [[e2 valueForKey:__EntityKey] integerValue];
						mValCnt3++;	//平均の母数
						break;
					default: //Active(2)
						mValSum2 += [[e2 valueForKey:__EntityKey] integerValue];
						mValCnt2++;	//平均の母数
						break;
				}
			} else {		// 1本：合計または平均　 ＜＜Active(2)へ集計
				mValSum2 += [[e2 valueForKey:__EntityKey] integerValue];
				mValCnt2++;	//平均の母数
			}
		}
	}
	if (0<mValCnt1 OR 0<mValCnt2 OR 0<mValCnt3) {
		NSLog(@"<<%d/%d>>LAST  mValuesCount=%d", iPrevMonth, iPrevDay, mValuesCount);
		// 最終日の集計処理する
		[self mValuesMake];
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
	CGPoint	pointsArray[GRAPH_DAYS_MAX+20+1];
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	
	//--------------------------------------------------------------------------プロット
	if (mValMin==mValMax) {
		mValMin--;
		mValMax++;
	}
	fYstep = (rect.size.height - GRAPH_H_GAP*2) / (mValMax - mValMin);  // 1あたりのポイント数
	CGPoint	points[GRAPH_DAYS_MAX+20+1];
	long			values[GRAPH_DAYS_MAX+20+1];
	int iCount = 1;
	
	//-------------------------3本目　　＜＜2本目よりも下層になるように先に描画している。
	if (mValuesMode==0) {	//For-sleep:黒
		po.x = fXgoal;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - mValMin);
		pointsArray[0] = po;	// The GOAL
		po.x -= RECORD_WIDTH;
		for (int ii = 1; ii < mValuesCount; ii++) {
			if (po.x <= 0) break;
			po.y = GRAPH_H_GAP + fYstep * (CGFloat)(mValues3[ ii ] - mValMin);
			pointsArray[ ii ] = po;
			po.x -= RECORD_WIDTH;
		}
		// Goal
		values[0] = mValues3[0];
		points[0] = pointsArray[0];
		// valuesArray[]<=0 を除外する
		iCount = 1;
		for (int ii=iCount; ii < mValuesCount; ii++) {
			if (0 < mValues3[ii]) {
				values[iCount] = mValues3[ii];
				points[iCount] = pointsArray[ii];
				iCount++;
			}
		}
		//描画
		[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec lineNo:3];
	}
	
	//-------------------------2本目　　＜＜1本目よりも下層になるように先に描画している。
	// Active: 2本目は常に描画
	po.x = fXgoal;
	po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - mValMin);
	pointsArray[0] = po;	// The GOAL
	po.x -= RECORD_WIDTH;
	for (int ii = 1; ii < mValuesCount; ii++) {
		if (po.x <= 0) break;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(mValues2[ ii ] - mValMin);
		pointsArray[ ii ] = po;
		po.x -= RECORD_WIDTH;
	}
	// Goal
	values[0] = mValues2[0];
	points[0] = pointsArray[0];
	// valuesArray[]<=0 を除外する
	iCount = 1;
	for (int ii=iCount; ii < mValuesCount; ii++) {
		if (0 < mValues2[ii]) {
			values[iCount] = mValues2[ii];
			points[iCount] = pointsArray[ii];
			iCount++;
		}
	}
	//描画
	[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec lineNo:2];
	
	//-------------------------1本目
	if (mValuesMode==0) {	//Wake-up:黄
		po.x = fXgoal;
		po.y = GRAPH_H_GAP + fYstep * (CGFloat)(iGoal - mValMin);
		pointsArray[0] = po;	// The GOAL
		po.x -= RECORD_WIDTH;
		for (int ii = 1; ii < mValuesCount; ii++) {
			if (po.x <= 0) break;
			po.y = GRAPH_H_GAP + fYstep * (CGFloat)(mValues1[ ii ] - mValMin);
			pointsArray[ ii ] = po;
			po.x -= RECORD_WIDTH;
		}
		// Goal
		values[0] = mValues1[0];
		points[0] = pointsArray[0];
		// valuesArray[]<=0 を除外する
		iCount = 1;
		for (int ii=iCount; ii < mValuesCount; ii++) {
			if (0 < mValues1[ii]) {
				values[iCount] = mValues1[ii];
				points[iCount] = pointsArray[ii];
				iCount++;
			}
		}
		//描画
		[self graphDraw:cgc count:iCount  points:points values:values valueType:__Dec	 lineNo:1];
	}
}


@end
