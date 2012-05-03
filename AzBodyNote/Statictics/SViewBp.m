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
@synthesize ppStatType = __StatType;
@synthesize ppDays = __Days;


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
    }
    return self;
}

- (void)drawString:(CGContextRef)cgc  str:(NSString*)str  rect:(CGRect)rect  angle:(float)angle
{
	UILabel *lb = [[UILabel alloc] initWithFrame:rect];
	lb.font = [UIFont systemFontOfSize:10.0];
	lb.text = str;
	lb.textAlignment = UITextAlignmentRight;
	lb.textColor = [UIColor whiteColor];
	lb.backgroundColor = [UIColor clearColor];
	lb.transform = CGAffineTransformMakeRotation( M_PI * angle / 180.0 ); //矩形中心回転
	[self addSubview:lb];
}

- (void)drawValue:(CGContextRef)cgc  value:(NSInteger)value  po:(CGPoint)po  isX:(BOOL)isX
{	// XY軸の値を45度傾斜文字列で描画する
	const char *cc = [[NSString stringWithFormat:@"%ld", (long)value] UTF8String];
	CGFloat fofs = strlen(cc) * 6.0;  //原点を右上にするためのオフセット
	if (isX) {
		// X軸
		if (__StatType==statDispersal24Hour && isX) {  // Hour表示だけ水平にするため
			//po.x -= 2.0;
			po.y -= 14.0;
		} else {
			po.x -= fofs - 12.0;
			po.y -= fofs + 7.0;
		}
	} else {
		// Y軸
		po.x -= fofs - 1.0;
		po.y -= fofs - 7.0;
	}
	CGContextSaveGState(cgc); //PUSH
	{
		CGContextSelectFont (cgc, "Helvetica", 14.0, kCGEncodingMacRoman);
		CGContextSetTextDrawingMode (cgc, kCGTextFill);
		if (isX) {
			CGContextSetRGBFillColor (cgc, 0, 0, 1, 0.5); // 塗り潰し色
		} else {
			CGContextSetRGBFillColor (cgc, 1, 0, 0, 0.5); // 塗り潰し色
		}
		if (__StatType==statDispersal24Hour && isX) {  // Hour表示だけ水平にするため
			CGContextSetTextMatrix (cgc, CGAffineTransformMakeRotation( 0 )); // +0 水平
		} else {
			CGContextSetTextMatrix (cgc, CGAffineTransformMakeRotation( M_PI/4.0 )); // +45
		}
		CGContextShowTextAtPoint (cgc, po.x, po.y, cc, strlen(cc));
	}
	CGContextRestoreGState(cgc); //POP
}

- (void)gradientRect:(CGRect)rect  poStart:(CGPoint)poStart  poEnd:(CGPoint)poEnd
{
	UIGraphicsBeginImageContext(rect.size);		// レイヤー
	// レイヤーを用意します。大きさは、ここでは drawRect に渡された rect を使用します。
	CALayer* layer = [CALayer layer];
	layer.frame = rect;

    CGContextRef context = UIGraphicsGetCurrentContext();   
    CGContextSaveGState(context);
	
/*	CGRect rc = rect;
	rc.origin.x = 0;
	rc.origin.y = 0;
    CGContextAddRect(context, rc);*/
   // CGContextAddRect(context, self.layer.bounds);
	
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {	//R, G, B, Alpha
        0.1f, 0.1f, 0.1f, 0.8f,	//Start Black
        0.8f, 0.8f, 0.8f, 0.8f,	//
        1.0f, 1.0f, 1.0f, 0.8f	//End  White
    };
    CGFloat locations[] = { 0.0f, 0.5f, 1.0f };
	
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
	
    //CGRect frame = self.bounds;
    //CGPoint startPoint = frame.origin;
    //CGPoint endPoint = frame.origin;
    //endPoint.y = frame.origin.y + frame.size.height;
	
    CGGradientRef gradientRef =
	CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
	
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                poStart,
                                poEnd,
                                0); //kCGGradientDrawsAftersEndLocation
	
	// 描画用領域に書き込んだデータを UIImage として取得します。
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	// 描画用領域のデータを取得したら、不要になった描画領域を解放します。
	UIGraphicsEndImageContext();
	// レイヤーに描画データを設定します。
	layer.contents = (id)image.CGImage;
	// レイヤーを UIView 型の view に追加すると、そのビューにレイヤーの内容が表示されます。
	[self.layer addSublayer:layer];
	
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
	
    CGContextRestoreGState(context);
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
	
	// システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	NSInteger  iYear=0, iMM=0, iDD=0;

	//--------------------------------------------------------------------------集計
	// Record
	NSInteger iHi, iLo, iDays;
	CGPoint	po;
	pStatCount = 0; //Init
	iDays = 0;
	for (E2record *e2 in __E2records) 
	{
		// 日次集計											年 | 月 | 日 | 時 | 分
		comp = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
				| NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:e2.dateTime];
		//NSLog(@"<<<%d : %d>>>[%ld]", comp.hour, comp.minute, (long)pValuesCount);
		if (iYear != comp.year OR iMM != comp.month OR iDD != comp.day) {
			if (__Days <= iDays) break;
			iDays++;
			iYear = comp.year, iMM = comp.month, iDD = comp.day;
		}
		
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

		// statDispersal24Hour でも平均処理で使用するため
		po.x = iLo;
		po.y = iHi;
		poStatHiLo[pStatCount] = po;

		if (__StatType==statDispersal24Hour) {
			po.x = comp.hour * 60 + comp.minute; //分
			po.y = iHi;
			poStat24[bpHi][pStatCount] = po;
			po.y = iLo;
			poStat24[bpLo][pStatCount] = po;
		}
		// インクリメント
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
	NSLog(@"pStatCount=%ld,  pValMin[bpHi]=%ld, pValMax[bpHi]=%ld", 
										(long)pStatCount, (long)pValMin[bpHi], (long)pValMax[bpHi]);
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
	CGRect rcPlot = rect; //self.bounds;
	rcPlot.origin.x = 50;
	rcPlot.origin.y = 50;
	rcPlot.size.width -= rcPlot.origin.x;
	rcPlot.size.height -= rcPlot.origin.y;
	
	CGFloat fXstep, fYstep, fStep;
	//--------------------------------------------------------------------------座標
	if (__StatType==statDispersalHiLo) {
		fXstep = rcPlot.size.width / (pValMax[bpLo] - pValMin[bpLo]);	//BpLo
		fYstep = rcPlot.size.height / (pValMax[bpHi] - pValMin[bpHi]); //BpHi
		NSLog(@"rect.size.width=%0.2f, pValMin=%ld, pValMax=%ld", rect.size.width, (long)pValMin, (long)pValMax);
		if (fXstep < fYstep) {	// 縦:横=1:1 にするため小さい方に合わせる
			fStep = fXstep;
		} else {
			fStep = fYstep;
		}
		// エリア全域：高血圧 中等症
		CGContextSetRGBFillColor (cgc, 1, 0.5, 0.5, 1.0);
		CGContextFillRect(cgc, rcPlot);
		// エリア：高血圧 中等症
		CGContextSetRGBFillColor (cgc, 0.9, 0.7, 0.7, 1);
		CGContextFillRect(cgc, CGRectMake(50, 50, fStep*(100-pValMin[bpLo]), fStep*(160-pValMin[bpHi])));
		// エリア：正常血圧
		CGContextSetRGBFillColor (cgc, 0.7, 0.7, 0.9, 1);
		CGContextFillRect(cgc, CGRectMake(50, 50, fStep*(85-pValMin[bpLo]), fStep*(130-pValMin[bpHi])));
		// Y軸 ヨコ線 BpHi
		CGContextSetRGBStrokeColor(cgc, 1, 0, 0, 0.2);
		for (NSInteger val=pValMin[bpHi]; val<=pValMax[bpHi]; val += 10) {
			CGFloat fy = 50 + (val - pValMin[bpHi])*fStep;
			CGContextMoveToPoint(cgc, 50, fy); //原点
			CGContextAddLineToPoint(cgc, rect.size.width, fy);
			CGContextStrokePath(cgc);
			[self drawValue:cgc value:val po:CGPointMake(50, fy) isX:NO];
		}
		// X軸 タテ線 BpLo
		CGContextSetRGBStrokeColor(cgc, 0, 0, 1, 0.2);
		for (NSInteger val=pValMin[bpLo]; val<=pValMax[bpLo]; val += 10) {
			CGFloat fx = 50 + (val - pValMin[bpLo])*fStep;
			CGContextMoveToPoint(cgc, fx, 50); //原点
			CGContextAddLineToPoint(cgc, fx, rect.size.height);
			CGContextStrokePath(cgc);
			[self drawValue:cgc value:val po:CGPointMake(fx, 50) isX:YES];
		}
	}
	else {
		fXstep = rcPlot.size.width / (24*60 + 15);	//24Hour
		fYstep = rcPlot.size.height / (pValMax[bpHi] - pValMin[bpLo]); //BpHi - BpLo
		fStep = 0; //使用しない
/*		// エリア全域：グラデーション背景
		CGRect rc = rcPlot;
		rc.origin.x = 25;
		rc.origin.y = 0;
		rc.size.width = rcPlot.size.width * 0.5;
		[self gradientRect:rc poStart:CGPointMake(rc.origin.x, rc.origin.y+10) 
					 poEnd:CGPointMake(rc.origin.x+rc.size.width, rc.origin.y+10)];
		rc.origin.y = 0;
		rc.origin.x += rc.size.width;
		[self gradientRect:rc poStart:CGPointMake(rc.origin.x+rc.size.width, rc.origin.y+10) 
					 poEnd:CGPointMake(rc.origin.x, rc.origin.y+10)];
 */
		// Y軸 ヨコ線 Bp
		CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.2);
		for (NSInteger val=pValMin[bpLo]; val<=pValMax[bpHi]; val += 10) {
			CGFloat fy = 50 + (val - pValMin[bpLo])*fYstep;
			CGContextMoveToPoint(cgc, 50, fy); //原点
			CGContextAddLineToPoint(cgc, rect.size.width, fy);
			CGContextStrokePath(cgc);
			[self drawValue:cgc value:val po:CGPointMake(50, fy) isX:NO];
		}
		// X軸 タテ線 24Hour
		CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.2);
		for (NSInteger val=0; val<=24*60; val += 60*2) {  // += 2Hour
			CGFloat fx = 50 + (val - 0)*fXstep;
			CGContextMoveToPoint(cgc, fx, 50); //原点
			CGContextAddLineToPoint(cgc, fx, rect.size.height);
			CGContextStrokePath(cgc);
			if (val<24*60) {
				[self drawValue:cgc value:val/60 po:CGPointMake(fx, 50) isX:YES];
			}
		}
	}
	// Y軸 ラベル
	UILabel *lb = [[UILabel alloc] initWithFrame:
				   CGRectMake(-100+15, self.bounds.size.height-100-100, 200, 30)]; //回転中心を考慮
	lb.font = [UIFont systemFontOfSize:12];
	if (__StatType==statDispersalHiLo) {
		lb.text = NSLocalizedString(@"Stat BpHi",nil);
	} else {
		lb.text = NSLocalizedString(@"Stat 24H Bp",nil);
	}
	lb.textColor = [UIColor darkGrayColor];
	lb.textAlignment = UITextAlignmentRight;
	lb.backgroundColor = [UIColor clearColor];
	lb.transform = CGAffineTransformMakeRotation( M_PI/-2.0 ); //矩形中心回転　-90
	[self addSubview:lb];
	// X軸 ラベル
	lb = [[UILabel alloc] initWithFrame:CGRectMake(100, self.bounds.size.height-30 , 200, 20)];
	lb.font = [UIFont systemFontOfSize:12];
	if (__StatType==statDispersalHiLo) {
		lb.text = NSLocalizedString(@"Stat BpLo",nil);
	} else {
		lb.text = NSLocalizedString(@"Stat 24H Hour",nil);
	}
	lb.textColor = [UIColor darkGrayColor];
	lb.backgroundColor = [UIColor clearColor];
	lb.textAlignment = UITextAlignmentRight;
	//lb.transform = CGAffineTransformMakeScale(1.0, -1.0); //上下反転
	[self addSubview:lb];
	// 凡例
	po.y = 7;
	po.x = 50;
	CGContextSetRGBFillColor (cgc, 1.0, 1.0, 0.0, 1); // 塗り潰し色
	CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
	lb = [[UILabel alloc] initWithFrame:CGRectMake(po.x+3, self.bounds.size.height-14, 50, 14)];
	lb.font = [UIFont systemFontOfSize:10];
	lb.text = NSLocalizedString(@"DateOpt Wake",nil);
	lb.textColor = [UIColor darkGrayColor];
	lb.backgroundColor = [UIColor clearColor];
	[self addSubview:lb];

	po.x = 120;
	CGContextSetRGBFillColor (cgc, 1.0, 1.0, 1.0, 1); // 塗り潰し色
	CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
	lb = [[UILabel alloc] initWithFrame:CGRectMake(po.x+3, self.bounds.size.height-14, 50, 14)];
	lb.font = [UIFont systemFontOfSize:10];
	lb.text = NSLocalizedString(@"DateOpt Rest",nil);
	lb.textColor = [UIColor darkGrayColor];
	lb.backgroundColor = [UIColor clearColor];
	[self addSubview:lb];
	
	po.x = 190;
	CGContextSetRGBFillColor (cgc, 0.3, 0.3, 0.9, 1); // 塗り潰し色
	CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
	lb = [[UILabel alloc] initWithFrame:CGRectMake(po.x+3, self.bounds.size.height-14, 50, 14)];
	lb.font = [UIFont systemFontOfSize:10];
	lb.text = NSLocalizedString(@"DateOpt Down",nil);
	lb.textColor = [UIColor darkGrayColor];
	lb.backgroundColor = [UIColor clearColor];
	[self addSubview:lb];
	
	po.x = 260;
	CGContextSetRGBFillColor (cgc, 0, 0, 0, 1); // 塗り潰し色
	CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
	lb = [[UILabel alloc] initWithFrame:CGRectMake(po.x+3, self.bounds.size.height-14, 50, 14)];
	lb.font = [UIFont systemFontOfSize:10];
	lb.text = NSLocalizedString(@"DateOpt Sleep",nil);
	lb.textColor = [UIColor darkGrayColor];
	lb.backgroundColor = [UIColor clearColor];
	[self addSubview:lb];
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	if ([kvs boolForKey:GUD_SettStatAvgShow] && 2<pStatCount) {
		assert(0<pStatCount);
		//--------------------------------------------------------------------------平均 Average
		double dAvgHi = 0.0;
		double dAvgLo = 0.0;
		NSInteger  iCntHi = 0, iCntLo = 0;
		for (NSInteger ii=0; ii < pStatCount; ii++) 
		{
			if (0 < poStatHiLo[ii].y) {
				dAvgHi += poStatHiLo[ii].y;
				iCntHi++;
			}
			if (0 < poStatHiLo[ii].x) {
				dAvgLo += poStatHiLo[ii].x;
				iCntLo++;
			}
		}
		if (1<iCntHi) {
			dAvgHi /= (double)iCntHi;
		} else {
			dAvgHi = 0.0;
		}
		if (1<iCntLo) {
			dAvgLo /= (double)iCntLo;
		} else {
			dAvgLo = 0.0;
		}
		NSLog(@"Average: iCntHi=%d, iCntLo=%d", iCntHi, iCntLo);
		NSLog(@"Average: dAvgHi=%0.4lf, dAvgLo=%0.4lf", dAvgHi, dAvgLo);
		
		//--------------------------------------------------------------------------標準偏 Standard deviations
		double dSdHi = 0.0; //残差
		double dSdLo = 0.0; //残差
		double dd;
		for (NSInteger ii=0; ii < pStatCount; ii++) 
		{
			if (0 < poStatHiLo[ii].y) {
				dd = poStatHiLo[ii].y - dAvgHi;
				dSdHi += (dd * dd);
			}
			if (0 < poStatHiLo[ii].x) {
				dd = poStatHiLo[ii].x - dAvgLo;
				dSdLo += (dd * dd);
			}
		}
		NSLog(@"Residual: dSdHi=%0.4lf, dSdLo=%0.4lf", dSdHi, dSdLo);
		dSdHi = sqrt( dSdHi / (iCntHi * (iCntHi-1)) );
		dSdLo = sqrt( dSdLo / (iCntLo * (iCntLo-1)) );
		NSLog(@"Standard deviations: dSdHi=%0.4lf, dSdLo=%0.4lf", dSdHi, dSdLo);
		//
		CGContextSetRGBStrokeColor(cgc, 1, 1, 1, 0.3);
		if (__StatType==statDispersalHiLo) {
			// BpHi
			if (0.05 < dSdHi) {
				CGContextSetLineWidth(cgc, dSdHi); //太さ
			} else {
				CGContextSetLineWidth(cgc, 0.05); //太さ
			}
			po.x = 50;
			po.y = 50 + (dAvgHi - pValMin[bpHi]) * fStep;
			CGContextMoveToPoint(cgc, po.x, po.y);
			CGContextAddLineToPoint(cgc, rect.size.width, po.y);
			CGContextStrokePath(cgc);
			NSString *zz = [NSString stringWithFormat:NSLocalizedString(@"Stat Avg %lf (%lf)",nil), dAvgHi, dSdHi];
			[self drawString:cgc str:zz
						rect:CGRectMake(self.bounds.size.width-155, self.bounds.size.height-po.y-12, 150,12)
					   angle:0.0];
			// BpLo
			if (0.05 < dSdLo) {
				CGContextSetLineWidth(cgc, dSdLo); //太さ
			} else {
				CGContextSetLineWidth(cgc, 0.05); //太さ
			}
			po.x = 50 + (dAvgLo - pValMin[bpLo]) * fStep;
			po.y = 50;
			CGContextMoveToPoint(cgc, po.x, po.y);
			CGContextAddLineToPoint(cgc, po.x, rect.size.height);
			CGContextStrokePath(cgc);
			zz = [NSString stringWithFormat:NSLocalizedString(@"Stat Avg %lf (%lf)",nil), dAvgLo, dSdLo];
			[self drawString:cgc str:zz 
						rect:CGRectMake(po.x-75-6, 75, 150,12)
					   angle:-90.0];
		} else {
			// BpHi
			if (0.05 < dSdHi) {
				CGContextSetLineWidth(cgc, dSdHi); //太さ
			} else {
				CGContextSetLineWidth(cgc, 0.05); //太さ
			}
			po.x = 50;
			po.y = 50 + (dAvgHi - pValMin[bpLo]) * fYstep; //＜＜※[bpLo]で正しい。 [bpHi]は時刻ベース
			CGContextMoveToPoint(cgc, po.x, po.y);
			CGContextAddLineToPoint(cgc, rect.size.width, po.y);
			CGContextStrokePath(cgc);
			NSString *zz = [NSString stringWithFormat:NSLocalizedString(@"Stat Avg %lf (%lf)",nil), dAvgHi, dSdHi];
			[self drawString:cgc str:zz
						rect:CGRectMake(50, 0, 150,12)
					   angle:0.0];
			// BpLo
			if (0.05 < dSdLo) {
				CGContextSetLineWidth(cgc, dSdLo); //太さ
			} else {
				CGContextSetLineWidth(cgc, 0.05); //太さ
			}
			po.x = 50;
			po.y = 50 + (dAvgLo - pValMin[bpLo]) * fYstep;
			CGContextMoveToPoint(cgc, po.x, po.y);
			CGContextAddLineToPoint(cgc, rect.size.width, po.y);
			CGContextStrokePath(cgc);
			zz = [NSString stringWithFormat:NSLocalizedString(@"Stat Avg %lf (%lf)",nil), dAvgLo, dSdLo];
			[self drawString:cgc str:zz 
						rect:CGRectMake(50, self.bounds.size.height-62, 150,12)
					   angle:0.0];
		}
	}

	//--------------------------------------------------------------------------プロット HiLo
	CGPoint	poBpHi[STAT_DAYS_MAX+STAT_DAYS_SAFE+1];
	CGPoint	poBpLo[STAT_DAYS_MAX+STAT_DAYS_SAFE+1];
	int   iCntBpHi = 0;
	int   iCntBpLo = 0;
	CGContextSetLineWidth(cgc, 1.2); //太さ
	for (NSInteger ii=0; ii < pStatCount; ii++) 
	{
		switch (pDateOpt[ii]) {
			case DtOpWake:
				CGContextSetRGBFillColor (cgc, 1.0, 1.0, 0.0, 1); // 塗り潰し色
				CGContextSetRGBStrokeColor(cgc, 1, 1, 0, 0.5);
				break;
			case DtOpRest:
				CGContextSetRGBFillColor (cgc, 1.0, 1.0, 1.0, 1); // 塗り潰し色
				CGContextSetRGBStrokeColor(cgc, 1, 1, 1, 0.5);
				break;
			case DtOpDown:
				CGContextSetRGBFillColor (cgc, 0.3, 0.3, 0.9, 1); // 塗り潰し色
				CGContextSetRGBStrokeColor(cgc, 0.3, 0.3, 0.9, 0.5);
				break;
			case DtOpSleep:
				CGContextSetRGBFillColor (cgc, 0, 0, 0, 1); // 塗り潰し色
				CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.5);
				break;
			default:
				continue;
				return;
		}
		if (__StatType==statDispersalHiLo) {
			po = poStatHiLo[ii];
			if (0<po.x && 0<po.y) {
				po.x = 50 + (po.x - pValMin[bpLo]) * fStep;
				po.y = 50 + (po.y - pValMin[bpHi]) * fStep;
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
			}
		}
		else {
			// Hi
			po = poStat24[bpHi][ii];
			if (0<=po.x && 0<po.y) {
				po.x = 50 + (po.x - 0) * fXstep;
				po.y = 50 + (po.y - pValMin[bpLo]) * fYstep;
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
				poBpHi[iCntBpHi++] = po;
				CGContextMoveToPoint(cgc, po.x, po.y);
			}
			// Lo
			po = poStat24[bpLo][ii];
			if (0<=po.x && 0<po.y) {
				po.x = 50 + (po.x - 0) * fXstep;
				po.y = 50 + (po.y - pValMin[bpLo]) * fYstep;
				CGContextAddLineToPoint(cgc, po.x, po.y);
				CGContextStrokePath(cgc);
				CGContextFillEllipseInRect(cgc, CGRectMake(po.x-2.5, po.y-2.5, 5, 5));	//円Fill
				poBpLo[iCntBpLo++] = po;
			}
		}
	}
/*	//------------------------------------------------------------------------------時系列線
	CGContextSetLineWidth(cgc, 0.4); //太さ
	//CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 0.4);
	CGContextSetGrayStrokeColor(cgc, 0.1, 0.3);
	if (1<iCntBpHi) {
		CGContextAddLines(cgc, poBpHi, iCntBpHi);
	}
	if (1<iCntBpLo) {
		CGContextAddLines(cgc, poBpLo, iCntBpLo);
	}
	CGContextStrokePath(cgc);
 */
}


@end
