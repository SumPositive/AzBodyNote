//
//  GDocRevisionTVC.h
//  AzPackList5
//
//  Created by Sum Positive on 12/02/18.
//  Copyright (c) 2012 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"
#import "GDataDocs.h"

@interface GDocRevisionTVC : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) GDataEntryDocBase		*docSelect;

@end
