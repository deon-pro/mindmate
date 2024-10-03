package com.flutterflow.mindmate

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager: NotificationManager =
                getSystemService(android.content.Context.NOTIFICATION_SERVICE) as NotificationManager

            // Channel 1: Message/Chat
            val messageChannelId = "Chats"
            val messageChannelName = "Chat Notifications"
            val messageChannelDescription = "Notifications for chats"
            val messageChannelImportance = NotificationManager.IMPORTANCE_HIGH
            val messageChannel = NotificationChannel(messageChannelId, messageChannelName, messageChannelImportance).apply {
                description = messageChannelDescription
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(messageChannel)

            // Channel 2: Payment
            val paymentChannelId = "Payment"
            val paymentChannelName = "Payment Notifications"
            val paymentChannelDescription = "Notifications for payment"
            val paymentChannelImportance = NotificationManager.IMPORTANCE_DEFAULT
            val paymentChannel = NotificationChannel(paymentChannelId, paymentChannelName, paymentChannelImportance).apply {
                description = paymentChannelDescription
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(paymentChannel)

            // Channel 3: Request
            val requestChannelId = "Video"
            val requestChannelName = "Video Notifications"
            val requestChannelDescription = "Notifications for Video Calls"
            val requestChannelImportance = NotificationManager.IMPORTANCE_HIGH
            val requestChannel = NotificationChannel(requestChannelId, requestChannelName, requestChannelImportance).apply {
                description = requestChannelDescription
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(requestChannel)

             // Channel 4: Review
            val reviewChannelId = "Review"
            val reviewChannelName = "Review Notifications"
            val reviewChannelDescription = "Notifications for Reviews"
            val reviewChannelImportance = NotificationManager.IMPORTANCE_DEFAULT
            val reviewChannel = NotificationChannel(reviewChannelId, reviewChannelName, reviewChannelImportance).apply {
                description = reviewChannelDescription
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(reviewChannel)

        }
    }
}

