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
#import <StoreKit/StoreKit.h>


@interface InformationVC : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate,
														SKProductsRequestDelegate>	// <SKPaymentTransactionObserver>は、AzBodyNoteAppDelegateに実装

- (IBAction)ibBuGoBlog:(UIButton *)button;
- (IBAction)ibBuPostMail:(UIButton *)button;
- (IBAction)ibBuPaid:(UIButton *)button;

@end
