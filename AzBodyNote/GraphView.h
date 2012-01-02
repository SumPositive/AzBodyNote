//
//  GraphView.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/17.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRAPH_H_GAP			5.0		// グラフの最大および最小の極限余白
#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ

@interface GraphView : UIView

@property (nonatomic, retain) NSArray	*RaE2records;
//@property (nonatomic, assign) NSInteger	iOverLeft;		// スクロール範囲外（左側）に表示するレコード数
//@property (nonatomic, assign) NSInteger	iOverRight;		// スクロール範囲外（右側）に表示するレコード数

- (IBAction)ibSegTypeChange:(UISegmentedControl *)seg;

@end
