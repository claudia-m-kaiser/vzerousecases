//
//  BraintreeAPI.m
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 7/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import "BraintreeMerchantService.h"


@implementation BraintreeMerchantService

- (id) init
{
    self = [super init];
    if (self) {
        [self setEnvironment:Sandbox];
    }
    return self;
}

- (void) setEnvironment:(BraintreeEnvironment) environment{
    switch (environment) {
        case Sandbox:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://vzerotraining.herokuapp.com/"]];
            break;
            
        case Production:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://your-merchant-server/production/"]];
            break;
            
        default:
            break;
    }
    
}

-(void)initialiseBraintreeGatewayWithCustomerID:(NSString*)customerID {
    
    
    
    [self.sessionManager GET:@"sandbox/client_token"
                         parameters:@{@"customerId": customerID}
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
                             // Initializing Braintree with the client token
                             Braintree *braintree = [Braintree braintreeWithClientToken:responseObject[@"client_token"]];
             
                             NSLog(@"Success! Obtained client token");
                             [self.clientTokenDelegate onBraintreeInitialised:braintree];

                         }
     
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
                             NSLog(@"Failure! Could not get client token");
                             [self.clientTokenDelegate onBraintreeInitialisationError:error];
             
                         }];
}

- (void)postNonceToServer:(NSString*) nonce{
    
    NSDictionary *params = @{@"payment_method_nonce" : nonce, @"store_in_vault" : @"true" };
    
    [self.sessionManager POST:@"gateway/transaction/create"
                   parameters:params
                      success:^(__unused AFHTTPRequestOperation *operation, __unused id responseObject) {
                          NSString *transactionID = responseObject[@"transaction_id"];
                          [self.paymentDelegate onPaymentSuccess:transactionID];
                      }
                      failure:^(__unused AFHTTPRequestOperation *operation, __unused NSError *error) {
                          [self.paymentDelegate onPaymentError:error];
                      }];

}

@end
