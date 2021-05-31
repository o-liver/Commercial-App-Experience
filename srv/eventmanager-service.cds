using { sap.cae.eventmanagement as eventmanagement } from '../db/event';

// Event manager service
service EventManagerService @(path:'eventmanager', impl : './eventmanager-service.js') {
  
  entity Events as projection on eventmanagement.Events {
    *, count( confirmedParticipants.ID ) as participantsCount : Integer  
  } 
    group by ID  // to make sure to pi

    // Action on event
    actions{
        action cancel() returns Events;
        action complete() returns Events;
        action block() returns Events;
    };
  
  entity Participants as projection on eventmanagement.Participants;

    // Add and confirm a participant on behalf


    // Cancel participation on behalf


                /* Cancelled list of participants */
  // entity CancelledParticipants as select eventmanagement.Participants{ * } where status = 3;
}
