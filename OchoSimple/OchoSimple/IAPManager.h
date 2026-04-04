//
//  IAPManager.h
//  OCHO
//
//  Created by Nelson on 6/3/13.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPManager : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end