//
//  CustomUIViewController.m
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 7/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import "CustomUIViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <Braintree/Braintree.h>
#import "BraintreeMerchantService.h"


@interface CustomUIViewController ()<BraintreeClientTokenDelegate,BraintreePaymentDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *creditCard;
@property (strong, nonatomic) IBOutlet UITextField *expirationMonth;
@property (strong, nonatomic) IBOutlet UITextField *expirationYear;
@property (strong, nonatomic) IBOutlet UITextField *cvv;

@property (nonatomic, copy) NSString *nonce;

@property UIAlertController *alertController;
@property BraintreeMerchantService *braintreeMerchantService;



@end

@implementation CustomUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    _braintreeMerchantService = [[BraintreeMerchantService alloc] init];
    _braintreeMerchantService.clientTokenDelegate = self;
    _braintreeMerchantService.paymentDelegate = self;

}

-(void)displayWaitMesage {
    [self presentViewController:_alertController animated:YES completion:nil];
}

-(void)hideWaitMessage:(void (^)(void))completion {
    [_alertController dismissViewControllerAnimated:YES completion:completion];
}


#pragma mark - IBAction

- (IBAction)tappedCreditCardSelector:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a test credit card number"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Visa Test Card1", @"Visa Test Card 2", @"Mastercard Test Card",  @"Amex Test Card", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)submitPayment:(id)sender {
    _alertController.title = @"Processing payment";
    _alertController.message = @"Please wait";
    [self displayWaitMesage];

    [_braintreeMerchantService initialiseBraintreeGatewayWithCustomerID:@""];
}

#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // Setting Default Values
    switch (buttonIndex) {
        case 0:
            _creditCard.text = @"4005519200000004";
            _expirationMonth.text = @"10";
            _expirationYear.text = @"2017";
            _cvv.text = @"123";
            break;
            
        case 1:
            _creditCard.text = @"4012000077777777";
            _expirationMonth.text = @"09";
            _expirationYear.text = @"2015";
            _cvv.text = @"456";
            break;
            
        case 2:
            _creditCard.text = @"5555555555554444";
            _expirationMonth.text = @"06";
            _expirationYear.text = @"2016";
            _cvv.text = @"789";
            break;
            
        case 3:
            _creditCard.text = @"378282246310005";
            _expirationMonth.text = @"04";
            _expirationYear.text = @"2015";
            _cvv.text = @"1234";
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Braintree API delegate

- (void)onBraintreeInitialised:(Braintree*)braintree {
    
    //Processing payment and tokenising card
    BTClientCardRequest *request = [BTClientCardRequest new];
    request.number = _creditCard.text;
    request.expirationMonth =_expirationMonth.text;
    request.expirationYear = _expirationYear.text;
    request.cvv = _cvv.text;
    
    [braintree tokenizeCard:request completion:^(NSString *nonce, NSError *error){
        [_braintreeMerchantService postNonceToServer:nonce];
    
    }];
}

- (void)onBraintreeInitialisationError:(NSError*)error {
    [self hideWaitMessage:^{
        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not get a client token" preferredStyle:UIAlertControllerStyleAlert];
        [alertMessage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertMessage animated:YES completion:nil];
    }];

}

#pragma mark - Braintree Payment Delegate

-(void)onPaymentSuccess:(NSString*)transactionID{
    [self hideWaitMessage:^{
        NSString *confirmationMessage = [NSString stringWithFormat:@"Transaction ID: %@",transactionID];
    
        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:@"Transaction Success" message:confirmationMessage preferredStyle:UIAlertControllerStyleAlert];
    
        [alertMessage addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
    
        [self presentViewController:alertMessage animated:YES completion:nil];
    }];

}

-(void)onPaymentError:(NSString*)error{
    [self hideWaitMessage:^{
        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
        [alertMessage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [self.navigationController popViewControllerAnimated:YES];
        
        }]];
    }];

}


@end
