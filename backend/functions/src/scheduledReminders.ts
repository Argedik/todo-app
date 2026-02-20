import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const sendScheduledReminders = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const fiveMinutesLater = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 5 * 60 * 1000
    );

    const usersSnap = await db.collection("users").get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;

      const events = await db
        .collection(`users/${uid}/calendarEvents`)
        .where("startAt", ">=", now)
        .get();

      for (const eventDoc of events.docs) {
        const event = eventDoc.data();
        const startAt = event.startAt?.toDate();
        if (!startAt) continue;

        const reminderRules = event.reminderRules || [];
        for (const rule of reminderRules) {
          const reminderTime = calculateReminderTime(startAt, rule);
          if (
            reminderTime >= now.toDate() &&
            reminderTime <= fiveMinutesLater.toDate()
          ) {
            await sendFCMNotification(uid, {
              title: `Yaklaşan etkinlik: ${event.title}`,
              body: `${rule.value} ${unitToTurkish(rule.unit)} sonra başlayacak`,
              data: { eventId: eventDoc.id, type: "calendar_event" },
            });
          }
        }
      }
    }

    return null;
  });

function calculateReminderTime(
  startAt: Date,
  rule: { type: string; value: number; unit: string }
): Date {
  const ms = startAt.getTime();
  let offset = 0;
  switch (rule.unit) {
    case "minute":
      offset = rule.value * 60 * 1000;
      break;
    case "hour":
      offset = rule.value * 60 * 60 * 1000;
      break;
    case "day":
      offset = rule.value * 24 * 60 * 60 * 1000;
      break;
  }
  return new Date(ms - offset);
}

function unitToTurkish(unit: string): string {
  switch (unit) {
    case "minute":
      return "dakika";
    case "hour":
      return "saat";
    case "day":
      return "gün";
    default:
      return unit;
  }
}

async function sendFCMNotification(
  uid: string,
  notification: { title: string; body: string; data: Record<string, string> }
) {
  const userDoc = await db.doc(`users/${uid}`).get();
  const fcmToken = userDoc.data()?.profile?.fcmToken;

  if (!fcmToken) return;

  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data,
      android: { priority: "high" },
      apns: {
        payload: { aps: { alert: { title: notification.title, body: notification.body } } },
      },
    });
  } catch (error) {
    console.error(`FCM gönderim hatası (${uid}):`, error);
  }
}
