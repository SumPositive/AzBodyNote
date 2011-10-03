//
//  E2editCellValue.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E2editCellValue : UITableViewCell
{
	NSNumber		*RnValue;
	NSInteger		mValueMin;
	NSInteger		mValueMax;
	NSInteger		mValueRate; //倍率　　double = mValue / mValueRate
	NSInteger		mValueStep; //増減単位
	
@private
	NSInteger		mSliderBase;
	NSInteger		mValue;
}

@property (nonatomic, retain) IBOutlet UILabel			*ibLbName;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbValue;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbUnit;
@property (nonatomic, retain) IBOutlet UISlider			*ibSrValue;		//.tagセットするため
@property (nonatomic, retain) IBOutlet UIButton			*ibBuValue;		//.tagセットするため

@property (nonatomic, retain) NSNumber		*RnValue;		// 結果を戻すため
@property (nonatomic, assign) NSInteger		mValueMin;
@property (nonatomic, assign) NSInteger		mValueMax;
@property (nonatomic, assign) NSInteger		mValueRate;
@property (nonatomic, assign) NSInteger		mValueStep;

// (IBAction) は、E2editTVC をオーナーにする。
//- (IBAction)ibBuValue:(UIButton *)button;
//- (IBAction)ibSrValueChange:(UISlider *)slider;

@end
