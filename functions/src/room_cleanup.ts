import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from 'firebase-admin';

export const cleanupAbandonedRooms = onSchedule({
  schedule: "every 24 hours",
  timeZone: "UTC",
  retryCount: 3,
  memory: "256MiB"
}, async () => {
    const firestore = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const threshold = new Date(now.toDate().getTime() - (24 * 60 * 60 * 1000)); // 24 hours ago

    try {
      const snapshot = await firestore
        .collectionGroup('rooms')
        .where('lastUpdated', '<', threshold)
        .where('state', 'in', ['abandoned', 'completed'])
        .get();

      const batch = firestore.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      
      console.log(`Cleaned up ${snapshot.size} inactive rooms`);
    } catch (error) {
      console.error('Error cleaning up rooms:', error);
    }
}); 