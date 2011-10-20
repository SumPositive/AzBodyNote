//
//  InformationVC.h
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InformationVC : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

- (IBAction)ibBuOK:(UIButton *)button;
- (IBAction)ibBuGoSupport:(UIButton *)button;
- (IBAction)ibBuGoMail:(UIButton *)button;

@end
