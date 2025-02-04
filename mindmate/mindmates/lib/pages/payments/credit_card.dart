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
                          clientId: "AYC5wXNbfVaN3-2BOTAP2D6yY51yCk4Dq-Awk4aiiIx6njG-7KL3K8RKCfDUmhLqSJq7JdfNxZiSu-Do",
                          secretKey: "ECIHld2xW4Lemhuc4nUEirdq5z2MSt-RefWs9DWgFtExAIhx9Qt4preitR47ePKCWqYlbvTnwtxNfSDY",
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
