using { sap.cae.eventmanagement as eventparticipant } from '../db/event';

service EventParticipant @(path:'eventparticipant',impl : './eventparticipant-service.js', requires:['EventParticipantRole', 'AdminRole']) {

    /** For displaying lists of Events */
  @readonly entity Events as projection on eventparticipant.Events
  excluding { createdBy ,modifiedBy , createdAt };

    /** Cannot delete participants ( can create and read participants list ) */
  entity Participants as projection on eventparticipant.Participants;

    annotate Event with {
        ID                    @Core.Computed;
    };
}

// Event participants can read all participants, add new participants, change participants they added themseves
// Admins have no restrictions
annotate EventParticipant.Participants with 
    @restrict: [
        { grant: ['READ', 'CREATE'], to: 'EventParticipantRole'},
        { grant: ['*'], to: 'EventParticipantRole', where: 'createdBy = $user' },
        { grand: '*', to: 'AdminRole' }
   ];