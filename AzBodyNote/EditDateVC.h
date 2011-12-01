//
//  EditDateVC.h
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"


@interface EditDateVC : UIViewController

@property (nonatomic, unsafe_unretained) id		delegate;
//@property (nonatomic, retain) E2record			*Re2record;
@property (nonatomic, copy) NSDate					*CdateSource;
//@property (nonatomic, assign) NSInteger		PiMinYearMMDD;
//@property (nonatomic, assign) NSInteger		PiMaxYearMMDD;

@property (nonatomic, retain) IBOutlet UIDatePicker		*ibDatePicker;

- (IBAction)ibBuToday:(UIButton *)button;

@end

@protocol EditDateDelegate <NSObject>
- (void)editDateDone:(id)sender  date:(NSDate*)date;
@end
