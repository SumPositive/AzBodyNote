//
//  DropboxView.m
//  AzCalc-Xc4.2
//
//  Created by Sum Positive on 11/11/03.
//  Copyright (c) 2011 AzukiSoft. All rights reserved.
//
#import "DropboxVC.h"

#define TAG_ACTION_Save			109
#define TAG_ACTION_Retrieve		118

#define USER_FILENAME			@"My Condition"
#define USER_FILENAME_KEY	@"Dropbox_FileName"

@implementation DropboxVC
@synthesize delegate;
//@synthesize mLocalPath;


#pragma mark - Alert

- (void)alertIndicatorOn:(NSString*)zTitle
{
	[mAlert setTitle:zTitle];
	[mAlert show];
	[mActivityIndicator setFrame:CGRectMake((mAlert.bounds.size.width-50)/2, mAlert.bounds.size.height-75, 50, 50)];
	[mActivityIndicator startAnimating];
}

- (void)alertIndicatorOff
{
	[mActivityIndicator stopAnimating];
	[mAlert dismissWithClickedButtonIndex:mAlert.cancelButtonIndex animated:YES];
}

- (void)alertCommError
{
	UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox CommError", nil) 
												   message:NSLocalizedString(@"Dropbox CommErrorMsg", nil) 
												  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
	[alv show];
}

#pragma mark - Dropbox DBRestClient

- (DBRestClient *)restClient 
{
	if (!restClient) {
		restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
	return restClient;
}


#pragma mark - IBAction

- (IBAction)ibBuClose:(UIButton *)button
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ibBuSave:(UIButton *)button
{
	GA_TRACK_METHOD
	NSString *filename = [ibTfName.text stringByDeletingPathExtension]; // 拡張子を除く
	if ([filename length] < 3) {
		UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox NameLeast", nil) 
													  message:NSLocalizedString(@"Dropbox NameLeastMsg", nil)  
													  delegate:nil cancelButtonTitle:nil 
											 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
		[alv show];
		return;
	}
	
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs setObject: toNSNull(filename) forKey:USER_FILENAME_KEY];
	[kvs synchronize]; // iCloud最新同期（取得）
	
	// 上書き確認
	mOverWriteRev = nil;
	for (DBMetadata *dbm in  mMetadatas) {
		if ([filename  isEqualToString:[dbm.filename stringByDeletingPathExtension]]) {  // 拡張子を除く
			mOverWriteRev = dbm.rev;  // OverWrite Revision
			break;
		}
	}
	
	NSString *destructiveButtonTitle = nil;
	NSString *otherButtonTitle = nil;
	if (mOverWriteRev) {
		destructiveButtonTitle = NSLocalizedString(@"Dropbox OverWrite", nil); // 上書き保存　＜＜ overWriteRev_を使ってアップロード
		otherButtonTitle = NSLocalizedString(@"Dropbox Sequential", nil); // 連番を付けて保存
	} else {
		otherButtonTitle = NSLocalizedString(@"Dropbox Save", nil); // 新規保存
	}
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle: filename  //NSLocalizedString(@"Dropbox Are you sure", nil) 
													delegate:self 
										   cancelButtonTitle: NSLocalizedString(@"Cancel", nil) 
									  destructiveButtonTitle: destructiveButtonTitle
										   otherButtonTitles: otherButtonTitle, nil];
	as.tag = TAG_ACTION_Save;
	[as showInView:self.view];
	[ibTfName resignFirstResponder]; // キーボードを隠す
}

- (IBAction)ibSegSort:(UISegmentedControl *)segment
{
	GA_TRACK_METHOD
	[self alertIndicatorOn:NSLocalizedString(@"Dropbox Communicating", nil)];
	[[self restClient] loadMetadata:@"/"];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	//ibTfName.delegate = self;   IBにて定義済み
	//ibTableView.delegate = self;
	
	ibTfName.keyboardType = UIKeyboardTypeDefault;
	ibTfName.returnKeyType = UIReturnKeyDone;
	
	// alertIndicatorOn: alertIndicatorOff: のための準備
	//[mAlert release];
	mAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil]; // deallocにて解放
	//[self.view addSubview:mAlert];　　alertIndicatorOn:にてaddSubviewしている。
	//[mActivityIndicator release];
	mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	mActivityIndicator.frame = CGRectMake(0, 0, 50, 50);
	[mAlert addSubview:mActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	//NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	//ibTfName.text = [userDef objectForKey:USER_FILENAME_KEY];
	NSUbiquitousKeyValueStore *kvs = [NSUbiquitousKeyValueStore defaultStore];
	[kvs synchronize]; // iCloud最新同期（取得）
	ibTfName.text = toNil([kvs objectForKey:USER_FILENAME_KEY]);

	if ([ibTfName.text length] < 3) {
		ibTfName.text = USER_FILENAME;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	[self alertIndicatorOn:NSLocalizedString(@"Dropbox Communicating", nil)];
	// Dropbox/App/CalcRoll 一覧表示
	[[self restClient] loadMetadata:@"/"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

#pragma mark unload

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
/*
- (void)dealloc 
{
	[mDidSelectRowAtIndexPath release], mDidSelectRowAtIndexPath = nil;
	[mActivityIndicator release];
	[mAlert release];
	[mMetadatas release], mMetadatas = nil;
    [super dealloc];
}*/


#pragma mark - Dropbox <DBRestClientDelegate>

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata 
{	// メタデータ読み込み成功
	mOverWriteRev = nil;
	
    if (metadata.isDirectory) {
#ifdef DEBUG
        NSLog(@"Folder '%@' contains:", metadata.path);
		for (DBMetadata *file in metadata.contents) {
			NSLog(@"\t%@", file.filename);
		}
#endif
		//[mMetadatas release], 
		mMetadatas = nil;
		if (0 < [metadata.contents count]) {
			//mMetadatas = [[NSMutableArray alloc] initWithArray:metadata.contents];
			mMetadatas = [NSMutableArray new];
			for (DBMetadata *dbm in metadata.contents) {
				if ([[dbm.filename pathExtension] caseInsensitiveCompare:DBOX_EXTENSION]==NSOrderedSame) { // 大小文字区別なく比較する
					[mMetadatas addObject:dbm];
				}
			}
			// Sorting
			if (ibSegSort.selectedSegmentIndex==0) { // Name Asc
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"filename" ascending:YES];
				NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
				//[sort1 release];
				[mMetadatas sortUsingDescriptors:sorting]; // 降順から昇順にソートする
				//[sorting release];
			} else { // Date Desc
				NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"lastModifiedDate" ascending:NO];
				NSArray *sorting = [[NSArray alloc] initWithObjects:sort1,nil];
				//[sort1 release];
				[mMetadatas sortUsingDescriptors:sorting]; // 降順から昇順にソートする
				//[sorting release];
			}
			[ibTableView reloadData];
		}
	}
	// 必ず通ること。
	[self alertIndicatorOff];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error 
{	// メタデータ読み込み失敗
    NSLog(@"Error loading metadata: %@", error);
	//[mMetadatas release];
	mMetadatas = nil;
	[ibTableView reloadData];
	//
	[self alertIndicatorOff];
	[self alertCommError];
}


- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath 
{	// ファイル読み込み成功
    NSLog(@"File loaded into path: %@", localPath); //== [apd tmpFilePath]
	// File Load
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(queue, ^{		// 非同期マルチスレッド処理
		// ファイルを読み込む
		AppDelegate* apd = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		NSString *zErr = [apd tmpFileLoad];
		
		dispatch_async(dispatch_get_main_queue(), ^{	// 終了後の処理
			if (zErr==nil) {
				// Done
				UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox QuoteDone", nil)
															  message:nil
															 delegate:nil
													cancelButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
				[alv	show];
			}
			else {
				// NG
				UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox QuoteErr", nil)
															  message:zErr
															 delegate:nil
													cancelButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
				[alv	show];
			}
			[self alertIndicatorOff];	// 進捗サインOFF
			[self dismissModalViewControllerAnimated:YES];	// 閉じる
		});
	});
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error 
{	// ファイル読み込み失敗
    NSLog(@"There was an error loading the file - %@", error);
	[self alertIndicatorOff];
	[self alertCommError];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
			  from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{	// ファイル書き込み成功
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
	// Dropbox/App/CalcRoll 一覧表示
	[[self restClient] loadMetadata:@"/"];
	[self alertIndicatorOff];
	UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox SaveDone", nil) 
												   message:nil  delegate:nil cancelButtonTitle:nil 
										 otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
	[alv show];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error 
{	// ファイル書き込み失敗
    NSLog(@"File upload failed with error - %@", error);
	[self alertIndicatorOff];
	[self alertCommError];
}



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			if (0 < [mMetadatas count]) {
				return [mMetadatas count];
			} else {
				return 1;
			}
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier];
    }
	
	switch (indexPath.section) {
		case 0: {
			if (0 < [mMetadatas count]) {
				DBMetadata *dbm = [mMetadatas objectAtIndex:indexPath.row];
				cell.textLabel.text = [dbm.filename stringByDeletingPathExtension]; // 拡張子を除く
				//日時表示予定// dbm.lastModifiedDate
			} else {
				cell.textLabel.text = NSLocalizedString(@"Dropbox NoFile", nil);
			}
		} break;
	}
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (0<=indexPath.row && indexPath.row<[mMetadatas count]) 
	{
		GA_TRACK_METHOD
		//[mDidSelectRowAtIndexPath release], 
		mDidSelectRowAtIndexPath = nil;
		DBMetadata *dbm = [mMetadatas objectAtIndex:indexPath.row];
		if (dbm) {
			mDidSelectRowAtIndexPath = [indexPath copy];
			NSLog(@"dbm.filename=%@", dbm.filename);
			/*　リビジョン連番が追記されるのを避けるため。
			ibTfName.text = [dbm.filename stringByDeletingPathExtension];
			 NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
			[userDef setObject:ibTfName.text  forKey:USER_FILENAME_KEY];
			[userDef synchronize];
			*/
			UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Dropbox Are you sure", nil) 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											   destructiveButtonTitle:NSLocalizedString(@"Dropbox Change", nil) 
													otherButtonTitles:nil];
			as.tag = TAG_ACTION_Retrieve;
			[as showInView:self.view];
		}
		else {
			[ibTableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択解除
		}
	}
	else {
		[ibTableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択解除
	}
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder]; // キーボードを隠す
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
replacementString:(NSString *)string 
{
	// senderは、MtfName だけ
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
	// 置き換えた後の長さをチェックする
	if ([text length] <= 40) {
		//appDelegate.AppUpdateSave = YES; // 変更あり
		//self.navigationItem.rightBarButtonItem.enabled = YES; // 変更あり [Save]有効
		return YES;
	} else {
		return NO;
	}
}


#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (mDidSelectRowAtIndexPath) {
		@try {
			[ibTableView deselectRowAtIndexPath:mDidSelectRowAtIndexPath animated:YES]; // 選択解除
		}
		@catch (NSException *exception) {
			NSLog(@"ERROR");
		}
	}

	if (buttonIndex==actionSheet.cancelButtonIndex) return; // CANCEL
	
	switch (actionSheet.tag) {
		case TAG_ACTION_Save: {	// 保存
			NSString *filename = [ibTfName.text stringByDeletingPathExtension]; // 拡張子らしきものがあれば除く
			filename = [filename stringByAppendingPathExtension:DBOX_EXTENSION]; // 改めて拡張子を付ける
			NSLog(@"TAG_ACTION_Save: filename=%@", filename);
			[self alertIndicatorOn:NSLocalizedString(@"Dropbox Communicating", nil)];
			if (buttonIndex != actionSheet.destructiveButtonIndex) { // otherbutton
				// < Overwrite > しない！
				mOverWriteRev = nil; // 連番を付けて保存
			}
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			dispatch_async(queue, ^{		// 非同期マルチスレッド処理
				// ファイルへ書き出す
				AppDelegate* apd = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				NSString *zErr = [apd tmpFileSave];
				
				dispatch_async(dispatch_get_main_queue(), ^{	// 終了後の処理
					if (zErr==nil) {
						// Upload開始		// mOverWriteRev=nil ならば連番付加追記
						[[self restClient] uploadFile:filename toPath:@"/" withParentRev:mOverWriteRev fromPath:[apd tmpFilePath]];
					}
					else {
						[self alertIndicatorOff];	// 進捗サインOFF
						// NG
						UIAlertView *alv = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dropbox SaveErr", nil)
																	  message:zErr
																	 delegate:nil
															cancelButtonTitle:nil
															otherButtonTitles:NSLocalizedString(@"Roger", nil), nil];
						[alv	show];
					}
				});
			});
		} break;
			
		case TAG_ACTION_Retrieve:		// リストア
			if (mDidSelectRowAtIndexPath && mDidSelectRowAtIndexPath.row < [mMetadatas count]) {
				DBMetadata *dbm = [mMetadatas objectAtIndex:mDidSelectRowAtIndexPath.row];
				if (dbm) {
					AppDelegate* apd = (AppDelegate*)[[UIApplication sharedApplication] delegate];
					[self alertIndicatorOn:NSLocalizedString(@"Dropbox Communicating", nil)];
					NSLog(@"dbm.path=%@ --> [apd tmpFilePath]=%@", dbm.path, [apd tmpFilePath]);
					[[self restClient] loadFile:dbm.path intoPath:[apd tmpFilePath]]; // DownLoad開始 ---> delagate loadedFile:
				}
			}
			break;
	}
}


@end
