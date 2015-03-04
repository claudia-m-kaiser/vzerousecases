//
//  BraintreeAPI.h
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 7/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Braintree/Braintree.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, BraintreeEnvironment) {
    Sandbox,
    Production
};

@protocol BraintreeClientTokenDelegate <NSObject>
@required
- (void)onBraintreeInitialised:(Braintree*)braintree;
- (void)onBraintreeInitialisationError:(NSError*)error;
@end

@protocol BraintreePaymentDelegate <NSObject>
@required
- (void)onPaymentSuccess:(NSString*)transactionID;
- (void)onPaymentError:(NSError*)error;
@end

@interface BraintreeMerchantService : NSObject

//@property enum BraintreeEnvironment currentEnvironment;
@property (nonatomic, strong) AFHTTPRequestOperationManager *sessionManager;
@property (nonatomic,strong) id<BraintreeClientTokenDelegate> clientTokenDelegate;
@property (nonatomic,strong) id<BraintreePaymentDelegate> paymentDelegate;

-(void)setEnvironment:(BraintreeEnvironment)environment;
-(void)initialiseBraintreeGatewayWithCustomerID:(NSString*)isNewCustomer;
-(void)postNonceToServer:(NSString*)nonce;


@end
