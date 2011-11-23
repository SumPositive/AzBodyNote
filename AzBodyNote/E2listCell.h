//
//  E2recordCell.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"


@interface E2listCell : UITableViewCell

@property (nonatomic, retain) E2record		*moE2node;

- (void)draw;

@end
