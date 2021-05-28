using { sap.cae.eventmanagement as eventmanagement } from '../db/event';
service EventManager @(path:'eventmanager', impl : './eventmanager-service.js') {
  entity Events as projection on eventmanagement.Events;
  entity Participants as projection on eventmanagement.Participants;

                /* Cancelled list of participants */
  // entity CancelledParticipants as select eventmanagement.Participants{ * } where status = 3;
}
