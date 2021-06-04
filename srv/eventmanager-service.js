const cds = require('@sap/cds')


/** Service implementation for Event Management service */

module.exports = cds.service.impl(srv => {

   // set the initial value for available slots and status of the event. 
   srv.before("CREATE", "Events", async req => {
        try {
            
            req.data.statusCode = 0;
            req.data.availableFreeSlots = req.data.maxParticipantsNumber ;
        } catch (error) {
            req.error(error);
        }
    })

       // set the initial value for available slots and status of the event. 
   srv.after("UPDATE", "Events", async req => {
        try {
            if ( req.data.maxParticipantsNumber === req.data.confirmedParticipants)
            {
                req.data.statusCode = 2;
            }
        } catch (error) {
            req.error(error);
        }
    })

    /* Set the Event status based on available free slots */
    /*srv.after("READ", "Events", each => {
    //Calculate Release and Processing Criticality
        if (each.availableFreeSlots > 0 ) {
            each["statusCode"] = 2 ;
        } else {
             each["statusCode"] = 1 ;
        }
        
    }); 
*/
        /* dont allow completed events to be deleted */
    srv.on("DELETE", "Events", async (req, next) => {
         const { Events } = srv.entities;
         const tx = srv.transaction(req);
         const result = await tx.read(Events).columns("statusCode").where({ ID: req.data.ID });
        //TODO: check the correct status codes (lifeCycle at Operation level?)
        if (result[0].statusCode === 1 || result[0].statusCode === 2 || result[0].statusCode === 3 || result[0].statusCode === 4) {
            //TODO: how to send localized error messages?
            req.reject(409, "Deletion is rejected : Cannot delete completed Events");
            return req;
        } else {
            //Call default implementation for 'on'
            return await next();
        }
    });

    srv.on("cancel", async req => {
        try {
            const { Events } = srv.entities;
            const tx = cds.transaction(req);
            const events = await tx.run(SELECT.from(Events).where({ ID: req.params[0] }));
           
            let eventIDs = [];
            events.forEach(event => {
                
                if (event.statusCode === 3){
                    req.error("Action not successfull : Completed event "+event.identifier +" cannot be cancelled");
                }else{
                    eventIDs.push(event.ID);
                }
            });

            //update cancellation status of event 
            let eventsRes = await tx.run(
            UPDATE(Events).set({statusCode : 5 }).where("ID in", eventIDs));

            if (eventsRes != eventIDs.length) {
                req.error("Action not successfull");
            }else{
                //success action
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("complete", async req => {
        try {
            const { Events } = srv.entities;
            const tx = cds.transaction(req);
            const events = await tx.run(SELECT.from(Events).where({ ID: req.params[0] }));
           
            let eventIDs = [];
            events.forEach(event => {
                            
                    eventIDs.push(event.ID);
              
            });

            //update cancellation status of event 
            let eventsRes = await tx.run(
            UPDATE(Events).set({statusCode : 3 }).where("ID in", eventIDs));

            if (eventsRes != eventIDs.length) {
                req.error("Complete Action not successfull");
            }else{
                //success action
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("block", async req => {  
        try {
            const { Events } = srv.entities;
            const tx = cds.transaction(req);
            const events = await tx.run(SELECT.from(Events).where({ ID: req.params[0] }));
           
            let eventIDs = [];
            events.forEach(event => {
                
                if (event.statusCode === 3){
                    req.error("Action not successfull : Completed event "+event.identifier +" cannot be blocked");
                }else{
                    eventIDs.push(event.ID);
                }
        
            });

            //update cancellation status of event 
            let eventsRes = await tx.run(
            UPDATE(Events).set({statusCode : 4 }).where("ID in", eventIDs));

            if (eventsRes != eventIDs.length) {
                req.error("Block Action not successfull");
            }else{
                //success action
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("publish", async req => {
        try {
            const { Events } = srv.entities;
            const tx = cds.transaction(req);
            const events = await tx.run(SELECT.from(Events).where({ ID: req.params[0] }));
           
            let eventIDs = [];
            events.forEach(event => {

                 if (event.statusCode === 3){
                    req.error("Action not successfull : Completed event "+event.identifier +" cannot be published");
                }else{
                    eventIDs.push(event.ID);
                }
                
            });

            //update cancellation status of event 
            let eventsRes = await tx.run(
            UPDATE(Events).set({statusCode : 1 }).where("ID in", eventIDs));

            if (eventsRes != eventIDs.length) {
                req.error("Publish Action not successfull");
            }else{
                //success action
            }
      
        } catch (error) {
            req.error(error);
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
