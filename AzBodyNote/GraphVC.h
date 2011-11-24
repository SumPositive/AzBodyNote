//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RECORD_LIMIT			50	// グラフ表示の最大レコード数　＜＜有料版にて100かつページ移動可能にする予定
#define RECORD_WIDTH	44.0		// 1レコード分の幅
#define MARGIN_WIDTH		160.0	// 左右端の余白幅

@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	IBOutlet UILabel				*ibLbWeight;
	IBOutlet UILabel				*ibLbTemp;
}

@end
