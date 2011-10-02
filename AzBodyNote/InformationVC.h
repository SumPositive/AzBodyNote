//
//  InformationVC.h
//  AzSplitIt-Xc4.1
//
//  Created by 松山 和正 on 11/09/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InformationVC : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	//IBOutlet UIButton		*ibBuOK;
	//IBOutlet UIButton		*ibBuGoSupport;
	//IBOutlet UIButton		*ibBuGoMail;
	
	IBOutlet UILabel				*ibLbVersion;
	
@private
	
}

- (IBAction)ibBuOK:(UIButton *)button;
- (IBAction)ibBuGoSupport:(UIButton *)button;
- (IBAction)ibBuGoMail:(UIButton *)button;

@end
