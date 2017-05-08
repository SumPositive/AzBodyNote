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
@synthesize ppE2records, ppPage, ppRecordWidth;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		if (iS_iPAD) {
			mPadScale = 1.3;
		} else {
			mPadScale = 1.0;
		}
    }
    return self;
}

- (void)imageGraph:(CGContextRef)cgc center:(CGPoint)po  DtOp:(DateOpt)dtop
{
	UIImage *img = nil;
	switch (dtop) {
		case DtOpWake:
			img = [UIImage imageNamed:@"Icon20-Wake"];
			break;
		case DtOpRest:
			img = [UIImage imageNamed:@"Icon20-Rest"];
			break;
		case DtOpDown:
			img = [UIImage imageNamed:@"Icon20-Down"];
			break;
		case DtOpSleep:
			img = [UIImage imageNamed:@"Icon20-Sleep"];
			break;
		case DtOpEnd: // GOAL
			img = [UIImage imageNamed:@"Icon20-Goal"];
			break;
		default:
			return;
	}
	CGRect rc = CGRectMake(po.x-img.size.width/2.0, po.y-img.size.height/2.0, 
						   img.size.width, img.size.height);
	
	CGContextSaveGState(cgc); //PUSH
	{
		CGContextSetAlpha(cgc, 0.7);
		CGContextDrawImage(cgc, rc, img.CGImage);
	}
	CGContextRestoreGState(cgc); //POP
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// E2record
	if ([self.ppE2records count] < 1 OR self.ppRecordWidth <10.0) {
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
	
	//文字列の設定
	CGContextSetTextDrawingMode (cgc, kCGTextFill);  //kCGTextFillStroke
	// "Helvetica"OK   "Optima"NG		＜＜日本語NG 
	CGContextSelectFont (cgc, "Helvetica", 12.0*mPadScale, kCGEncodingMacRoman); // ＜＜日本語NG 
	// 文字列 カラー設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBFillColor (cgc, 151.0/295, 80.0/295, 77.0/295, 1.0);//Azukid色の薄め

	//システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents* comp;
	const char *cc;

	CGPoint po;
	po.x = self.bounds.size.width - self.ppRecordWidth/2.0;
    if (iS_iPAD) {
        po.y = -3.0;	//Base Line
    } else {
        po.y = +4.0;	//Base Line
    }
	
	if (self.ppPage==0) {
		//Goal
		if (bGoal) {
			cc = [@"Goal" UTF8String];
			CGContextShowTextAtPoint (cgc, po.x-15*mPadScale, po.y+22, cc, strlen(cc));
			//アイコン
			CGPoint poImg = po;
			poImg.y += 10;
			[self imageGraph:cgc center:poImg DtOp:DtOpEnd]; //Goal Image
		}
		po.x -= self.ppRecordWidth;
	}

	//Record
	for (E2record *e2 in self.ppE2records) 
	{
		if (po.x <= 0) break;
		if ([e2 valueForKey:E2_dateTime]) 
		{
			// 日次集計											月									日		
			comp = [calendar components: NSMonthCalendarUnit | NSDayCalendarUnit
					| NSHourCalendarUnit | NSMinuteCalendarUnit   fromDate:e2.dateTime];
			
			// 月/日
			cc = [[NSString stringWithFormat:@"%ld/%ld", (long)comp.month, (long)comp.day] UTF8String];
			if (4 < strlen(cc)) {
				CGContextShowTextAtPoint (cgc, po.x-15*mPadScale, po.y+22+12*mPadScale, cc, strlen(cc));
			} else {
				CGContextShowTextAtPoint (cgc, po.x-10*mPadScale, po.y+22+12*mPadScale, cc, strlen(cc));
			}
			// 時:分
			cc = [[NSString stringWithFormat:@"%ld:%ld", (long)comp.hour, (long)comp.minute] UTF8String];
			if (4 < strlen(cc)) {
				CGContextShowTextAtPoint (cgc, po.x-15*mPadScale, po.y+22, cc, strlen(cc));
			} else {
				CGContextShowTextAtPoint (cgc, po.x-10*mPadScale, po.y+22, cc, strlen(cc));
			}
			//アイコン
			CGPoint poImg = po;
			poImg.y += 10;
			[self imageGraph:cgc center:poImg DtOp:[e2.nDateOpt integerValue]];
			
			po.x -= self.ppRecordWidth;
		}
	}
}


@end
