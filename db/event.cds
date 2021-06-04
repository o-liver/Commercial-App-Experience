using { managed, cuid ,Currency } from '@sap/cds/common';
namespace sap.cae.eventmanagement;

/* Event header Entity */
entity Events : managed, cuid {   
    identifier              : String;
    title                   :  String(100);
    description             :  String(500);
    date                    : DateTime;
    maxParticipantsNumber   : Integer;
    availableFreeSlots      : Integer;
    participantsFeeAmount   : Decimal(6,2);
    currency                : Currency;
    statusCode              : EventStatus;
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
