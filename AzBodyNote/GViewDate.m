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
	
	CGPoint po;
	CGPoint	pointsArray[GRAPH_PAGE_LIMIT+20+1];
	long			valuesArray[GRAPH_PAGE_LIMIT+20+1];
	int			arrayNo;
	CGFloat	fXgoal = self.bounds.size.width - RECORD_WIDTH/2;		// 最初、GOALを中央に表示する
	//-------------------------------------------------------------------------------------- Date 描画
	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
	po.x = fXgoal;
	po.y = GRAPH_H_GAP;
	pointsArray[0] = po;	// The GOAL
	valuesArray[0] = 0;	// The GOAL
	po.x -= RECORD_WIDTH;
	arrayNo = 1;
	for (E2record *e2 in __E2records) {
		if (po.x <= 0) break;
		if (e2.dateTime) {
			pointsArray[ arrayNo ] = po;
			NSDateComponents *comp = [calendar components:unitFlags fromDate:e2.dateTime];
			valuesArray[ arrayNo ] = comp.month * 1000000 + comp.day * 10000 + comp.hour * 100 + comp.minute;
			//NSLog(@"valuesArray[ %d ]=%ld", arrayNo, valuesArray[ arrayNo ]);
			arrayNo++;
			assert(arrayNo < GRAPH_PAGE_LIMIT+20+1);
		}
		po.x -= RECORD_WIDTH;
	}
	//[self graphDrawDate:cgc count:arrayNo points:pointsArray values:valuesArray];	
	
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
	CGContextTranslateCTM(cgc, 0, rect.size.height);
	CGContextScaleCTM(cgc, 1.0, -1.0);
	//　全域クリア
	CGContextSetRGBFillColor (cgc, 0.67, 0.67, 0.67, 1.0); // スクロール領域外と同じグレー
	CGContextFillRect(cgc, self.bounds);
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFillStroke);
	CGContextSelectFont (cgc, "Helvetica", 12.0, kCGEncodingMacRoman); // ＜＜日本語NG

	for (int iNo=0; iNo < arrayNo; iNo++) 
	{
		CGPoint po = pointsArray[ iNo ];
		// 数値
		long val = valuesArray[ iNo ];
		//NSLog(@"graphDrawDate: [ %d ]=%ld=(%.2f, %.2f)", iNo, val, po.x, po.y);
		// 文字列 カラー設定(0.0-1.0でRGBAを指定する)
		CGContextSetRGBStrokeColor(cgc, 0, 0, 0, 1.0);
		CGContextSetRGBFillColor (cgc, 0, 0, 0, 1.0);
		const char *cc;
		if (val < 1000000) {
			//cc = [[NSString stringWithString:NSLocalizedString(@"TheGoal",nil)] UTF8String]; ＜＜日本語NG
			cc = [[NSString stringWithString:@"GOAL"] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+14, cc, strlen(cc)); //P.1
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+14+self.bounds.size.height, cc, strlen(cc)); //P.2
		}
		else {
			int iMonth = val / 1000000;
			val -= iMonth * 1000000;
			int iDay = val / 10000;
			val -= iDay * 10000;
			int iHour = val / 100;
			val -= iHour * 100;
			int iMinute = val;
			
			cc = [[NSString stringWithFormat:@"%d/%d", iMonth, iDay] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+20, cc, strlen(cc));
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+20+self.bounds.size.height, cc, strlen(cc));
			
			cc = [[NSString stringWithFormat:@"%02d:%02d", iHour, iMinute] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+8, cc, strlen(cc));
			CGContextShowTextAtPoint (cgc, po.x-15, po.y+8+self.bounds.size.height, cc, strlen(cc));
		}
	}
}


@end
