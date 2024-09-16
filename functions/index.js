const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendActivityFeedNotification = functions.firestore
    .document('notifications/{userId}/userNotifications/{notificationId}')
    .onCreate(async (snapshot, context) => {
        const userId = context.params.userId;
        const notificationData = snapshot.data();

        // Fetch the recipient's FCM token
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
            console.log(`No FCM token for user: ${userId}`);
            return;
        }

        // Create the notification payload
        const payload = {
            notification: {
                title: notificationData.type === 'like' ? 'New Like' : 'New Comment',
                body: notificationData.type === 'like' 
                    ? `${notificationData.username} liked your post.` 
                    : `${notificationData.username} commented: ${notificationData.comment}`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };

        // Send the notification
        try {
            await admin.messaging().sendToDevice(fcmToken, payload);
            console.log(`Notification sent to ${userId}`);
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    });
