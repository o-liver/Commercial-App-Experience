//using EventManager as service from 'cae-poc../../../home/user/projects/Commercial-App-Experience/srv/eventmanager-service';
using EventManager as service from '../../srv/eventmanager-service';

annotate EventManager.Events with {
    participantsFeeAmount @Measures.ISOCurrency: currency_code;
    //participantsFeeAmount @Measures.Unit: currency_code; 
};

annotate EventManager.Events with @(
    UI : 
    {        
        SelectionFields : [ identifier, date,maxParticipantsNumber,availableFreeSlots,statusCode_code,participantsFeeAmount, currency_code ],
                LineItem        : [ 
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>publish}',     Action : 'EventManager.publish'  },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>block}',       Action : 'EventManager.block'    },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>cancel}',      Action : 'EventManager.cancel'   },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>complete}',    Action : 'EventManager.complete' },
            { $Type : 'UI.DataField', Label  : '{i18n>id}',                   Value : identifier               },
            { $Type : 'UI.DataField', Label  : '{i18n>title}',                Value : title                    },
            { $Type : 'UI.DataField', Label  : '{i18n>description}',          Value : description              },
            { $Type : 'UI.DataField', Label  : '{i18n>date}',                 Value : date                     },            
            {         
                Value : statusCode.code,
                @UI.Hidden : true
            },            
            { $Type : 'UI.DataField', Label  : '{i18n>participationFee}',     Value : participantsFeeAmount    },
            //{ $Type : 'UI.DataField', Label  : '{i18n>currency}',             Value : currency.code          },
            //{ $Type : 'UI.DataField', Label  : '{i18n>currency}',             Value : currency.symbol        },
            
            { $Type : 'UI.DataField', Label  : '{i18n>availableFreeSlots}',   Value : availableFreeSlots       },
            { $Type : 'UI.DataField', Label  : '{i18n>createdBy}',            Value : createdBy                },
            { $Type : 'UI.DataField', Label  : '{i18n>status}',               Value : statusCode.descr , Criticality : eventStatusCriticality        }
        ],
        Identification : [ 
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>publish}',     Action : 'EventManager.publish'  },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>block}',       Action : 'EventManager.block'    },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>cancel}',      Action : 'EventManager.cancel'   },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>complete}',    Action : 'EventManager.complete' }
         ],
        HeaderInfo         : {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : '{i18n>event}',
            TypeNamePlural : '{i18n>events}',
            Title          : { $Type : 'UI.DataField', Value : identifier  },
            Description    : { $Type : 'UI.DataField', Value : description }
        },
        HeaderFacets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Date' },
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#AvailableFreeSlots'},             
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#ParticipantsFeeAmount'}, 
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#EventStatus'},  
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Created'}     
        ],
        DataPoint #Date :{ 

                Title : '{i18n>eventDate}',    
                Value : date,
                ![@UI.Emphasized],
        },
        DataPoint #AvailableFreeSlots :{ 

                Title : '{i18n>availableFreeSlots}',    
                Value : availableFreeSlots,
                ![@UI.Emphasized],
        },
         DataPoint #ParticipantsFeeAmount :{ 

                Title : '{i18n>participationFee}',    
                Value : participantsFeeAmount,
                ![@UI.Emphasized],
        },
        DataPoint #EventStatus :{ 

                Title : '{i18n>status}',    
                Value : statusCode.descr,
                Criticality : eventStatusCriticality  ,
                ![@UI.Emphasized],
        },
        Facets             : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>generalData}',
            ID     : 'GeneralData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#Values], ID : 'GeneralData'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>participants}',
            ID     : 'Participants',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : 'participants@UI.LineItem', ID : 'Participants'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>administativeData}',
            ID     : 'AdministrativeData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#AdminData], ID : 'AdministrativeData'
            }],
        }],
            // Object page field groups
        FieldGroup #Values : {
            Data : [           
            { $Type : 'UI.DataField', Value : identifier,  Label : '{i18n>eventID}' },
            { $Type : 'UI.DataField', Value : statusCode.code,  Label : 'status code' },
            { $Type : 'UI.DataField', Value : title,  Label : '{i18n>title}' },
            { $Type : 'UI.DataField', Value : description, Label : '{i18n>description}' },
            { $Type : 'UI.DataField', Value : date, Label : '{i18n>eventDate}' },
            { $Type : 'UI.DataField', Value : maxParticipantsNumber, Label : '{i18n>maximumAllowedParticipants}' },
            { $Type : 'UI.DataField', Value : availableFreeSlots, Label : '{i18n>availableFreeSlots}' },    
            { $Type : 'UI.DataField', Value : participantsFeeAmount, Label : '{i18n>participationFee}' },
            //{ $Type : 'UI.DataField', Value : currency.code, Label : '{i18n>currency}' },
            //{ $Type : 'UI.DataField', Value : currency.descr, Label : '{i18n>currency}' },
            // { $Type : 'UI.DataField', Value : currency.name, Label : '{i18n>currency}' },
            // { $Type : 'UI.DataField', Value : currency.symbol, Label : '{i18n>currency}' }       
            
            
            
        ]},

        FieldGroup #AdminData : {
            Data : [           
            { $Type : 'UI.DataField', Value : createdBy,  Label : '{i18n>createdBy}' },
            { $Type : 'UI.DataField', Value : createdAt,  Label : '{i18n>createdOn}' },
            { $Type : 'UI.DataField', Value : modifiedBy, Label : '{i18n>changedBy}' },
            { $Type : 'UI.DataField', Value : modifiedAt, Label : '{i18n>changedOn}' }               
            
            
        ]} ,
        FieldGroup #Created : {
            Data : [ 
            { $Type : 'UI.DataField', Value : createdBy,  Label : '{i18n>createdBy}' } ,          
            { $Type : 'UI.DataField', Value : createdAt,  Label : '{i18n>createdOn}' },
                             
            
        ]}
    }    
);

annotate EventManager.Participants with @(
UI : 
    { 
        SelectionFields : [ identifier, email,mobileNumber,statusCode_code ],
        LineItem : [
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>confirmParticipation}',    Action : 'EventManager.confirmParticipation' },
            { $Type : 'UI.DataFieldForAction', Label  : '{i18n>cancelParticipation}',     Action : 'EventManager.cancelParticipation'  },             
            {
                $Type : 'UI.DataField',
                Value : identifier,
                Label  : '{i18n>participantID}',  
                ![@UI.Importance] : #High,
            },
            {
                $Type : 'UI.DataField',
                Value : name,
                Label  : '{i18n>name}',  
                ![@UI.Importance] : #High,
            },            
            {
                $Type : 'UI.DataField',
                Value : email,
                Label  : '{i18n>email}',  
                ![@UI.Importance] : #High,
            },
            {
                $Type : 'UI.DataField',
                Value : mobileNumber,
                Label  : '{i18n>mobile}',  
                ![@UI.Importance] : #High,
            },
            {
                $Type : 'UI.DataField',
                Value : statusCode.descr,
                Label  : '{i18n>status}', 
                Criticality : participantStatusCriticality, 
                ![@UI.Importance] : #High,
            },
            {               
                Value : statusCode.code,
                @UI.Hidden : true
            }
        ],
       HeaderInfo         : 
       {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : '{i18n>participant}',
            TypeNamePlural : '{i18n>participants}',
            Title          : { $Type : 'UI.DataField', Value : identifier ,  Label : '{i18n>participantID}'  },
            Description    : { $Type : 'UI.DataField', Value : name       ,  Label : '{i18n>name}'           }
            
        },
        HeaderFacets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#ParticipantStatus'},   
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Created'}     
        ],
        DataPoint #ParticipantStatus :{ 

                Title : '{i18n>status}',    
                Value : statusCode.descr,
                Criticality : participantStatusCriticality  ,
                ![@UI.Emphasized],
        },

        Facets             : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : '{i18n>generalData}',
            ID     : 'GeneralData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#ParticipantDetails], ID : 'GeneralData'
            }],
        },
        
        {
            $Type  : 'UI.CollectionFacet',
             Label  : '{i18n>administativeData}',
            ID     : 'AdministrativeData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#AdminData], ID : 'AdministrativeData'
            }],
        }
        ],
            // Object page field groups
        FieldGroup #ParticipantDetails : {
            Data : [           
            { $Type : 'UI.DataField', Value : identifier,       Label : '{i18n>participantID}'    } ,
            { $Type : 'UI.DataField', Value : name,             Label : '{i18n>name}'             } ,
            { $Type : 'UI.DataField', Value : email,            Label : '{i18n>email}'            } ,
            { $Type : 'UI.DataField', Value : mobileNumber,     Label : '{i18n>mobile}'           }  
            
            
            
        ]},
        FieldGroup #AdminData : {
            Data : [           
            { $Type : 'UI.DataField', Value : createdBy,  Label : '{18n>createdBy}' },
            { $Type : 'UI.DataField', Value : createdAt,  Label : '{i18n>createdOn}' },
            { $Type : 'UI.DataField', Value : modifiedBy, Label : '{i18n>changedBy}' },
            { $Type : 'UI.DataField', Value : modifiedAt, Label : '{18n>changedOn}' }               
            
            
        ]} ,
        FieldGroup #Created : {
            Data : [           
            { $Type : 'UI.DataField', Value : createdAt,  Label : '{18n>createdOn}'  },
            { $Type : 'UI.DataField', Value : modifiedAt,  Label : '{18n>changedOn}' }
                   
            
        ]}

    }
    
);
