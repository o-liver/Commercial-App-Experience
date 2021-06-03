using { sap.cae.eventmanagement as eventmanagement } from '../db/event';
service EventManager @(path:'eventmanager', impl : './eventmanager-service.js') {
  
  entity Events as projection on eventmanagement.Events {
    *, count( confirmedParticipants.ID ) as participantsCount : Integer  
  } 
    group by ID  // to make sure to pi
    actions{
        action cancel() returns Events;
        action complete() returns Events;
        action block() returns Events;
        action publish() returns Events;
    };
  
  entity Participants as projection on eventmanagement.Participants;


                /* Cancelled list of participants */
  // entity CancelledParticipants as select eventmanagement.Participants{ * } where status = 3;
}
