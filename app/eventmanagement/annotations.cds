using EventManager as service from 'cae-poc../../../home/user/projects/Commercial-App-Experience/srv/eventmanager-service';


annotate EventManager.Events with @(
    UI : 
    {        
        SelectionFields : [ identifier, date,availableFreeSlots ],
        LineItem        : [ 
            { $Type : 'UI.DataFieldForAction', Label  : 'Publish',     Action : 'EventManager.publish'  },
            { $Type : 'UI.DataFieldForAction', Label  : 'Block',       Action : 'EventManager.block'    },
            { $Type : 'UI.DataFieldForAction', Label  : 'Cancel',      Action : 'EventManager.cancel'   },
            { $Type : 'UI.DataFieldForAction', Label  : 'Complete',    Action : 'EventManager.complete' },
            { $Type : 'UI.DataField', Label  : 'ID',                   Value : identifier               },
            { $Type : 'UI.DataField', Label  : 'Title',                Value : title                    },
            { $Type : 'UI.DataField', Label  : 'Description',          Value : description              },
            { $Type : 'UI.DataField', Label  : 'Date',                 Value : date                     },
            { $Type : 'UI.DataField', Label  : 'Available Free Slots', Value : availableFreeSlots       },
            { $Type : 'UI.DataField', Label  : 'Status',               Value : statusCode               }
        ],
        Identification : [ 
            { $Type : 'UI.DataFieldForAction', Label  : 'Publish',     Action : 'EventManager.publish'  },
            { $Type : 'UI.DataFieldForAction', Label  : 'Block',       Action : 'EventManager.block'    },
            { $Type : 'UI.DataFieldForAction', Label  : 'Cancel',      Action : 'EventManager.cancel'   },
            { $Type : 'UI.DataFieldForAction', Label  : 'Complete',    Action : 'EventManager.complete' }
         ],
        HeaderInfo         : {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : 'Event',
            TypeNamePlural : 'Events',
            Title          : { $Type : 'UI.DataField', Value : identifier  },
            Description    : { $Type : 'UI.DataField', Value : description }
        },
        HeaderFacets: [
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#Date' },
            { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#AvailableFreeSlots'},   
            { $Type : 'UI.ReferenceFacet', Target : '@UI.FieldGroup#Created'}     
        ],
        DataPoint #Date :{ 

                Title : 'Event Date',    
                Value : date,
                ![@UI.Emphasized],
        },
        DataPoint #AvailableFreeSlots :{ 

                Title : 'Available Free Slots',    
                Value : availableFreeSlots,
                ![@UI.Emphasized],
        },
        Facets             : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Event General Data',
            ID     : 'GeneralData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#Values], ID : 'GeneralData'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Participants',
            ID     : 'Participants',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : 'participants@UI.LineItem', ID : 'Participants'
            }],
        },
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Administative Data',
            ID     : 'AdministrativeData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#AdminData], ID : 'AdministrativeData'
            }],
        }],
            // Object page field groups
        FieldGroup #Values : {
            Data : [           
            { $Type : 'UI.DataField', Value : identifier,  Label : 'ID' },
            { $Type : 'UI.DataField', Value : title,  Label : 'Title' },
            { $Type : 'UI.DataField', Value : description, Label : 'Description' },
            { $Type : 'UI.DataField', Value : date, Label : 'Event Date' },
            { $Type : 'UI.DataField', Value : maxParticipantsNumber, Label : 'Maximum Allowed Participants' },
            { $Type : 'UI.DataField', Value : maxParticipantsNumber, Label : 'Maximum Allowed Participants' },
            { $Type : 'UI.DataField', Value : availableFreeSlots, Label : 'Available Free Slots' },    
            { $Type : 'UI.DataField', Value : participantsFeeAmount, Label : 'Participation Fee' },          
            
            
            
        ]},

        FieldGroup #AdminData : {
            Data : [           
            { $Type : 'UI.DataField', Value : createdBy,  Label : 'Created By' },
            { $Type : 'UI.DataField', Value : createdAt,  Label : 'Created On' },
            { $Type : 'UI.DataField', Value : modifiedBy, Label : 'Changed By' },
            { $Type : 'UI.DataField', Value : modifiedAt, Label : 'Changed On' }               
            
            
        ]} ,
        FieldGroup #Created : {
            Data : [           
            { $Type : 'UI.DataField', Value : createdAt,  Label : 'Created On' },
                   
            
        ]}
    }    
);

annotate EventManager.Participants with @(
        SelectionFields : [ identifier, email,mobileNumber ],
        UI.LineItem : [
            {
                $Type : 'UI.DataField',
                Value : identifier,
                Label  : 'ID',  
                ![@UI.Importance] : #High,
            },
            {
                $Type : 'UI.DataField',
                Value : email,
                Label  : 'Email',  
                ![@UI.Importance] : #High,
            },
            {
                $Type : 'UI.DataField',
                Value : mobileNumber,
                Label  : 'Mobile Number',  
                ![@UI.Importance] : #High,
            },
        ],
       HeaderInfo         : 
       {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : 'Event',
            TypeNamePlural : 'Events',
            Title          : { $Type : 'UI.DataField', Value : identifier  },
            Description    : { $Type : 'UI.DataField', Value : email }
        },
        
       
        Facets             : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Event General Data',
            ID     : 'GeneralData',
            Facets : [
            { 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#Values], ID : 'GeneralData'
            }],
        },
        ],
            // Object page field groups
        FieldGroup #Values : {
            Data : [           
            { $Type : 'UI.DataField', Value : identifier, Label : 'Participant ID' },
            { $Type : 'UI.DataField', Value : email,  Label : 'Email ID' },
            { $Type : 'UI.DataField', Value : mobileNumber, Label : 'Mobile Number' }     
            
            
            
        ]},

  
    
);

