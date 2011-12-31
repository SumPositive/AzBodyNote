//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRAPH_PAGE_LIMIT			50		// グラフ表示の最大レコード数　＜＜有料版にてページ移動可能にする予定
#define RECORD_WIDTH				44.0		// 1レコード分の幅

@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	IBOutlet UILabel				*ibLbWeight;
	IBOutlet UILabel				*ibLbTemp;
}

@end
