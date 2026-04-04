//
//  IAPManagerOcho.m
//  OCHO
//
//  Created by Nelson on 6/3/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "IAPManagerOcho.h"

@implementation IAPManagerOcho

- (void)requestUnlimitedRoundsProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.adamzappl.ochosimple.unlimitedrounds" ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    unlimitedRoundsProduct = [products count] >= 1 ? [[products objectAtIndex:0] retain] : nil;
    if (unlimitedRoundsProduct)
    {
        NSLog(@"Product title: %@" , unlimitedRoundsProduct.localizedTitle);
        NSLog(@"Product description: %@" , unlimitedRoundsProduct.localizedDescription);
        NSLog(@"Product price: %@" , unlimitedRoundsProduct.price);
        NSLog(@"Product id: %@" , unlimitedRoundsProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
    [productsRequest release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}



@end
