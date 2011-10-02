//
//  E2editCellValue.h
//  AzBodyNote
//
//  Created by Sum Positive on 11/10/02.
//  Copyright 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface E2editCellValue : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel			*ibLbName;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbValue;
@property (nonatomic, retain) IBOutlet UILabel			*ibLbUnit;
@property (nonatomic, retain) IBOutlet UISlider			*ibSrValue;		//.tagセットするため
@property (nonatomic, retain) IBOutlet UIButton			*ibBuValue;		//.tagセットするため

// (IBAction) は、E2editTVC をオーナーにする。
//- (IBAction)ibBuValue:(UIButton *)button;
//- (IBAction)ibSrValueChange:(UISlider *)slider;

@end
