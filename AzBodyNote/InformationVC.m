//
//  InformationVC.m
//  AzSplitIt-Xc4.1
//
//  Created by 松山 和正 on 11/09/25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "InformationVC.h"
#import "UIDevice-Hardware.h"

#define ALERT_ToSupportSite	19
#define ALERT_CONTACT			28

@implementation InformationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    // Do any additional setup after loading the view from its nib.

	NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	ibLbVersion.text = [NSString stringWithFormat:@"Version %@", zVersion];
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

- (IBAction)ibBuGoSupport:(UIButton *)button
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ToSupportSite",nil)
													message:NSLocalizedString(@"ToSupportSite msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"＜Back"
										  otherButtonTitles:@"Go safari＞", nil];
	alert.tag = ALERT_ToSupportSite;
	[alert show];
	[alert autorelease];
}

- (IBAction)ibBuGoMail:(UIButton *)button
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
		[alert autorelease];
        return;
    }
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact mail",nil)
													message:NSLocalizedString(@"Contact mail msg",nil)
												   delegate:self		// clickedButtonAtIndexが呼び出される
										  cancelButtonTitle:@"Cancel"
										  otherButtonTitles:@"OK", nil];
	alert.tag = ALERT_CONTACT;
	[alert show];
	[alert autorelease];
}


#pragma mark - <delegate>

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != 1) return; // Cancel
	// OK
	switch (alertView.tag) 
	{
		case ALERT_ToSupportSite: {
			NSURL *url = [NSURL URLWithString:@"http://splitpay.tumblr.com/"];
			[[UIApplication sharedApplication] openURL:url];
		}	break;
			
		case ALERT_CONTACT: { // Post commens
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			
			// To: 宛先
			NSArray *toRecipients = [NSArray arrayWithObject:@"SplitPay@azukid.com"];
			[picker setToRecipients:toRecipients];
			//[picker setCcRecipients:nil];
			//[picker setBccRecipients:nil];
			
			// Subject: 件名		CFBundleDisplayName
			NSString *zSubj = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
			[picker setSubject:zSubj];  
			
			// Body: 本文
			NSString *zVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; //（リリース バージョン）は、ユーザーに公開した時のレベルを表現したバージョン表記
			NSString *zBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]; //（ビルド回数 バージョン）は、ユーザーに非公開のレベルも含めたバージョン表記
			NSString* zBody = [NSString stringWithFormat:@"Product: %@\n",  zSubj];
			zBody = [zBody stringByAppendingFormat:@"Version: %@ (%@)\n",  zVersion, zBuild];

			UIDevice *device = [UIDevice currentDevice];
			NSString* deviceID = [device platformString];	
			zBody = [zBody stringByAppendingFormat:@"Device: %@   iOS: %@\n\n", 
					 deviceID,
					 [[UIDevice currentDevice] systemVersion]]; // OSの現在のバージョン
			
			zBody = [zBody stringByAppendingString:NSLocalizedString(@"Contact message",nil)];
			[picker setMessageBody:zBody isHTML:NO];
			
			[self presentModalViewController:picker animated:YES];
			[picker release];
		}	break;
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
			[alert autorelease];
		} break;
        case MFMailComposeResultFailed: {
            //[self setAlert:@"メール送信失敗！":@"メールの送信に失敗しました。ネットワークの設定などを確認して下さい"];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Contact Failed",nil)
															message:NSLocalizedString(@"Contact Failed msg",nil)
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert autorelease];
		} break;

        default:
            break;
    }
	[self dismissModalViewControllerAnimated:YES];
}

@end
