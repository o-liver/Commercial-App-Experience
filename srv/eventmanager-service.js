const cds = require('@sap/cds')


/** Service implementation for Event Management service */

module.exports = cds.service.impl(srv => {

    srv.after('CREATE', 'Events', each => _initialiseAvailableFreeSlots(each))
    
    /** Function to initialize the available free slots in an event along with status  */ 
    function _initialiseAvailableFreeSlots (each) { 
        each.availableFreeSlots = each.maxParticipantsNumber
        
        //set the status of event to be available
        each.statusCode = 1
    } 

    /* Set the Event status based on available free slots */
    srv.after("READ", "Events", each => {
    //Calculate Release and Processing Criticality
        if (each.availableFreeSlots > 0 ) {
            each["statusCode"] = 2 ;
        } else {
             each["statusCode"] = 1 ;
        }
        
    }); 

        /* dont allow completed events to be deleted */
    srv.on("DELETE", "Events", async (req, next) => {
         const { Events } = srv.entities;
         const tx = srv.transaction(req);
         const result = await tx.read(Events).columns("statusCode").where({ ID: req.data.ID,
                                                              IsActiveEntity: true });
        //TODO: check the correct status codes (lifeCycle at Operation level?)
        if (result[0].statusCode === 3) {
            //TODO: how to send localized error messages?
            req.reject(409, "Deletion is rejected : Cannot delete completed Events");
            return req;
        } else {
            //Call default implementation for 'on'
            return await next();
        }
    });

    
    /*
        const { Participants } = srv.entities ('sap.cae.eventmanagement.Participants')
        srv.after ('READ', 'Events', _reduceAvailableFreeSlots)
        //Function to adjust the free slots in the event  
        function _reduceAvailableFreeSlots (events,req) { 
            const eventsByID = Array.isArray(events) 
                ? events.reduce ((all,o) => { (all[o.ID] = o).total=0; return all },{}) 
                : { [events.ID]: events } 

            return cds.transaction(req) .run ( 
                    SELECT.from(Participants) .columns ('parent_ID', 'Status') 
                        .where ({ parent_ID: {in: Object.keys(eventsByID)} }) 
                ) .then (participants => 
                    participants.forEach (participant => ordersByID [participant.parent_ID] .availableFreeSlots -= 1) 
                    ) 

            
        } 
    */

})

