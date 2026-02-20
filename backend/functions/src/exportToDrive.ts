import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const exportToDrive = functions.https.onCall(
  async (_data: unknown, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Giriş yapmanız gerekiyor."
      );
    }

    const uid = context.auth.uid;

    const [tasks, activities, notes, ruleSets, messages] = await Promise.all([
      db.collection(`users/${uid}/tasks`).get(),
      db.collection(`users/${uid}/activities`).get(),
      db.collection(`users/${uid}/notes`).get(),
      db.collection(`users/${uid}/aiRuleSets`).get(),
      db.collection(`users/${uid}/generatedMessages`).get(),
    ]);

    const exportData = {
      "tasks.json": tasks.docs.map((d) => ({ id: d.id, ...d.data() })),
      "activities.json": activities.docs.map((d) => ({ id: d.id, ...d.data() })),
      "notes.json": notes.docs.map((d) => ({ id: d.id, ...d.data() })),
      "ai_rules.json": ruleSets.docs.map((d) => ({ id: d.id, ...d.data() })),
      "generated_messages.json": messages.docs.map((d) => ({
        id: d.id,
        ...d.data(),
      })),
    };

    // TODO: googleapis kullanarak Google Drive'a yükle
    // 1. "Notlarim_Backups" klasörünü bul veya oluştur
    // 2. Her JSON dosyasını yükle
    // 3. Opsiyonel: Notlar için .md dosyaları da üret

    const jobRef = db.collection(`users/${uid}/syncJobs`).doc();
    await jobRef.set({
      type: "export_drive",
      status: "completed",
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
      finishedAt: admin.firestore.FieldValue.serverTimestamp(),
      resultMeta: {
        files: Object.keys(exportData),
        totalDocuments: Object.values(exportData).reduce(
          (sum, arr) => sum + arr.length,
          0
        ),
      },
    });

    await db.doc(`users/${uid}`).update({
      "settings.lastBackupAt": admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      jobId: jobRef.id,
    };
  }
);
