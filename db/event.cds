using { managed, cuid ,Currency } from '@sap/cds/common';
namespace sap.cae.eventmanagement;

/* Event header Entity */
entity Events : managed, cuid {
    key ID : Integer;    
    title  :  String(100);
    description  :  String(500);
    date   : DateTime;
    maxParticipantsNumber : Integer;
    participantsFeeAmount  : Decimal(6,2);
    currency : Currency;
    Participants : Composition of many Participants on Participants.parent = $self
    //title  : localized String(111);
    //descr  : localized String(1111); 
}

/* Participants Entity */
entity Participants : managed, cuid {
    parent : Association to Events;
    key ID : Integer;
    name : String ;
    email : String;
    mobileNumber : String;
    statusCode : Status;
}

/* Code List Data Type with Fixed values */
type Status : Integer enum{
  InProcess = 1;
  Confirmed = 2;
  Cancelled = 3;
}
