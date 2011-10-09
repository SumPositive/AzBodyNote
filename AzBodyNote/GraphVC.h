//
//  GraphVC.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZVolume.h"


@interface GraphVC : UIViewController <AZVolumeDelegate>
{
	IBOutlet UILabel		*ibLbVolume;
	
	AZVolume				*mVolume;
}

// AZVolumeDelegate
//- (void)volumeChanged:(NSInteger)volume;


@end
