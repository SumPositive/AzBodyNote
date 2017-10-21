//
//  DataManager.h
//  AzBodyNote
//
//  Created by 松山正和 on 2017/10/08.
//
//

#import <Foundation/Foundation.h>
#import "Global.h"


#define UKVS_UPLOAD_DATE        @"UKVS_UPLOAD_DATE"


@interface DataManager : NSObject

+ (DataManager*)singleton;

// E0配下をDATAへ書き出す
- (void)coreExport:(void(^)(BOOL success, NSData* exportData))completion;
// NSDataを読み込んでE0配下を更新する
- (void)coreImportData:(NSData*)importData completion:(void(^)(BOOL success))completion;

// iCloud
- (void)iCloudUpload:(void(^)(BOOL success))completion;
// 読み込む（開始アラートから）
- (void)iCloudDownloadAlert;
// 読み込む（終了アラートまで）
- (void)iCloudDownloading;


@end
