using { sap.cae.eventmanagement as eventparticipant } from '../db/event';
service EventParticipant @(path:'eventparticipant',impl : './eventparticipant-service.js') {

    /** For displaying lists of Events */
  @readonly entity Events as projection on eventparticipant.Events
  excluding { createdBy ,modifiedBy , createdAt };

    /** Cannot delete participants ( can create and read participants list ) */
  @insertonly @readonly entity Participants as projection on eventparticipant.Participants;

    annotate Event with {
        ID                    @Core.Computed;
    };
}
