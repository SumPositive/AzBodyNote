//
//  AZStore.h
//
//  Created by Sum Positive on 11/10/06.
//  Copyright (c) 2011 Azukid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@interface AZStore : NSObject <SKPaymentTransactionObserver>


@end


@protocol AZStoreDelegate <NSObject>
#pragma mark - <AZStoreDelegate>
@end

