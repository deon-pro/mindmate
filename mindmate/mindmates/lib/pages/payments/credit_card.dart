import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Support Mindmate ❤️',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter Amount \$',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String enteredAmount = _amountController.text.trim();
                if (enteredAmount.isNotEmpty) {
                  double amount = double.parse(enteredAmount);
                  if (amount > 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                          clientId: "AeJcqW1ywdI7XAnA4hWJNvxn2ldW7AMAwOtw9H55vEHym5KFNn47MPJNI2T7Vq_6Pv8hOdjn-hmBgNIQ",
                          secretKey: "ENKAEMCdXjGikdxQOjQrIPGMQV3fmzukdukynAKUDbbtzn5p2HJ7YIC0OeCP_Umm4pCSLR6Nw5i2hNLL",
                          returnURL: "https://bluecodeinfinity.com/return",
                          cancelURL: "https://bluecodeinfinity.com/cancel",
                          transactions: [
                            {
                              "amount": {
                                "total": amount.toStringAsFixed(2),
                                "currency": "USD",
                                "details": {
                                  "subtotal": amount.toStringAsFixed(2),
                                  "shipping": '0',
                                  "shipping_discount": 0
                                }
                              },
                              "description": "Donation for Mindmate❤️",
                              "item_list": {
                                "items": [
                                  {
                                    "name": "Custom Payment",
                                    "quantity": 1,
                                    "price": amount.toStringAsFixed(2),
                                    "currency": "USD"
                                  }
                                ],
                              }
                            }
                          ],
                          note: "Thank you for supporting mindmate❤️.",
                          onSuccess: (Map params) async {
                            print("Payment successful: $params");
                            // Add your logic after successful payment
                          },
                          onError: (error) {
                            print("Payment error: $error");
                            // Handle payment error
                          },
                          onCancel: (params) {
                            print('Payment cancelled: $params');
                            // Handle payment cancellation
                          },
                        ),
                      ),
                    );
                  } else {
                    // Show error message for invalid amount
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid amount.'),
                      ),
                    );
                  }
                } else {
                  // Show error message for empty amount field
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter an amount.'),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Make Payment ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    'assets/images/paypal.png',
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
