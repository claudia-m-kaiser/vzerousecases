//
//  CardScanViewController.m
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 8/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import "CardScanViewController.h"
#import <CardIO/CardIO.h>

@interface CardScanViewController ()  <CardIOPaymentViewControllerDelegate>

@end

@implementation CardScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![CardIOUtilities canReadCardWithCamera]) {
        // Hide your "Scan Card" button, or take other appropriate action...
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CardIOUtilities preload];
}

#pragma mark - User Actions

- (void)scanCardClicked:(id)sender {
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:scanViewController animated:YES completion:nil];
}

#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"Scan succeeded with info: %@", info);
    // Do whatever needs to be done to deliver the purchased items.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.infoLabel.text = [NSString stringWithFormat:@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
    [self dismissViewControllerAnimated:YES completion:nil];
}

}

@end
