//
//  InformationVC.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import "Global.h"
#import "AzBodyNoteAppDelegate.h"
#import "InformationVC.h"
#import "UIDevice-Hardware.h"

#define ALERT_ToSupportSite	19
#define ALERT_CONTACT			28
#define ALERT_PAID					37


@implementation InformationVC
{
	AzBodyNoteAppDelegate		*appDelegate_;

	IBOutlet UILabel			*ibLbTitle;
	IBOutlet UILabel			*ibLbVersion;
	IBOutlet UILabel			*ibLbNote;
	IBOutlet UIImageView	*ibImgIcon;
	IBOutlet UIButton		*ibBuGoBlog;
	IBOutlet UIButton		*ibBuPostMail;
	IBOutlet UIButton		*ibBuPaid;
	
	UIAlertView						*alertProgress_;
	UIActivityIndicatorView	*alertIndicator_;
}


#pragma mark - AlertProgressOn/Off

- (void)alertProgressOn:(NSString*)zTitle
{
	if (alertProgress_==nil) {
		alertProgress_ = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil]; // deallocにて解放
		if (alertIndicator_==nil) {
			alertIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			alertIndicator_.frame = CGRectMake(0, 0, 50, 50);
		}
		[alertProgress_ addSubview:alertIndicator_];
	}
	[alertProgress_ setTitle:zTitle];
	[alertProgress_ show];
	[alertIndicator_ setFrame:CGRectMake((alertProgress_.bounds.size.width-50)/2, alertProgress_.frame.size.height-75, 50, 50)];
	[alertIndicator_ startAnimating];
}

- (void)alertProgressOff
{
	[alertIndicator_ stopAnimating];
	[alertProgress_ dismissWithClickedButtonIndex:alertProgress_.cancelButtonIndex animated:YES];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		appDelegate_ = (AzBodyNoteAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - StoreKit

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	if (0 < [response.invalidProductIdentifiers count]) {
		NSLog(@"*** invalidProductIdentifiers: アイテムIDが不正");
		return;
	}

	for (SKProduct *product in response.products) 
	{
		[ibBuPaid setTitle:product.localizedTitle forState:UIControlStateNormal];
		ibBuPaid.hidden = NO;
		break; // 1つだけだから
	}	
}

- (void)paymentStart
{
	// 購入処理開始
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:STORE_PRODUCTID_UNLOCK];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
	// インジケータ開始
	[self alertProgressOn:NSLocalizedString(@"Paid Progress",nil)];
}

- (void)paymentCompleate:(SKPaymentTransaction*)tran
{
	NSLog(@"paymentCompleate: productIdentifier=%@", tran.payment.productIdentifier);
	
	if ([tran.payment.productIdentifier isEqualToString:STORE_PRODUCTID_UNLOCK]) {
		// Unlock
		if (appDelegate_.gud_bPaid==NO) {
			appDelegate_.gud_bPaid = YES;
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:GUD_bPaid];
			[[NSUserDefaults standardUserDefaults] synchronize];
			// Compleate !
			[[SKPaymentQueue defaultQueue] finishTransaction:tran]; // 処理完了
			// インジケータ消す
			[self alertProgressOff];
			alertBox(	NSLocalizedString(@"Paid Compleate",nil), nil, @"OK" );
		}
	}
}

- (void)paymentFailed:(SKPaymentTransaction*)tran
{
	NSLog(@"paymentFailed: tran=%@", tran);
	// インジケータ消す
	[self alertProgressOff];
	alertBox(	NSLocalizedString(@"Paid Failed",nil), nil, @"OK" );
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{	// Observer: 
	for (SKPaymentTransaction *tran in transactions)
	{
		switch (tran.transactionState) {
			case SKPaymentTransactionStatePurchasing: // 購入中
				break;
				
			case SKPaymentTransactionStateFailed: // 購入失敗
				[self	paymentFailed:tran];
				break;
				
			case SKPaymentTransactionStatePurchased:	// 購入完了
				[self paymentCompleate:tran];
				break;
				
			case SKPaymentTransactionStateRestored: // 購入済み
				[self paymentCompleate:tran];
				break;
		}
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions 
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//self.title = NSLocalizedString(@"TabInfo",nil);
	ibLbTitle.text = NSLocalizedString(@"InfoTitle",nil);

	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
#ifdef AzSTABLE
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@", zVersion];
#else
	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72Free"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57Free"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@\nFree", zVersion];
#endif
	
	ibLbNote.text = NSLocalizedString(@"InfoNote",nil);

	[ibBuGoBlog setTitle:NSLocalizedString(@"InfoGoBlog",nil) forState:UIControlStateNormal];
	[ibBuPostMail setTitle:NSLocalizedString(@"InfoPostMail",nil) forState:UIControlStateNormal];
	
	// PAID 広告＆制限解除
	ibBuPaid.hidden = YES;
	if (appDelegate_.gud_bPaid==NO && [SKPaymentQueue canMakePayments])
	{
		NSSet *set = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil];
		SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
		req.delegate = self;
		[req start];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	self.view.alpha = 0.3;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (self.view.alpha != 1) { //AddNewのときだけディゾルブ
		// アニメ準備
		CGContextRef context = UIGraphicsGetCurrentContext();
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDuration:TABBAR_CHANGE_TIME];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut]; //Slow at End.
		// アニメ終了状態
		self.view.alpha = 1;
		// アニメ実行
		[UIView commitAnimations];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)ibBuOK:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuGoBlog:(UIButton *)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ToSupportSite",nil)
													message:NSLocalizedString(@"ToSupportSite msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"＜Back"
										  otherButtonTitles:@"Go safari＞", nil];
	alert.tag = ALERT_ToSupportSite;
	[alert show];
	//[alert autorelease];
}

- (IBAction)ibBuPostMail:(UIButton *)button
{
	//メール送信可能かどうかのチェック　　＜＜＜MessageUI.framework が必要＞＞＞
    if (![MFMailComposeViewController canSendMail]) {
		//[self setAlert:@"メールが起動出来ません！":@"メールの設定をしてからこの機能は使用下さい。"];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact NoMail",nil)
														message:NSLocalizedString(@"Contact NoMail msg",nil)
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		//[alert autorelease];
        return;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact mail",nil)
													message:NSLocalizedString(@"Contact mail msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_CONTACT;
	[alert show];
	//[alert autorelease];
}

- (IBAction)ibBuPaid:(UIButton *)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Paid Unlock",nil)
													message:NSLocalizedString(@"Paid Unlock msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
										  otherButtonTitles:NSLocalizedString(@"PAID",nil), nil];
	alert.tag = ALERT_PAID;
	[alert show];
}


#pragma mark - <delegate>

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_ToSupportSite: {
			NSURL *url = [NSURL URLWithString:@"http://HealthyGoo.tumblr.com/"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;
			
		case ALERT_CONTACT: { // Post commens
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			
			// To: 宛先
			NSArray *toRecipients = [NSArray arrayWithObject:@"post@azukid.com"];
			[picker setToRecipients:toRecipients];
			//[picker setCcRecipients:nil];
			//[picker setBccRecipients:nil];
			
			// Subject: 件名		CFBundleDisplayName
			NSString *zSubj = NSLocalizedString(@"InfoTitle",nil);
			[picker setSubject:zSubj];  
			
			// Body: 本文
			NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
			NSString *zBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; //（ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
			NSString* zBody = [NSString stringWithFormat:@"Product: %@\n",  zSubj];
			zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@)\n",  zVersion, zBuild];

			UIDevice *device = [UIDevice currentDevice];
			NSString* deviceID = [device platformString];	
			zBody = [zBody stringByAppendingFormat:@"Device: %@   iOS: %@\n", 
					 deviceID,
					 [[UIDevice currentDevice] systemVersion]]; // OSの現在のバージョン

			NSArray *languages = [NSLocale preferredLanguages];
			zBody = [zBody stringByAppendingFormat:@"Locale: %@ (%@)\n\n",
					 [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
					 [languages objectAtIndex:0]];
			
			zBody = [zBody stringByAppendingString:NSLocalizedString(@"Contact message",nil)];
			[picker setMessageBody:zBody isHTML:NO];
			
			[self presentModalViewController:picker animated:YES];
			//[picker release];
		}	break;

		case ALERT_PAID:
			[self	paymentStart];
			break;
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error 
{
    switch (result){
        case MFMailComposeResultCancelled:
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            break;
        case MFMailComposeResultSent: {
            //送信した場合
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact Sent",nil)
															message:NSLocalizedString(@"Contact Sent msg",nil)
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			//[alert autorelease];
		} break;
        case MFMailComposeResultFailed: {
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact Failed",nil)
															message:NSLocalizedString(@"Contact Failed msg",nil)
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			//[alert autorelease];
		} break;

        default:
            break;
    }
	[self dismissModalViewControllerAnimated:YES];
}

@end
