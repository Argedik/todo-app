import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { generateMeetingMessage } from "./generateMeetingMessage";
import { exportToSheets } from "./exportToSheets";
import { exportToDrive } from "./exportToDrive";
import { sendScheduledReminders } from "./scheduledReminders";

admin.initializeApp();

export { generateMeetingMessage, exportToSheets, exportToDrive, sendScheduledReminders };
