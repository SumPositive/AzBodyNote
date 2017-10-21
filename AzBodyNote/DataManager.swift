//
//  DataManager.swift
//  AzBodyNote
//
//  Created by 松山正和 on 2017/10/08.
//

import Foundation



class DataManager: NSObject {

    ////////////////////////////////////////////////////////////////
    // MARK: - Public value
    
    
    
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Private value
    private static let singleInstance = DataManager() // シングルトン・インタンス --> 初期処理 init()

    let ICLOUD_CONTAINER = "iCloud.com.azukid.AzBodyNote"
    let ICLOUD_FILENAME = "Condition_1.data"
    

    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - Public func
    class func singleton() -> DataManager! {
        return singleInstance;
    }
    

    
    ////////////////////////////////////////////////////////////////
    // MARK: - Private func
    struct E2codable: Codable {
        let title: String
        let publicTime: String
        let forecasts: [Forecast]
        let location: WeatherLocation
        let description: WeatherDescription
    }
    
    // シングルトン・インスタンスの初期処理
    private override init() {
        //シングルトン保証// privateにすることにより他から初期化させない
        // Initialize a instance
    }
    
    // E2 ---> JSON
    // E2を全てJSON文字列に変換する
    func jsonFromE2( e2:E2record ) -> String! {
        //    // Sort条件
        //    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:E2_dateTime ascending:NO];
        //    NSArray *sortDesc = [NSArray arrayWithObjects: sort1,nil]; // 日付降順：Limit抽出に使用
        //    NSArray *aE2records = [mocFunc_ select: E2_ENTITYNAME
        //                                      limit: 0
        //                                     offset: 0
        //                                      where: [NSPredicate predicateWithFormat:E2_nYearMM @" > 200000"] // 未保存を除外する
        //                                       sort: sortDesc]; // 最新日付から抽出
        //    // NSManagedObject を NSDictionary変換する。　JSON変換できるようにするため
        let sort1 = NSSortDescriptor(key: E2_dateTime, ascending: false)
        guard let mocFunc = MocFunctions.shared() else {
            return ""
        }
        guard let aE2records:Array = mocFunc.select(
            E2_ENTITYNAME,
            limit: 0,
            offset: 0,
            where: NSPredicate(format: E2_nYearMM + " > 200000"), // 未保存を除外する
            sort: [sort1])
            else {
                return ""
        }

        //    // E2record
        //    for (E2record *e2 in aE2records) {
        //        //NSLog(@"----- e2=%@", e2);
        //        @autoreleasepool {
        //            NSDictionary *dic = [mocFunc_ dictionaryObject:e2];
        //            if (dic) {
        //                //NSLog(@"----- ----- dic=%@", dic);
        //                [maE2 addObject:dic];    // #class = "E2record"
        //            }
        //        }
        //    }
        var maE2:[Dictionary<String,Any>] = []
        for e2 in aE2records as Array {
            let e2obj = e2 as! NSManagedObject
            guard let dic = mocFunc.dictionaryObject(e2obj) else {
                continue
            }
            maE2.append(dic as! Dictionary)
        }
        
        //
        //    // NSArray --> JSON
        //    DBJSON    *js = [DBJSON new];
        //    NSError *err = nil;
        //    NSString *zJson = [js stringWithObject:maE2 error:&err];
        //    if (err) {
        //        NSLog(@"tmpFileSave: SBJSON: stringWithObject: (err=%@) zJson=%@", [err description], zJson);
        //        GA_TRACK_EVENT_ERROR([err description],0);
        //        return [err description];
        //    }
        //    NSLog(@"tmpFileSave: zJson=%@", zJson);

        // weatherNews　= 前項で作ったWeatherNewsオブジェクトとします
        let data = try! JSONEncoder().encode(weatherNews)
        let json = String(data: data, encoding: .utf8)!
        print(json)

        return json
    }
    
    // E2_Clear & JSON ---> E2
    // JSON文字列を読み込みE2を全クリアしてから追加する
    func clearE2FromJson( json:String ) {
        
        
        return
    }


}


