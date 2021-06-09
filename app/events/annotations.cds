using EventManager as service from '../../srv/eventmanager-service';

annotate EventManager.Events with @(Capabilities :{
    DeleteRestrictions.Deletable  : true,
    UpdateRestrictions.Updatable  : true,
    InsertRestrictions.Insertable : true
});

annotate EventManager.Events with @(
    UI : 
    {
        SelectionFields : [ identifier, date,availableFreeSlots ],
        LineItem        : [ 
            { $Type : 'UI.DataFieldForAction', Label  : 'Publish',     Action : 'EventManager.publish' },
            { $Type : 'UI.DataFieldForAction', Label  : 'Block',       Action : 'EventManager.block' },
            { $Type : 'UI.DataFieldForAction', Label  : 'Cancel',      Action : 'EventManager.cancel' },
            { $Type : 'UI.DataFieldForAction', Label  : 'Complete',    Action : 'EventManager.complete' },
            { $Type : 'UI.DataField', Label  : 'ID',                   Value : identifier },
            { $Type : 'UI.DataField', Label  : 'Title',                Value : title },
            { $Type : 'UI.DataField', Label  : 'Description',          Value : description },
            { $Type : 'UI.DataField', Label  : 'Date',                 Value : date },
            { $Type : 'UI.DataField', Label  : 'Available Free Slots', Value : availableFreeSlots },
            { $Type : 'UI.DataField', Label  : 'Status',               Value : statusCode }
        ],
        HeaderInfo         : {
            $Type          : 'UI.HeaderInfoType',
            TypeName       : 'Event',
            TypeNamePlural : 'Events',
            Title          : { $Type : 'UI.DataField', Value : identifier  },
            Description    : { $Type : 'UI.DataField', Value : description }
        },
        Facets             : [{
            $Type  : 'UI.CollectionFacet',
            Label  : 'Events',
            ID     : 'GeneralData',
            Facets : [{ 
                $Type : 'UI.ReferenceFacet', Target : ![@UI.FieldGroup#Values], ID : 'GeneralData'
            }],
        }],
            // Object page field groups
        FieldGroup #Values : {
            Data : [
            { $Type : 'UI.DataField', Value : description, Label : 'Description' },
            { $Type : 'UI.DataField', Value : identifier,  Label : 'ID' }
        ]}
    }    
);