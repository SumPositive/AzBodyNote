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
	__unsafe_unretained id						delegate;	
	__strong E2record			*Re2node;
	NSTimeInterval	MintervalPrev;
}
@synthesize delegate;
@synthesize Re2record;
@synthesize PiMinYearMMDD;
@synthesize PiMaxYearMMDD;


#pragma mark - Action

- (void)buttonToday
{
	//MdatePicker.date = [NSDate date]; // Now
	//[MdatePicker setDate:[NSDate date] animated:YES];
}


// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
- (void)done:(id)sender
{

}


#pragma mark - View lifecicle


// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
//【Tips】ここでaddSubviewするオブジェクトは全てautoreleaseにすること。メモリ不足時には自動的に解放後、改めてここを通るので、初回同様に生成するだけ。
- (void)loadView
{
    [super loadView];

#ifdef AzPAD
	self.view.backgroundColor = [UIColor lightGrayColor];
#else
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[self.navigationController setToolbarHidden:YES animated:NO]; // ツールバー消す
#endif

	// DONEボタンを右側に追加する
	// 前画面に[SAVE]があるから、この[DONE]を無くして戻るだけで更新するように試してみたが、
	// 右側にある[DONE]ボタンを押して、また右側にある[SAVE]ボタンを押す流れが安全
	// 左側の[BACK]で戻ると、次に現れる[CANCEL]を押してしまう危険が大きい。
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone  //[DONE]
											  target:self action:@selector(done:)];// autorelease];
	
/*	// とりあえず生成、位置はviewDesignにて決定
	if (Re3edit) {
		//------------------------------------------------------[NOW]ボタン
		MbuToday = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[MbuToday setTitle:NSLocalizedString(@"Today",nil) forState:UIControlStateNormal];
		[MbuToday addTarget:self action:@selector(buttonToday) forControlEvents:UIControlEventTouchDown];
		[self.view addSubview:MbuToday]; //[MbuToday release]; autoreleaseされるため
	}
*/
/*	//------------------------------------------------------[Time]ボタン
	MbuYearTime = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	// Titleは、viewWillAppear:にてセット
	[MbuYearTime addTarget:self action:@selector(buttonYearTime) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:MbuYearTime]; //[MbuYearTime release]; autoreleaseされるため
	if (Re6edit) 
	{
		[MbuYearTime setTitle:NSLocalizedString(@"Due Amount",nil) forState:UIControlStateNormal]; // 表示は逆
		MlbAmount = [[[UILabel alloc] init] autorelease];
		MlbAmount.font = [UIFont systemFontOfSize:20];
		MlbAmount.textAlignment = UITextAlignmentCenter;
		[self.view addSubview:MlbAmount]; // autorelease
	}
	
	//------------------------------------------------------Picker
	//MdatePicker = [[[UIDatePicker alloc] init] autorelease]; iPadでは不具合発生する
	MdatePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake(0,0, 320,216)] autorelease];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"dk_DK"];  // AM/PMを消すため ＜＜実機でのみ有効らしい＞＞
	MdatePicker.locale = locale; 
	[locale release];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	//NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	//[MdatePicker setCalendar:calendar];
	//[calendar release];
	//NG//UIDatePickerの言語表示を変えようと頑張ったがダメだった⇒ http://aosicode.blog94.fc2.com/blog-entry-32.html
	//NG//Pickerが和暦になっても、表示は正しく西暦になるようなので、このままにしておく。

	[self.view addSubview:MdatePicker];  //auto//[MdatePicker release];
	MintervalPrev = [MdatePicker.date timeIntervalSinceReferenceDate]; // 2001/1/1からの秒数
	//------------------------------------------------------
 */
}
/*
- (void)datePickerDidChange:(UIDatePicker *)sender
{
}
*/

// viewWillAppear はView表示直前に呼ばれる。よって、Viewの変化要素はここに記述する。　 　// viewDidAppear はView表示直後に呼ばれる
- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

/*	// 画面表示に関係する Option Setting を取得する
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	MbOptAntirotation = [defaults boolForKey:GD_OptAntirotation];
	MbOptUseDateTime = [defaults boolForKey:GD_OptUseDateTime];

	if (AzMIN_YearMMDD < PiMinYearMMDD) {
		MdatePicker.minimumDate = GdateYearMMDD(PiMinYearMMDD,  0, 0, 0);
	} else {
		MdatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:-365*24*60*60];	// 約1年前から
	}
	if (PiMaxYearMMDD < AzMAX_YearMMDD) {
		MdatePicker.maximumDate = GdateYearMMDD(PiMaxYearMMDD, 23,59,59); 
	} else {
		MdatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:+31*6*24*60*60];	// 約6ヶ月先まで
	}

	if (Re3edit) {
		if (MbOptUseDateTime) {
			[MbuYearTime setTitle:NSLocalizedString(@"Hide Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDateAndTime;
		} else {
			[MbuYearTime setTitle:NSLocalizedString(@"Show Time",nil) forState:UIControlStateNormal]; // 表示は逆
			MdatePicker.datePickerMode = UIDatePickerModeDate;
		}
		MdatePicker.date =Re3edit.dateUse;
	} 
	else { // E6 常に時刻不要
		MdatePicker.datePickerMode = UIDatePickerModeDate;
		NSInteger iYearMMDD = [Re6edit.e2invoice.e7payment.nYearMMDD integerValue];
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone; //[Done]  (デフォルト[Save])
		MdatePicker.date = GdateYearMMDD(iYearMMDD, 0, 0, 0);
		// 金額表示
		// 通貨記号もコンマも無しにする。 ＜＜ラベル文字⇒Decimal数値変換時にエラー発生するため
		MlbAmount.text = [NSString stringWithFormat:@"%@", Re6edit.nAmount];
	}
*/

	//ここでキーを呼び出すと画面表示が無いまま待たされてしまうので、viewDidAppearでキー表示するように改良した。
}

// 画面表示された直後に呼び出される
- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
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
