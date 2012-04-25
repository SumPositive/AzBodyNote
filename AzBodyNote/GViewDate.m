//
//  GViewDate.m
//  AzBodyNote
//
//  Created by 松山 masa on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GViewDate.h"
#import "GraphVC.h"

#define SPACE_Y				5.0


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
	
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	mGraphDays = [[kvs objectForKey:GUD_SettGraphDays] integerValue];
	BOOL bGoal = [kvs boolForKey:GUD_bGoal];

	
	CGPoint po;
	CGPoint	pointsArray[GRAPH_DAYS_MAX+20+1];
	long			valuesArray[GRAPH_DAYS_MAX+20+1];
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	int iPrevMonth = 0, iPrevDay = 0;

	//[VA_GOAL0]Goal
	po.x = fXgoal;
	po.y = SPACE_Y;
	pointsArray[VA_GOAL] = po;	// The GOAL
	valuesArray[VA_GOAL] = 0;	// The GOAL
	//[VA_AVE]Avg.
	po.x -= RECORD_WIDTH;
	pointsArray[VA_AVE] = po;
	valuesArray[VA_AVE] = 0;
	//[VA_REC]〜Record
	NSInteger iVal = 0;
	int	arrayCnt = VA_REC; //[VA_REC]〜Record
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
				iVal = 0;	//終端処理されないように
				if (mGraphDays+VA_REC <= arrayCnt) break; // OK
				iPrevMonth = comp.month;
				iPrevDay = comp.day;
			}
		}
		iVal = comp.month * 100 + comp.day;
	}
	//終端
	if (0 < iVal) {
		po.x -= RECORD_WIDTH;
		pointsArray[ arrayCnt ] = po;
		valuesArray[ arrayCnt ] = iVal;
		arrayCnt++;
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
	CGContextSetRGBFillColor (cgc, 151.0/295, 80.0/295, 77.0/295, 1.0);//Azukid色の薄め

	for (int iNo=0; iNo < arrayCnt; iNo++) 
	{
		CGPoint po = pointsArray[ iNo ];
		// 数値
		long val = valuesArray[ iNo ];
		//NSLog(@"graphDrawDate: [ %d ]=%ld=(%.2f, %.2f)", iNo, val, po.x, po.y);
		
		const char *cc;
		if (iNo==VA_GOAL) {	//Goal
			if (bGoal) {
				cc = [[NSString stringWithString:@"GOAL"] UTF8String];
				CGContextShowTextAtPoint (cgc, po.x-15, po.y+1, cc, strlen(cc));
			}
		}
		else if (iNo==VA_AVE) {	//Avg.
			cc = [[NSString stringWithString:@"Average"] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-20, po.y+1, cc, strlen(cc));
		}
		else {
			assert(VA_REC<=iNo);
			int iMonth = val / 100;
			val -= iMonth * 100;
			int iDay = val;
			cc = [[NSString stringWithFormat:@"%d/%d", iMonth, iDay] UTF8String];
			if (4 < strlen(cc)) {
				CGContextShowTextAtPoint (cgc, po.x-15, po.y+1, cc, strlen(cc));
			} else {
				CGContextShowTextAtPoint (cgc, po.x-10, po.y+1, cc, strlen(cc));
			}
		}
	}
}


@end
