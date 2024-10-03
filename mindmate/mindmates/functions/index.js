const functions = require('firebase-functions');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const APP_ID = '10a1b2098d2e45e59100af945e38ef99';
const APP_CERTIFICATE = '3b398ac50f064c919ee1d3fd800868dd';

// Firebase Cloud Function to generate Agora RTC token
exports.generateAgoraToken = functions.https.onCall((data, context) => {
  const channelName = data.channelName;
  const uid = data.uid || 0;  // Default is 0 for dynamic UID
  const role = data.role === 'publisher' ? RtcRole.PUBLISHER : RtcRole
    .SUBSCRIBER;

  // Token expiration time (1 hour)
  const expirationTimeInSeconds = 3600;
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTime + expirationTimeInSeconds;

  // Generate the token
  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID, APP_CERTIFICATE, channelName, uid, role, privilegeExpiredTs
  );

  return { token: token };
});

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();  // Initialize Firebase Admin SDK

exports.notifyPaymentConfirmation = functions.firestore
  .document('payments/{paymentId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Check if the payment status changed to "confirmed"
    if (previousValue.status !== 'confirmed' && newValue.status === 'confirmed') {
      const userId = newValue.userId;

      try {
        // Fetch the user's FCM token from Firestore
        const userDoc = await admin.firestore().collection('users')
          .doc(userId).get();

        if (!userDoc.exists) {
          console.log('No such user!');
          return;
        }

        const fcmToken = userDoc.data().token;
        if (!fcmToken) {
          console.log('User does not have an FCM token.');
          return;
        }

        // Define the notification payload
        const payload = {
          notification: {
            title: 'Payment Confirmed',
            body: `Your payment with transaction 
              ID ${newValue.transactionId} has been confirmed.`,
          },
          token: fcmToken,
        };

        // Send a notification via Firebase Cloud Messaging (FCM)
        const response = await admin.messaging().send(payload);
        console.log('Successfully sent message:', response);
      } catch (error) {
        console.error('Error fetching user or sending notification:', error);
      }
    }
  });

