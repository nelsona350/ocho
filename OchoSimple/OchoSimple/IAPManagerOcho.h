//
//  IAPManagerOcho.h
//  OCHO
//
//  Created by Nelson on 6/3/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface IAPManagerOcho : NSObject <SKProductsRequestDelegate>
{
    SKProduct *unlimitedRoundsProduct;
    SKProductsRequest *productsRequest;
    
}
@end
