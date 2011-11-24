//
//  GraphView.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/17.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRAPH_H_GAP			2.0		// グラフの最大および最小の極限余白
#define SEPARATE_HEIGHT	3.0		// 区切り線の高さ

@interface GraphView : UIView

@property (nonatomic, retain) NSArray	*RaE2records;

- (IBAction)ibSegTypeChange:(UISegmentedControl *)seg;

@end
