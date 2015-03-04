//
//  UseCasesTableViewController.h
//  VZeroUseCases
//
//  Created by Kaiser, Claudia on 6/12/2014.
//  Copyright (c) 2014 Kaiser, Claudia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BraintreeMerchantService.h"

@interface UseCasesTableViewController : UITableViewController <BraintreeClientTokenDelegate,BraintreePaymentDelegate> {

}

@end
