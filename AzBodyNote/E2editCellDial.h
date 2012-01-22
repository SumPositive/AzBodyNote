//
//  E2editCellDial.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MocEntity.h"
#import "AZDial.h"

@interface E2editCellDial : UITableViewCell <AZDialDelegate>

@property (nonatomic, unsafe_unretained) id						delegate;
@property (nonatomic, unsafe_unretained) UIView				*viewParent;
@property (nonatomic, strong) E2record			*Re2record;		// 結果を戻すため
@property (nonatomic, strong) NSString			*RzKey;			// 結果を戻すため

@property (nonatomic, retain) IBOutlet UILabel			*ibLbName;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbDetail;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbUnit;

@property (nonatomic, assign) NSInteger		mValueMin;
@property (nonatomic, assign) NSInteger		mValueMax;
@property (nonatomic, assign) NSInteger		mValueDec;
//@property (nonatomic, assign) NSInteger		mValueStep;
@property (nonatomic, assign) NSInteger		mValuePrev;

- (IBAction)ibBuValue:(UIButton *)button;
- (IBAction)ibBuNone:(UIButton *)button;

@end
