//
//  ViewController.m
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 6/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import "UseCasesViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <Braintree/Braintree.h>

@interface UseCasesViewController ()<BTDropInViewControllerDelegate>


#pragma mark Payment Data

@property (nonatomic,strong) Braintree *braintree;
@property (nonatomic,copy)NSString *merchantID;
@property (nonatomic,copy)NSString *nonce;
@property (nonatomic,copy)NSString *lastTransactionID;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation UseCasesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeBraintree];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeBraintree{
    
    self.braintree = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://192.168.0.9:9000/client_token"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             // Setup braintree with responseObject[@"client_token"]
             NSLog(@"Client token: %@ ", responseObject[@"client_token"]);
             self.braintree = [Braintree braintreeWithClientToken:responseObject[@"client_token"]];
             [self.activityIndicator stopAnimating];
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Could not wait a client token. %@", error.description);
             [self.activityIndicator stopAnimating];
             //assigning a token manually
         }];
    
}



- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    
    NSLog(@"Retrieved nonce successfully: %@", paymentMethod.nonce);

    self.nonce = paymentMethod.nonce;
    
    //Sending the payment method nonce to the server
    //[self postNonceToServer:self.nonce];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Payment was cancelled");

}

- (void)postNonceToServer:(NSString*) nonce{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = @{@"payment_method_nonce" : nonce};
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:@"http://192.168.0.9:9000/future" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
    
    

@end
