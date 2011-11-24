//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ViewTAG_BpHi			301
#define ViewTAG_BpLo			302
#define ViewTAG_Puls			303
#define ViewTAG_Weight		304
#define ViewTAG_Temp		305

@interface GraphVC : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UILabel				*ibLbBpHi;
	IBOutlet UILabel				*ibLbBpLo;
	IBOutlet UILabel				*ibLbPuls;
	IBOutlet UILabel				*ibLbWeight;
	IBOutlet UILabel				*ibLbTemp;
}

@end
