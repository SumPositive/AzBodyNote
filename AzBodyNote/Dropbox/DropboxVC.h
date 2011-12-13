//
//  DropboxVC.h
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//
// "Security.framework" が必要
//
#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import <DropboxSDK/JSON.h>

#define DBOX_KEY					@"qq4oke7nx6f8ivj"
#define DBOX_SECRET			@"dq48qqerkqz9sen"
#define DBOX_EXTENSION		@"condition"		//@"Condition"

@interface DropboxVC : UIViewController <UITableViewDelegate, UITableViewDataSource, 
UITextFieldDelegate, DBRestClientDelegate, UIActionSheetDelegate>
{
	IBOutlet UIButton		*ibBuClose;
	IBOutlet UIButton		*ibBuSave;
	IBOutlet UITextField	*ibTfName;

	IBOutlet UISegmentedControl	*ibSegSort;
	IBOutlet UITableView	*ibTableView;

	id		delegate;
	//NSString			*mLocalPath;		//= "(HOME)/tmp/MyKeyboard.CalcRoll" or ".CalcRollPad"
	DBRestClient	*restClient;
	NSMutableArray		*mMetadatas;
	UIActivityIndicatorView	*mActivityIndicator;
	UIAlertView						*mAlert;
	NSIndexPath					*mDidSelectRowAtIndexPath;
	//BOOL						bPad;
	//NSString					*mRootPath;
}

@property (nonatomic, strong) id					delegate;
//@property (nonatomic, strong) NSString		*mLocalPath;

- (IBAction)ibBuClose:(UIButton *)button;
- (IBAction)ibBuSave:(UIButton *)button;
- (IBAction)ibSegSort:(UISegmentedControl *)segment;

@end
