import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double amountInDollars = 0.0;
  double amountInKES = 0.0;
  double availableFundsInDollars = 1000.0;
  String beneficiaryAccountNumber = '01108854569700';

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MINDMATE CREDIT CARD'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
            ),
            CreditCardForm(
              formKey: formKey,
              cardHolderName: cardHolderName,
              cardNumber: cardNumber,
              cvvCode: cvvCode,
              expiryDate: expiryDate,
              themeColor: Colors.blue,
              obscureCvv: true,
              obscureNumber: true,
              cardNumberDecoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Card Number',
                hintText: 'XXXX XXXX XXXX XXXX',
              ),
              expiryDateDecoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Expiry Date',
                hintText: 'MM/YY',
              ),
              cvvCodeDecoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'CVV',
                hintText: 'XXX',
              ),
              cardHolderDecoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Card Holder',
              ),
              onCreditCardModelChange: onCreditCardModelChange,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount in Dollars',
                  hintText: 'Enter Amount',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    amountInDollars = double.tryParse(value) ?? 0.0;
                    calculateAmountInKES();
                  });
                },
              ),
            ),
            Text(
              'Amount in KES: $amountInKES',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                if (isValidCard()) {
                  if (amountInDollars <= availableFundsInDollars) {
                    availableFundsInDollars -= amountInDollars;
                    transferToBeneficiary();
                    String transactionId = getRandomTransactionId();
                    savePaymentData(transactionId); // Save payment data to database
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Payment Confirmation'),
                          content: Text(
                              'Dear $cardHolderName,\n\nThis message is to confirm that your recent payment of \$$amountInDollars '
                              'to PATRICK WAMBUA has been successfully processed.\n\nTransaction Details:\n'
                              'Transaction ID: $transactionId\n'
                              'Date and Time: ${DateTime.now().toString()}\n'
                              'Amount: \$$amountInDollars\n'
                              'Merchant: PATRICK WAMBUA\n'
                              'Payment Method: ${getCardType(cardNumber)} ****${cardNumber.substring(cardNumber.length - 4)}\n\n'
                              'Thank you for your payment!\n\nIf you have any questions or concerns regarding this transaction, '
                              'please contact our customer support.\n\nBest regards,\nPATRICK WAMBUA'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                clearFields();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Insufficient Funds!'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid Card Information'),
                    ),
                  );
                }
              },
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      cardHolderName = creditCardModel.cardHolderName;
      expiryDate = creditCardModel.expiryDate;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  bool isValidCard() {
    if (expiryDate.isEmpty) {
      return false;
    }
    return cardNumber.isNotEmpty &&
        cardHolderName.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvvCode.isNotEmpty &&
        expiryDate.length == 5 &&
        cvvCode.length == 3 &&
        isExpiryDateValid();
  }

  bool isExpiryDateValid() {
    DateTime now = DateTime.now();
    int currentYear = now.year % 100;
    int currentMonth = now.month;
    int cardYear = int.parse(expiryDate.substring(3));
    int cardMonth = int.parse(expiryDate.substring(0, 2));

    if (cardYear < currentYear || (cardYear == currentYear && cardMonth < currentMonth)) {
      return false;
    }
    return true;
  }

  void calculateAmountInKES() {
    const exchangeRate = 135;
    setState(() {
      amountInKES = amountInDollars * exchangeRate;
    });
  }

  void transferToBeneficiary() {
    // Logic for transferring payment to beneficiary account
  }

  void clearFields() {
    setState(() {
      cardNumber = '';
      cardHolderName = '';
      expiryDate = '';
      cvvCode = '';
      amountInDollars = 0.0;
      amountInKES = 0.0;
    });
  }

  String getRandomTransactionId() {
    Random random = Random();
    int randomNumber = random.nextInt(99999);
    return 'TFJC$randomNumber';
  }

  String getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5')) {
      return 'MasterCard';
    } else {
      return 'Credit Card';
    }
  }

  String encryptData(String data) {
    // Implement encryption algorithm here
    // For demonstration purposes, we'll return the data as-is
    String encryptedData = '';
    if (data.isNotEmpty) {
      encryptedData = data.substring(0, 4) +
          'xxxxxxxxxxxx' +
          data.substring(data.length - 4);
    }
    return encryptedData;
  }

  void savePaymentData(String transactionId) async {
    try {
      await firestore.collection('payment').add({
        'cardNumber': encryptData(cardNumber), // Encrypt card number before saving
        'cardHolderName': cardHolderName,
        'expiryDate': expiryDate,
        'cvvCode': 'xxx', // Encrypt CVV before saving
        'amountInDollars': amountInDollars,
        'transactionId': transactionId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving payment data: $e');
    }
  }
}

   
