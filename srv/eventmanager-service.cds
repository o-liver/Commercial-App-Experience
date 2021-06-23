using { sap.cae.eventmanagement as eventmanagement } from '../db/event';
service EventManager @(path:'eventmanager', impl : './eventmanager-service.js') {
  @odata.draft.enabled  
  entity Events as projection on eventmanagement.Events {
    *, //count( confirmedParticipants.ID ) as participantsCount : Integer
    virtual null as eventStatusCriticality: Integer  
  } 
    group by ID  // to make sure to pi
    actions{
        action cancel() returns Events;
        action complete() returns Events;
        action block() returns Events;
        action publish() returns Events;
    };
 
  entity Participants as projection on eventmanagement.Participants {
      *,
      virtual null as participantStatusCriticality: Integer 
  }actions{
      action cancelParticipation() returns Participants;
      action confirmParticipation() returns Participants;
  };

    

}
