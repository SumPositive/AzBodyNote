//
//  InformationVC.m
//	AzBodyNote
//
//  Created by Sum Positive on 2011/10/01.
//  Copyright 2011 Sum Positive@Azukid.com. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"		// <SKPaymentTransactionObserver>
#import "InformationVC.h"
#import "UIDevice-Hardware.h"

#define ALERT_ToSupportSite	19
#define ALERT_CONTACT			28
#define ALERT_PAID					37


@implementation InformationVC
{
	AppDelegate		*appDelegate_;

	IBOutlet UILabel			*ibLbTitle;
	IBOutlet UILabel			*ibLbVersion;
	IBOutlet UILabel			*ibLbNote;
	IBOutlet UIImageView	*ibImgIcon;
	IBOutlet UIButton		*ibBuGoBlog;
	IBOutlet UIButton		*ibBuPostMail;
	IBOutlet UIButton		*ibBuPaid;
	
	//SKProductsRequest		*mProductRequest;
	//SKProduct						*productUnlock_;
	//UIActivityIndicatorView	*mProductIndicator;
}


/***　通らない
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}***/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (appDelegate_==nil) {
		appDelegate_ = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	}
	// インジケータ開始 ＜＜＜ここで一回表示しなければ、インジケータ位置が定まらない（原因不明のため対処療法）
//	[appDelegate_  alertProgressOn: NSLocalizedString(@"Please wait",nil)];
	
	//self.title = NSLocalizedString(@"TabInfo",nil);
	ibLbTitle.text = NSLocalizedString(@"InfoTitle",nil);

	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

	if (72 <= ibImgIcon.frame.size.width) {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon72"]];
	} else {
		[ibImgIcon setImage:[UIImage imageNamed:@"Icon57"]];
	}
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@", zVersion];
	
	ibLbNote.text = NSLocalizedString(@"InfoNote",nil);

	[ibBuGoBlog setTitle:NSLocalizedString(@"InfoGoBlog",nil) forState:UIControlStateNormal];
	[ibBuPostMail setTitle:NSLocalizedString(@"InfoPostMail",nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	GA_TRACK_PAGE(@"InformationVC");
	appDelegate_.app_is_AdShow = NO; //これは広告表示しないViewである。 viewWillAppear:以降で定義すること
	// インジケータ終了
//	[appDelegate_	alertProgressOff];
	self.view.alpha = 0.3;
	
/*	// PAID 広告＆制限解除
	ibBuPaid.hidden = YES;
	if (mProductRequest) {
		[mProductRequest cancel];			// 中断
		mProductRequest.delegate = nil;  // これないと、通信中に閉じると落ちる
	}
	
	if (appDelegate_.app_is_sponsor==NO)
	{
		if (mProductIndicator==nil) {
			mProductIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			mProductIndicator.frame = ibBuPaid.frame;
			[self.view addSubview:mProductIndicator];
		}
		[mProductIndicator startAnimating];
		
		if ([SKPaymentQueue canMakePayments]) { // 課金可能であるか確認する
			// 課金可能
			// 商品情報リクエスト ---> productsRequest:didReceiveResponse:が呼び出される
			NSSet *set = [NSSet setWithObjects:STORE_PRODUCTID_UNLOCK, nil]; // 商品が複数ある場合は列記
			mProductRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
			mProductRequest.delegate = self;		//viewDidUnloadにて、cancel, nil している。さもなくば落ちる
			[mProductRequest start];
		}
	}*/
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload		//＜＜実験では、呼ばれなかった！
{
	//[mProductIndicator stopAnimating];
    [super viewDidUnload];
}
/*
- (void)dealloc 
{	// 必ず最後に呼ばれる
	[mProductIndicator stopAnimating], mProductRequest = nil;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:appDelegate_]; // これが無いと、しばらくすると落ちる
	if (mProductRequest) {
		[mProductRequest cancel];			// 中断
		mProductRequest.delegate = nil;  // これないと、通信中に閉じると落ちる
	}
}*/

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
/*
- (IBAction)ibBuPaid:(UIButton *)button
{
	if (appDelegate_.app_is_sponsor) {	// 購入済み
		alertBox(NSLocalizedString(@"SK Restored",nil), nil, @"OK");
		ibBuPaid.hidden = YES;
		return;
	}

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"SK Paid",nil)
													message: NSLocalizedString(@"SK Paid msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles: NSLocalizedString(@"SK Paid next",nil), nil];
	alert.tag = ALERT_PAID;
	[alert show];
}*/


#pragma mark - <delegate>

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_ToSupportSite: {
			NSURL *url = [NSURL URLWithString:@"http://Condition.azukid.com/"];
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
			if (appDelegate_.app_is_sponsor) {
				zSubj = [zSubj stringByAppendingString:@"  (Sponsor)"];
			} else {
				zSubj = [zSubj stringByAppendingString:@"  (Trial)"];
			}
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
			zBody = [zBody stringByAppendingFormat:@"Locale: %@ (%@)\n",
					 [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier],
					 [languages objectAtIndex:0]];

			zBody = [zBody stringByAppendingFormat:@"Records: %ld\n\n", appDelegate_.app_e2record_count];
			
			zBody = [zBody stringByAppendingString: NSLocalizedString(@"Contact message",nil)];
			[picker setMessageBody:zBody isHTML:NO];
			
			[self presentModalViewController:picker animated:YES];
			//[picker release];
		}	break;
			
/*		case ALERT_PAID:
		{
			// アドオン購入処理開始　　　　　　　<SKPaymentTransactionObserver>は、AppDelegateに実装
			assert(appDelegate_);
			if (productUnlock_) {
				[[SKPaymentQueue defaultQueue] addTransactionObserver: appDelegate_];
				//SKPayment *payment = [SKPayment paymentWithProductIdentifier: STORE_PRODUCTID_UNLOCK]; <<<Deprecated
				SKPayment *payment = [SKPayment paymentWithProduct:productUnlock_];
				[[SKPaymentQueue defaultQueue] addPayment:payment];
			}
		} break;*/
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

/*
#pragma mark - <SKProductsRequestDelegate>
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{	// 商品情報を取得して購入ボタン表示などを整える
	[mProductIndicator stopAnimating];
	
	if (0 < [response.invalidProductIdentifiers count]) {
		NSLog(@"*** invalidProductIdentifiers: アイテムIDが不正");
		return;
	}
	
	for (SKProduct *product in response.products) 
	{
		productUnlock_ = product;
		[ibBuPaid setTitle:product.localizedTitle forState:UIControlStateNormal];
		ibBuPaid.hidden = NO;
		//NSLog(@"productsRequest: product: [%@] [%@]", product.localizedTitle, product.localizedDescription);
		break; // 1つだけだから
	}	
}*/


@end
