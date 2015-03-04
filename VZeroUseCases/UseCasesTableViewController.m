//
//  UseCasesTableViewController.m
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 6/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import "UseCasesTableViewController.h"
#import "CustomUIViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <Braintree/Braintree.h>


@interface UseCasesTableViewController ()<BTDropInViewControllerDelegate,UIActionSheetDelegate> {
    BTDropInViewController *dropInViewController;
}

@property (nonatomic,strong) Braintree *braintree;
@property (nonatomic, copy) NSString *nonce;

@property UIAlertController *alertController;
@property BraintreeMerchantService *braintreeMerchantService;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *environmentsSelector;

@end

@implementation UseCasesTableViewController

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

#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    _alertController.title = @"Initialising Braintree Gateway";
    _alertController.message = @"Please wait";

    switch (indexPath.row)
    
    {
        case 0:
            //Disabling One Touch App Switch
            [Braintree setReturnURLScheme:@""];
            
            //Displaying payment UI
            [self displayWaitMesage];
            [_braintreeMerchantService initialiseBraintreeGatewayWithCustomerID:@""];
       
            break;
            
        case 1:
            
            //Specifying a test customer ID
            [self displayWaitMesage];
            [_braintreeMerchantService initialiseBraintreeGatewayWithCustomerID:@"your-test-customer-id"];
            
            break;
            
        case 2:
            
            //Do nothing. This segue was defined from the storyboard
            break;
            
        case 3:
            
            //Defining URL Scheme to enable One Touch
            [Braintree setReturnURLScheme:@"paypal.VZeroUseCases.payments"];
            //Displaying payment UI
            [self displayWaitMesage];
            [_braintreeMerchantService initialiseBraintreeGatewayWithCustomerID:@""];
            
            break;
            
        default:
            
            break;
            
    }
}

- (IBAction)tappedEnvironmentSelector:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a Merchant Server Environment"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Sandbox Merchant", @"Production Merchant",nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - Environment Selection action sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            [_braintreeMerchantService setEnvironment:Sandbox];
            _environmentsSelector.title = @"Sandbox";

            break;
            
        case 1:
            [_braintreeMerchantService setEnvironment:Production];
            _environmentsSelector.title = @"Production";
            break;
            
        default:
            break;
    }
    
}


#pragma mark - Braintree DropinUI delegate

- (void)userDidCancelPayment {

}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [_braintreeMerchantService postNonceToServer:paymentMethod.nonce];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {

}


#pragma mark - Braintree Client Token delegate

- (void)onBraintreeInitialised:(Braintree*)braintree {
    [self hideWaitMessage:nil];
    
    // Initializing Braintree with the client token]
    self.braintree = braintree;
    
    //Customizing Braintree's UI View controller with transaction details
    dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    
    dropInViewController.title = @"Buy treats";
    dropInViewController.summaryTitle = @"Trick or Treat";
    dropInViewController.summaryDescription = @"Yummy yummy treats";
    dropInViewController.displayAmount = [NSNumberFormatter localizedStringFromNumber:@(1) numberStyle:NSNumberFormatterCurrencyStyle];
    dropInViewController.callToActionText = @"Buy Now";
    dropInViewController.shouldHideCallToAction = NO;
    
    // Displaying Braintree's view controller
    [self showViewController:dropInViewController sender:self];
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
        
        NSString *confirmationMessage = [NSString stringWithFormat:@"Transaction ID: %@",transactionID];
        
        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:@"Transaction Success" message:confirmationMessage preferredStyle:UIAlertControllerStyleAlert];
    
        [alertMessage addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
    
        [self presentViewController:alertMessage animated:YES completion:nil];
}

-(void)onPaymentError:(NSString*)error{

        UIAlertController *alertMessage = [UIAlertController alertControllerWithTitle:@"Error" message:@"Could not process payment" preferredStyle:UIAlertControllerStyleAlert];
    [alertMessage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self.navigationController popViewControllerAnimated:YES];

    }]];

}

@end
