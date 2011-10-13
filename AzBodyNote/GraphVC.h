//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZDial.h"


@interface GraphVC : UIViewController <AZDialDelegate>
{
	IBOutlet UILabel		*ibLbVolume;
	
	AZDial						*mDial;
}

// AZDialDelegate
//- (void)volumeChanged:(NSInteger)volume;


@end
