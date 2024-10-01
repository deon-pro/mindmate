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
