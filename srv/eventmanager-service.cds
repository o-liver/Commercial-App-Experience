using { sap.cae.eventmanagement as eventmanagement } from '../db/event';
using sap from '@sap/cds/common';  

service EventManager @(path:'eventmanager', impl: './eventmanager-service.js', requires:['EventManagerRole', 'AdminRole']) {

  entity Currencies as projection on sap.common.Currencies;

  @odata.draft.enabled  
  entity Events as projection on eventmanagement.Events {
    *, //count( confirmedParticipants.ID ) as participantsCount : Integer
    virtual null as eventStatusCriticality: Integer 
  } 
    //group by ID  // to make sure to pi
     actions{
        @(Common.SideEffects: { TargetProperties: [ '_event.statusCode','_event.availableFreeSlots','_event.maxParticipantsNumber' ] },
        cds.odata.bindingparameter.name : '_event' )
        action cancel() returns Events;

        @(Common.SideEffects: { TargetProperties: [ '_event.statusCode','_event.availableFreeSlots','_event.maxParticipantsNumber' ] },
        cds.odata.bindingparameter.name : '_event' )
        action complete() returns Events;

        @(Common.SideEffects: { TargetProperties: [ '_event.statusCode','_event.availableFreeSlots','_event.maxParticipantsNumber' ] },
        cds.odata.bindingparameter.name : '_event' )
        action block() returns Events;

        @(Common.SideEffects: { TargetProperties: [ '_event.statusCode','_event.availableFreeSlots','_event.maxParticipantsNumber' ] },
        cds.odata.bindingparameter.name : '_event' )
        action publish() returns Events;
    };
 
  entity Participants as projection on eventmanagement.Participants {
      *,
      virtual null as participantStatusCriticality: Integer 
  }actions{
      @(Common.SideEffects: { TargetEntities: [ '_participant','_participant/parent'] }, // refresh the all fields of the entity participant and event
      cds.odata.bindingparameter.name : '_participant' )
      action cancelParticipation() returns Participants;

      @(Common.SideEffects: { TargetProperties: [ '_participant/statusCode','_participant/parent/statusCode','_participant/parent/availableFreeSlots','_participant/parent/maxParticipantsNumber' ] },
      cds.odata.bindingparameter.name : '_participant' )
      action confirmParticipation() returns Participants;
  };

  // Function to return logged in user information
  type userRoles { identified: Boolean; authenticated: Boolean; };
  type user { user: String; locale: String; roles: userRoles };
  function userInfo() returns user;

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
