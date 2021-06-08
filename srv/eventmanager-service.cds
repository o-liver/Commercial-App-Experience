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
  
  entity Participants as projection on eventmanagement.Participants {
      *
  }actions{
      action cancelParticipation() returns Participants;
  };


                /* Cancelled list of participants */
  // entity CancelledParticipants as select eventmanagement.Participants{ * } where status = 3;

    // @Core.Computed annotation prevents the "UUID popup" on create
    annotate EventManager.Events with {
        ID @Core.Computed
    }

  annotate EventManager.Events with @(
    UI : 
    {
        SelectionFields : [
            identifier,
            date,
            availableFreeSlots
        ],
        LineItem        : [
            {
                $Type  : 'UI.DataFieldForAction',
                Label  : 'Publish',
                Action : 'EventManager.publish'
            },
            {
                $Type  : 'UI.DataFieldForAction',
                Label  : 'Block',
                Action : 'EventManager.block'
            },
            {
                $Type  : 'UI.DataFieldForAction',
                Label  : 'Cancel',
                Action : 'EventManager.cancel'
            },
            {
                $Type  : 'UI.DataFieldForAction',
                Label  : 'Complete',
                Action : 'EventManager.complete'
            },
            {
                $Type : 'UI.DataField',
                Value : identifier
            },
            {
                $Type : 'UI.DataField',
                Value : title
            },
            {
                $Type : 'UI.DataField',
                Value : description
            },
            {
                $Type : 'UI.DataField',
                Value : date
            },
            {
                $Type : 'UI.DataField',
                Value : availableFreeSlots
            },
            {
                $Type : 'UI.DataField',
                Value : statusCode
            }
        ]
    }    
);
}
