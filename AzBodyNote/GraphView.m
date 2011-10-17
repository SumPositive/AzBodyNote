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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	//現在のグラフィックスコンテキストを取得
	CGContextRef cgContext = UIGraphicsGetCurrentContext();
	//CGContextTranslateCTM(cgContext, 0, 500);
	//CGContextScaleCTM(cgContext, 1.0, -1.0);
	
	//ストロークカラーの設定(0.0-1.0でRGBAを指定する)
	CGContextSetRGBStrokeColor(cgContext, 0.0, 0.0, 0.0, 1.0);
	//ストロークの線幅を設定
	CGContextSetLineWidth(cgContext, 2.0);
	//カレントポイントから指定した座標に向けて線を引く
	CGContextStrokeEllipseInRect(cgContext, CGRectMake(0.0, 0.0,100.0,100.0));
	//パスに円を追加
	CGContextAddEllipseInRect(cgContext, CGRectMake(0.0, 0.0, 600.0, 600.0));
	//画面に描画
	CGContextStrokePath(cgContext);
	
	//
	CGContextSetRGBStrokeColor(cgContext, 1.0, 0.0, 0.0, 1.0);
	CGPoint lines[] =
	{
		CGPointMake(  0.0,   0.0),
		CGPointMake(70.0, 60.0),
		CGPointMake(130.0, 100.0),
		CGPointMake(190.0, 70.0),
		CGPointMake(250.0, 90.0),
		CGPointMake(310.0, 50.0)
	};
	CGContextAddLines(cgContext, lines, (sizeof(lines)/sizeof(lines[0])));
	//画面に描画
	CGContextStrokePath(cgContext);
}

@end
