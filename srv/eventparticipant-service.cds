using { sap.cae.eventmanagement as eventparticipant } from '../db/event';

service EventParticipant @(path:'eventparticipant',impl : './eventparticipant-service.js', requires:['EventParticipantRole']) {

    /** For displaying lists of Events */
  @readonly entity Events as projection on eventparticipant.Events
  excluding { createdBy ,modifiedBy , createdAt };

    /** Cannot delete participants ( can create and read participants list ) */
  @insertonly @readonly entity Participants as projection on eventparticipant.Participants;

    annotate Event with {
        ID                    @Core.Computed;
    };
}

// TODO
// Participants only see events with remaining slots or they are assigned to
// annotate EventParticipant.Events with 
//     @restrict: [
//         { grant: ['READ'], to: 'EventParticipantRole', where: 'availableFreeSlots > 0 or exists (participants[name = $user])' }
//    ];