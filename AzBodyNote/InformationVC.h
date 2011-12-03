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
{
	IBOutlet UILabel			*ibLbTitle;
	IBOutlet UILabel			*ibLbVersion;
	IBOutlet UILabel			*ibLbNote;
	
	IBOutlet UIButton		*ibBuGoBlog;
	IBOutlet UIButton		*ibBuPostMail;
}

- (IBAction)ibBuGoBlog:(UIButton *)button;
- (IBAction)ibBuPostMail:(UIButton *)button;

@end
