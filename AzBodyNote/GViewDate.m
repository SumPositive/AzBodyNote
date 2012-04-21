//
//  GViewDate.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewDate.h"
#import "GraphVC.h"

@implementation GViewDate
@synthesize ppE2records = __E2records;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	mGraphDays = [[userDefaults objectForKey:GUD_SettGraphDays] integerValue];

	CGPoint po;
	CGPoint	pointsArray[GRAPH_DAYS_MAX+20+1];
	long			valuesArray[GRAPH_DAYS_MAX+20+1];
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0;

	po.x = fXgoal;
	po.y = GRAPH_H_GAP;
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = 0;	// The GOAL
	NSInteger iVal = 0;
	int	arrayCnt = 1;		//[0]Goal  [1]〜Record
	for (E2record *e2 in __E2records) {
		if (po.x <= 0) break;
		if ([e2 valueForKey:E2_dateTime]) 
		{
			// 日次集計											月									日		
			comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit
							   fromDate:e2.dateTime];
			if (iPrevMonth==0) {	// 最初1度だけ初期化
				iPrevMonth = comp.month;
				iPrevDay = comp.day;
			}
			else if (iPrevMonth != comp.month OR iPrevDay != comp.day) {
				po.x -= RECORD_WIDTH;
				pointsArray[ arrayCnt ] = po;
				valuesArray[ arrayCnt ] = iVal;
				arrayCnt++;
				if (mGraphDays < arrayCnt) break; // OK
				iPrevMonth = comp.month;
				iPrevDay = comp.day;
			}
		}
		iVal = comp.month * 100 + comp.day;
	}
	// 描画
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, rect);
	// 領域の下線
	CGRect rc = rect; //self.bounds;
	rc.origin.y = 1;  //rc.size.height - 3;
	rc.size.height = 2;
	CGContextSetRGBFillColor (cgc, 0.75, 0.75, 0.75, 1.0);
	CGContextFillRect(cgc, rc);
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);  //kCGTextFillStroke
	// "Helvetica"OK   "Optima"NG
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman); // ＜＜日本語NG 
	// 文字列 カラー設定(0.0-1.0でRGBAを指定する)
	//CGContextSetRGBStrokeColor(cgc, 151.0/255, 80.0/255, 77.0/255, 1.0); //文字の色
	//CGContextSetRGBFillColor (cgc, 151.0/255, 80.0/255, 77.0/255, 1.0);
	CGContextSetRGBFillColor (cgc, 151.0/295, 80.0/295, 77.0/295, 1.0);

	for (int iNo=0; iNo < arrayCnt; iNo++) 
	{
		CGPoint po = pointsArray[ iNo ];
		// 数値
		long val = valuesArray[ iNo ];
		//NSLog(@"graphDrawDate: [ %d ]=%ld=(%.2f, %.2f)", iNo, val, po.x, po.y);
		
		const char *cc;
		if (val < 100) {
			//cc = [[NSString stringWithString:NSLocalizedString(@"TheGoal",nil)] UTF8String]; ＜＜日本語NG
			cc = [[NSString stringWithString:@"GOAL"] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+1, cc, strlen(cc));
		}
		else {
			int iMonth = val / 100;
			val -= iMonth * 100;
			int iDay = val;
			//val -= iDay * 10000;
			//int iHour = val / 100;
			//val -= iHour * 100;
			//int iMinute = val;
			
			cc = [[NSString stringWithFormat:@"%d/%d", iMonth, iDay] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+1, cc, strlen(cc));
			
			//cc = [[NSString stringWithFormat:@"%02d:%02d", iHour, iMinute] UTF8String];
			//CGContextShowTextAtPoint (cgc, po.x-15, po.y+0, cc, strlen(cc));
		}
	}
}


@end
