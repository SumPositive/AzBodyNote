//
//  EditDateVC.m
//  AzCredit
//
//  Created by 松山 和正 on 10/01/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "EditDateVC.h"


@interface EditDateVC (PrivateMethods)
- (void)viewDesign;
- (void)buttonToday;
- (void)buttonYearTime;
- (void)done:(id)sender;
@end

@implementation EditDateVC
{
	//__unsafe_unretained id						delegate;	
	//__strong E2record			*Re2node;
	//NSTimeInterval	MintervalPrev;
}
@synthesize delegate;
@synthesize CdateSource;
//@synthesize Re2record = e2record_;
//@synthesize PiMinYearMMDD;
//@synthesize PiMaxYearMMDD;
@synthesize ibDatePicker;


#pragma mark - Action

- (IBAction)ibBuToday:(UIButton *)button
{
	//ibDatePicker.date = [NSDate date]; // Now
	[ibDatePicker setDate:[NSDate date] animated:YES];
}


// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{
	//e2record_.dateTime = ibDatePicker.date;
	if ([delegate respondsToSelector:@selector(editDateDone:date:)]) {
		[delegate editDateDone:self date:[ibDatePicker.date copy]];
	}
	[self.navigationController popViewControllerAnimated:YES];	// < 前のViewへ戻る
}


#pragma mark - View lifecicle


// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];
/*
#ifdef AzPAD
	self.view.backgroundColor = [UIColor lightGrayColor];
#else
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
#endif
*/
	// DONEボタンを右側に追加する
	// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
	// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
	// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone  //[DONE]
											  target:self action:@selector(done:)];// autorelease];
	
}

- (void)datePickerDidChange:(UIDatePicker *)sender
{
	
}

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	NSLog(@"CdateSource=%@", CdateSource);
	[ibDatePicker setDate:CdateSource animated:YES];
	
	//self.title = NSLocalizedString(@"Use date",nil);  親側でセット
	//viewWillAppearでキーを表示すると画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}


#pragma mark  View - Unload - dealloc
/*
- (void)dealloc    // 最後に1回だけ呼び出される（デストラクタ）
{
	[super dealloc];
}
*/

@end
