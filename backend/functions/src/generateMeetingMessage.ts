import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import OpenAI from "openai";

const db = admin.firestore();

interface GenerateRequest {
  eventId: string;
  ruleSetId: string;
  additionalNote?: string;
  messageType?: "kısa" | "orta" | "uzun";
}

export const generateMeetingMessage = functions.https.onCall(
  async (data: GenerateRequest, context: functions.https.CallableContext) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Giriş yapmanız gerekiyor."
      );
    }

    const uid = context.auth.uid;
    const { eventId, ruleSetId, additionalNote, messageType = "orta" } = data;

    const [eventDoc, ruleSetDoc] = await Promise.all([
      db.doc(`users/${uid}/calendarEvents/${eventId}`).get(),
      db.doc(`users/${uid}/aiRuleSets/${ruleSetId}`).get(),
    ]);

    if (!eventDoc.exists || !ruleSetDoc.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Etkinlik veya kural seti bulunamadı."
      );
    }

    const event = eventDoc.data()!;
    const ruleSet = ruleSetDoc.data()!;

    const prompt = buildPrompt(event, ruleSet, additionalNote, messageType);

    const openaiApiKey = process.env.OPENAI_API_KEY ||
      (functions.config().openai?.key as string | undefined);

    if (!openaiApiKey) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "OpenAI API anahtarı yapılandırılmamış."
      );
    }

    const openai = new OpenAI({ apiKey: openaiApiKey });

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content:
            "Sen profesyonel bir Türkçe mesaj yazarısın. Verilen kurallara göre mesaj üret.",
        },
        { role: "user", content: prompt },
      ],
      max_tokens: 1000,
      temperature: 0.7,
    });

    const generatedContent =
      completion.choices[0]?.message?.content || "Mesaj üretilemedi.";

    const messageRef = db.collection(`users/${uid}/generatedMessages`).doc();
    const now = admin.firestore.FieldValue.serverTimestamp();

    await messageRef.set({
      title: `${event.title} - Mesaj`,
      content: generatedContent,
      sourceEventId: eventId,
      ruleSetId: ruleSetId,
      isFavorite: false,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    });

    return {
      messageId: messageRef.id,
      content: generatedContent,
    };
  }
);

function buildPrompt(
  event: FirebaseFirestore.DocumentData,
  ruleSet: FirebaseFirestore.DocumentData,
  additionalNote?: string,
  messageType?: string
): string {
  const lines: string[] = [
    "Aşağıdaki bilgilere göre Türkçe bir mesaj üret:",
    "",
    `## Etkinlik Bilgileri`,
    `- Başlık: ${event.title}`,
    `- Tarih: ${event.startAt?.toDate?.()?.toISOString() || "Belirtilmemiş"}`,
    `- Açıklama: ${event.description || "Yok"}`,
    "",
    `## Kural Seti: ${ruleSet.name}`,
    `- Kategori: ${ruleSet.category}`,
    `- Hitap şekli: ${ruleSet.greetingStyle || "Genel"}`,
    `- Üslup: ${ruleSet.tone}`,
    `- Emoji politikası: ${ruleSet.emojiPolicy}`,
    `- Hedef mesaj uzunluğu: ${messageType || ruleSet.lengthTarget}`,
  ];

  if (ruleSet.fixedPhrases?.length > 0) {
    lines.push(
      `- Sabit cümleler (mesaja dahil et): ${ruleSet.fixedPhrases.join("; ")}`
    );
  }

  if (ruleSet.bannedWords?.length > 0) {
    lines.push(
      `- Yasak kelimeler (KULLANMA): ${ruleSet.bannedWords.join(", ")}`
    );
  }

  if (ruleSet.customInstructions) {
    lines.push(`- Ek talimatlar: ${ruleSet.customInstructions}`);
  }

  if (additionalNote) {
    lines.push("", `## Kullanıcı notu: ${additionalNote}`);
  }

  lines.push(
    "",
    "Mesajı doğrudan yaz, açıklama ekleme. Dil: Türkçe."
  );

  return lines.join("\n");
}
