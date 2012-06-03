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
@synthesize ppPage = __Page;


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
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	BOOL bGoal = [kvs boolForKey:KVS_bGoal];

	
	//-------------------------------------------------------------------------------------- Date 描画
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
	
	CGFloat fZoom = 1.0;
	if (iS_iPAD) {
		fZoom = 1.5;
	}
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);  //kCGTextFillStroke
	// "Helvetica"OK   "Optima"NG
	CGContextSelectFont (cgc, "Helvetica", 12.0*fZoom, kCGEncodingMacRoman); // ＜＜日本語NG 
	// 文字列 カラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, 151.0/295, 80.0/295, 77.0/295, 1.0);//Azukid色の薄め

	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* comp;
	const char *cc;

	CGPoint po;
	po.x = self.bounds.size.width - RECORD_WIDTH/2.0;
	po.y = SPACE_Y;
	
	if (__Page==0) { 
		//Goal
		if (bGoal) {
			cc = [[NSString stringWithString:@"Goal"] UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15*fZoom, po.y+1*fZoom, cc, strlen(cc));
		}
		po.x -= RECORD_WIDTH;
	}

	//Record
	for (E2record *e2 in __E2records) 
	{
		if (po.x <= 0) break;
		if ([e2 valueForKey:E2_dateTime]) 
		{
			// 日次集計											月									日		
			comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit
					| NSHourCalendarUnit | NSMinuteCalendarUnit   fromDate:e2.dateTime];
			
			// 月/日
			cc = [[NSString stringWithFormat:@"%d/%d", comp.month, comp.day] UTF8String];
			if (4 < strlen(cc)) {
				CGContextShowTextAtPoint (cgc, po.x-15*fZoom, po.y+12*fZoom, cc, strlen(cc));
			} else {
				CGContextShowTextAtPoint (cgc, po.x-10*fZoom, po.y+12*fZoom, cc, strlen(cc));
			}
			// 時:分
			cc = [[NSString stringWithFormat:@"%d:%d", comp.hour, comp.minute] UTF8String];
			if (4 < strlen(cc)) {
				CGContextShowTextAtPoint (cgc, po.x-15*fZoom, po.y+1*fZoom, cc, strlen(cc));
			} else {
				CGContextShowTextAtPoint (cgc, po.x-10*fZoom, po.y+1*fZoom, cc, strlen(cc));
			}
			po.x -= RECORD_WIDTH;
		}
	}
}


@end
