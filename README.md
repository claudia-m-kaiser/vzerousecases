VZero Mobile Test
=============

This example shows 4 simple use cases for V.Zero Mobile

- New Customer
This options uses Braintree's Drop-in UI to simulate a payment for a new customer.
One touch is disabled in this option

- Existing Customer 
This options uses Braintree's Drop-in UI to simulate a payment for an existing customer.

- Custom 
This is will show a custom view controller, using custom fields for the credit card numbers
The credit card numbers can be pre-populated with Braintree test values supplied in the documentation.

- One Touch
You will need to have the PayPal app installed on your phone.

## Setup

### Xcode

- Open VZeroUseCases.workspace

### Merchant server configuration.

Open the BraintreeMerchantService.m.
Configure your merchant server endpoints for the client_token and for the payment method nonce.

#### Updates

    // Update the Base URL
    - (void) setEnvironment:(BraintreeEnvironment) environment{
    switch (environment) {
        case Sandbox:
            
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://your-merchant-server/sandbox/"]];
            break;
            
        case Production:
            self.sessionManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://your-merchant-server/production/"]];
            break;
            
        default:
            break;
    }

    // Update the client_token endpoint in initialiseBraintreeGatewayWithCustomerID.
    [self.sessionManager GET:@"client_token"

    // Update the payment method nonce endpoint in postNonceToServer
	[self.sessionManager POST:@"process-payment" 

**NOTE**: Currently BuildPal only builds debug targets for PayPalApp and PayPalQATest

## Testing

### Use case for a new customer

The client token request will be sent to this endpoint, leaving the CustomerId blank

	http://your-merchant-server/sandbox/client_token?CustomerId=

### Use case for an existing client.

To test this use case you must first create a client in your vault and add payment methods.
You can do this either via the Braintree Server SDK or through the Braintree Dashboard.
Once you've completed this, copy the 'customer Id' for your test customer.

Your server should offer the possibility of generating a client token by passing a customerId as a parameter.
In this example, the CustomerId is communicated to the server as a URL parameter:

	http://your-merchant-server/sandbox/client_token?CustomerId=1234


Go to UseCasesTableViewController.m and in didSelectRowAtIndexPath update the 'customer_id' for your test customer.

    // Update the client_token endpoint in initialiseBraintreeGatewayWithCustomerID.
    case 1:
            
            //Specifying a test customer ID
            [self displayWaitMesage];
            [_braintreeMerchantService initialiseBraintreeGatewayWithCustomerID:@"a-test-customer-id"];
            
            break;

### One Touch
The one touch feature can only be properly tested in Production.
The Sandbox test will not reflect the actual One-Touch experience.
