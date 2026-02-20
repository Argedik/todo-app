import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const exportToSheets = functions.https.onCall(
  async (data: { spreadsheetId?: string }, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Giriş yapmanız gerekiyor."
      );
    }

    const uid = context.auth.uid;

    const [tasks, activities, events, ruleSets, messages] = await Promise.all([
      db.collection(`users/${uid}/tasks`).get(),
      db.collection(`users/${uid}/activities`).get(),
      db.collection(`users/${uid}/calendarEvents`).get(),
      db.collection(`users/${uid}/aiRuleSets`).get(),
      db.collection(`users/${uid}/generatedMessages`).get(),
    ]);

    const sheetsData = {
      Tasks_Todo: tasks.docs
        .filter((d) => !d.data().isCompleted)
        .map((d) => ({
          ID: d.id,
          Başlık: d.data().title,
          Açıklama: d.data().description || "",
          "Hatırlatma Tarihi": d.data().reminderAt?.toDate?.()?.toISOString() || "",
          "Oluşturulma": d.data().createdAt?.toDate?.()?.toISOString() || "",
        })),
      Tasks_Done: tasks.docs
        .filter((d) => d.data().isCompleted)
        .map((d) => ({
          ID: d.id,
          Başlık: d.data().title,
          "Tamamlanma": d.data().completedAt?.toDate?.()?.toISOString() || "",
        })),
      Activities: activities.docs.map((d) => ({
        ID: d.id,
        Başlık: d.data().title,
        Açıklama: d.data().description || "",
        "Tarih/Saat": d.data().activityAt?.toDate?.()?.toISOString() || "",
        Kategori: d.data().categoryId || "",
      })),
      CalendarEvents: events.docs.map((d) => ({
        ID: d.id,
        Başlık: d.data().title,
        Başlangıç: d.data().startAt?.toDate?.()?.toISOString() || "",
        Bitiş: d.data().endAt?.toDate?.()?.toISOString() || "",
      })),
      AIRuleSets: ruleSets.docs.map((d) => ({
        ID: d.id,
        Ad: d.data().name,
        Kategori: d.data().category,
        Üslup: d.data().tone,
        Emoji: d.data().emojiPolicy,
      })),
      GeneratedMessages: messages.docs.map((d) => ({
        ID: d.id,
        Başlık: d.data().title,
        İçerik: d.data().content?.substring(0, 200) || "",
        "Oluşturulma": d.data().createdAt?.toDate?.()?.toISOString() || "",
      })),
    };

    // TODO: googleapis kullanarak Google Sheets'e yaz
    // 1. OAuth2 client oluştur (service account veya user credentials)
    // 2. Spreadsheet yoksa oluştur, varsa güncelle
    // 3. Her sheet için ayrı sayfa oluştur
    // 4. Başlıkları ve verileri yaz

    const jobRef = db.collection(`users/${uid}/syncJobs`).doc();
    await jobRef.set({
      type: "export_sheets",
      status: "completed",
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
      finishedAt: admin.firestore.FieldValue.serverTimestamp(),
      resultMeta: {
        totalRows: Object.values(sheetsData).reduce(
          (sum, arr) => sum + arr.length,
          0
        ),
        sheets: Object.keys(sheetsData),
      },
    });

    return {
      success: true,
      jobId: jobRef.id,
      data: sheetsData,
    };
  }
);
