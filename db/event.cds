using { managed, cuid ,Currency } from '@sap/cds/common';
namespace sap.cae.eventmanagement;

/* Event header Entity */
entity Events : managed, cuid {   
    identifier              : String          @title : 'Event ID';
    title                   :  String(100)    @title : 'Title';
    description             :  String(500)    @title : 'Description';
    date                    : DateTime        @title : 'Event Date';
    maxParticipantsNumber   : Integer         @title : 'Maximum Number of Participants';
    availableFreeSlots      : Integer         @title : 'Available Free Slots';
    participantsFeeAmount   : Decimal(6,2)    @title : 'Paricipation Fee';
    currency                : Currency;
    statusCode              : EventStatus     @title : 'Event Status';
    participants            : Composition of many Participants on participants.parent = $self;
    confirmedParticipants   : Association to many Participants on confirmedParticipants.parent = $self and confirmedParticipants.statusCode = 'Confirmed'
    //title  : localized String(111);
    //descr  : localized String(1111); 
}

/* Participants Entity */
entity Participants : managed, cuid {
    parent          : Association to Events;
    identifier      : String;
    name            : String ;
    email           : String;
    mobileNumber    : String;
    statusCode      : Status;
}

/* Code List Data Type with Fixed values */
type Status : Integer enum{
  InProcess = 1;
  Confirmed = 2;
  Cancelled = 3;
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

annotate Events with {
    ID                      @Core.Computed;
    identifier              @mandatory;
    title                   @mandatory;
    description             ;
    date                    @mandatory;
    maxParticipantsNumber   @mandatory;        
}

annotate Participants with {
    ID              @Core.Computed;
    identifier      @mandatory ;
    name            @mandatory;  
    mobileNumber    ; 
    email           ; 
}
