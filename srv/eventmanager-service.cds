using { sap.cae.eventmanagement as eventmanagement } from '../db/event';

service EventManager @(path:'eventmanager', impl : './eventmanager-service.js', requires:['EventManagerRole', 'AdminRole']) {
  @odata.draft.enabled  
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
 
  entity Participants as projection on eventmanagement.Participants {
      *
  }actions{
      action cancelParticipation() returns Participants;
      action confirmParticipation() returns Participants;
  };

}

// Event managers can read all events, create new events and change their own events
// Admins have no restrictions
annotate EventManager.Events with 
    @restrict: [
        { grant: ['READ', 'CREATE'], to: 'EventManagerRole' },
        { grant: ['*'], to: 'EventManagerRole', where: 'createdBy = $user' },
        { grand: '*', to: 'AdminRole' }
    ];

// Event managers read all participants, add new participants, change participants they added themseves
// Admins have no restrictions
annotate EventManager.Participants with 
    @restrict: [
        { grant: ['READ', 'CREATE'], to: 'EventManagerRole'},
        { grant: ['*'], to: 'EventManagerRole', where: 'createdBy = $user' },
        { grand: '*', to: 'AdminRole' }
   ];