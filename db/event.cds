using { managed, cuid ,Currency } from '@sap/cds/common';
using sap from '@sap/cds/common';
namespace sap.cae.eventmanagement;  

/* Event header Entity */
entity Events : managed, cuid {   
    identifier              : String                     @title : 'Event ID';
    title                   : localized String(100)      @title : 'Title';
    description             : localized String(500)      @title : 'Description';
    date                    : DateTime                   @title : 'Event Date';
    maxParticipantsNumber   : Integer                    @title : 'Maximum Number of Participants';
    availableFreeSlots      : Integer                    @title : 'Available Free Slots' @readonly;
    participantsFeeAmount   : Decimal(6,2)               @title : 'Paricipation Fee';
    currency                : Association to one sap.common.Currencies;
    statusCode              : Association to one EventStatusCode @title : 'Event Status' @readonly;
    participants            : Composition of many Participants on participants.parent = $self;
    //confirmedParticipants   : Association to many Participants on confirmedParticipants.parent = $self and confirmedParticipants.statusCode

}

/* Participants Entity */
entity Participants : managed, cuid {
    parent          : Association to Events;
    identifier      : String;
    name            : String ;
    email           : String;
    mobileNumber    : String;
    statusCode      : Association to one ParticipantStatusCode @readonly;
}

/* Code List Data Type with Fixed values */
type ParticipantStatus : Integer enum{
  InProcess = 1;
  Confirmed = 2;
  Cancelled = 3;
}

entity ParticipantStatusCode : sap.common.CodeList {
        @Common.Text : {
            $value                 : descr,
            ![@UI.TextArrangement] : #TextOnly
        }
    key code : Integer @(title : '{i18n>ParticipantStatusCode}') default 1
}

type EventStatus : Integer enum{
  NotReleased   = 0;
  Published     = 1;
  Booked        = 2;
  Completed     = 3;
  Blocked       = 4;
  Cancelled     = 5;
  
  // SAM => 0 -> 1 -> 2 -> 3  , 0 -> 1 -> 3 , 0 -> 1 -> 4 -> 1 ... ,  
  // Completed events cannot be cancelled / blocked / published 
  // NotReleased and Cancelled events can be deleted  ( Published , Booked , Completed , Blocked events cannot be deleted)
}
entity EventStatusCode : sap.common.CodeList {
        @Common.Text : {
            $value                 : descr,
            ![@UI.TextArrangement] : #TextOnly
        }
    key code : Integer @(title : '{i18n>EventStatusCode}') default 0
}

annotate Events with @fiori.draft.enabled{
    ID                      @Core.Computed;
    identifier              @mandatory;
    title                   @mandatory;
    description             ;
    date                    @mandatory;
    maxParticipantsNumber   @mandatory;  
    participantsFeeAmount   @Measures.ISOCurrency: currency_code;
    //participantsFeeAmount @Measures.Unit: currency_code;       
}

annotate Participants with {
    ID              @Core.Computed;
    identifier      @mandatory ;
    name            @mandatory;  
    mobileNumber    ; 
    email           ; 
}
