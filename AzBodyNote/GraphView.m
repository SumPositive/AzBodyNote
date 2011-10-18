//
//  GraphView.m
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/17.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)graphDraw:(CGContextRef)cgc frame:(CGRect)frame
{
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 0.2);
	
	// 外枠
	CGContextAddRect(cgc, frame);
	CGContextStrokePath(cgc);
	
	// 平均軸
	CGFloat fy = frame.origin.y + frame.size.height/2;
	CGContextMoveToPoint(cgc, 0, fy);
	CGContextAddLineToPoint(cgc, frame.size.width, fy);

	// 日付軸
	CGFloat fx = frame.size.width - 60;
	CGContextMoveToPoint(cgc, fx, frame.origin.y);
	CGContextAddLineToPoint(cgc, fx, frame.origin.y + frame.size.height);
	
	//画面に描画
	CGContextStrokePath(cgc);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	//現在のグラフィックスコンテキストを取得
	CGContextRef cgc = UIGraphicsGetCurrentContext();
	// CoreGraphicsの原点が左下なので原点を合わせる
    CGContextTranslateCTM(cgc, 0, rect.size.height);
    CGContextScaleCTM(cgc, 1.0, -1.0);

	CGRect  rc = rect;
	// 最高血圧
	rc.origin.y = rect.size.height - 5 - 70;
	rc.size.height = 70;
	[self graphDraw:cgc frame:rc];
	// 最低血圧
	rc.origin.y -= 70;
	rc.size.height = 70;
	[self graphDraw:cgc frame:rc];
	
	return;

	
	
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgc, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgc, 2.0);
	//カレントポイントから指定した座標に向けて線を引く
	CGContextStrokeEllipseInRect(cgc, CGRectMake(0.0, 0.0,100.0,100.0));
	//パスに円を追加
	CGContextAddEllipseInRect(cgc, CGRectMake(0.0, 0.0, 600.0, 600.0));
	//画面に描画
	CGContextStrokePath(cgc);
	
	//
	CGContextSetRGBStrokeColor(cgc, 1.0, 0.0, 0.0, 1.0);
	CGPoint lines[] =
	{
		CGPointMake(  0.0,   0.0),
		CGPointMake(70.0, 60.0),
		CGPointMake(130.0, 100.0),
		CGPointMake(190.0, 70.0),
		CGPointMake(250.0, 90.0),
		CGPointMake(310.0, 50.0)
	};
	CGContextAddLines(cgc, lines, (sizeof(lines)/sizeof(lines[0])));
	//画面に描画
	CGContextStrokePath(cgc);
	

	CGContextSetRGBFillColor(cgc, 1.0, 0.5, 0.0, 1.0);
    CGContextSetRGBStrokeColor(cgc, 1.0, 0.0, 0.5, 1.0);
    CGContextSetLineWidth(cgc, 10.0);
	
    CGRect r1 = CGRectMake(20.0 , 20.0, 100.0, 100.0);
    CGContextAddEllipseInRect(cgc,r1);
    CGContextFillPath(cgc);
	
    CGContextMoveToPoint(cgc, 50, 100);
    CGContextAddLineToPoint(cgc, 150, 100);
    CGContextAddLineToPoint(cgc, 50, 200);
    CGContextAddLineToPoint(cgc, 150, 200);
    CGContextStrokePath(cgc);
	
    CGContextMoveToPoint(cgc,50, 250);
    CGContextAddCurveToPoint(cgc, 
							 100, 250, 100, 200, 150, 250);
    CGContextAddCurveToPoint(cgc, 
							 200, 350, 50, 250, 50, 350);
    CGContextStrokePath(cgc);
}

@end
