import * as admin from 'firebase-admin';
import { cleanupAbandonedRooms } from './room_cleanup';

admin.initializeApp();

export {
  cleanupAbandonedRooms,
};
