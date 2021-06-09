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

     srv.before("READ", "Events", async req => {
        try {
            
            var test = 1;
        } catch (error) {
            req.error(error);
        }
    })
    srv.after("READ", "Events", async req => {
        try {
            
            var test = 1;
        } catch (error) {
            req.error(error);
        }
    })
     srv.on("READ", "Events", async req => {
        try {
            
            var test = 1;
        } catch (error) {
            req.error(error);
        }
    })

        function validateEmail(email) {
        var regexEmail = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        if (email.match(regexEmail)) {
            return true; 
        } else {
            return false; 
        }
    }

    function validatePhone(phone) {
        var regexPhone = /^\+(?:[0-9] ?){6,14}[0-9]$/;

        if (phone.match(regexPhone)) {
            return true; 
        } else {
            return false; 
        }
    }
  // reject creation of participants in case there are no available slots
   srv.before("CREATE", "Participants", async req => {
        try {
           const { EventManager } = cds.services;
            const { Events , Participants } = cds.entities("sap.cae.eventmanagement");

            // Check the validity of email before creation of participant
            if( req.data.email !== 'undefined' && req.data.email ) {
                if ( validateEmail(req.data.email ) === false ) {
                    // invalid email
                    req.error("Invalid Email ID: "+req.data.email, +"please enter valid email ");  
                }
            }
            // Check the validity of phone  before creation of participant
            if( req.data.mobileNumber !== 'undefined' && req.data.mobileNumber ) {
                if ( validatePhone(req.data.mobileNumber ) === false ) {
                    // invalid phone number
                    req.error("Invalid Mobile Number: "+req.data.mobileNumber, +"please enter valid mobile number ");  
                }
            }

            // Check the status of the event status before adding participant 
            let eventIDs = [];
            eventIDs.push(req.data.parent_ID); 
            const events = await EventManager.read(Events).where("ID in", eventIDs);   
            if ( events[0].statusCode === 2)
            {
              req.error("Cannot Add Participants : Event is fully booked , try after some time :-) ");  
            }
            if ( events[0].statusCode === 3)
            {
              req.error("Cannot Add Participants : Event is completed , better luck next time :-) ");  
            }
            if ( events[0].statusCode === 4)
            {
              req.error("Cannot Add Participants : Event is blocked , try after publishing the event :-) ");  
            }
            if ( events[0].statusCode === 5)
            {
              req.error("Cannot Add Participants : Event is cancelled , try after publishing the event :-) ");  
            }
                        if ( events[0].statusCode === 0)
            {
              req.error("Cannot Add Participants : Event is not released , try after publishing the event :-) ");  
            }
        } catch (error) {
            req.error(error);
        }
    })

    // check the validity of email
   srv.after("UPDATE", "Participants", async req => {
        try {
                      
            const { EventManager } = cds.services;
            const { Participants } = cds.entities("sap.cae.eventmanagement");
            let eventIDs = [];
            eventIDs.push(req.ID);
            if( req.email !== 'undefined' && req.email ) {
                // Check the validity of email after update of participant
                if ( validateEmail(req.email ) === false ) {
                    // invalid email
                    req.error("Invalid Email ID: "+req.email, +"please enter valid email ");  
                }else{
                    //update cancellation status of event 
                    const updateEvent = await UPDATE(Participants).set({email: req.email}).where("ID in", eventIDs);
                }
            }
             if( req.mobileNumber !== 'undefined' && req.mobileNumber ) {
                // Check the validity of Phone after update of participant
                if ( validatePhone(req.mobileNumber ) === false ) {
                    // invalid phone
                    req.error("Invalid Email ID: "+req.email, +"please enter valid email ");  
                }else{
                    //update phone
                    const updateEvent = await UPDATE(Participants).set({email: req.phone}).where("ID in", eventIDs);
                }
             }
        } catch (error) {
            req.error(error);
        }
    })

          // set the available slots acordingly and set the blocked status ( incase its the last available slot )
       srv.after("CREATE", "Participants", async req => {
        try {
            const { EventManager } = cds.services;
            const { Events , Participants } = cds.entities("sap.cae.eventmanagement");
            let eventIDs = [];
            eventIDs.push(req.parent_ID);
            let participantIDs = [];
            participantIDs.push(req.ID);
            const events = await EventManager.read(Events).where("ID in", eventIDs);
            const updateParticipant = await UPDATE(Participants).set({statusCode: 2 }).where("ID in", participantIDs);
            const availableFreeSlots = events[0].availableFreeSlots - 1;
            const updateEvent = await UPDATE(Events).set({ availableFreeSlots: availableFreeSlots , 
                                                           statusCode: (availableFreeSlots === 0 ? 2 : events[0].statusCode)})
                                                    .where("ID in", eventIDs);
        } catch (error) {
            req.error(error);
        }
    })
    
    // set the event status to booked based on confirmed slots
   srv.after("UPDATE", "Events", async req => {
        try {
                      
            const { EventManager } = cds.services;
            const { Events } = cds.entities("sap.cae.eventmanagement");
            let eventIDs = [];
            eventIDs.push(req.ID);
            const events = await EventManager.read(Events).where("ID in", eventIDs);
            
                if ( events[0].availableFreeSlots != undefined){
                        if ( events[0].availableFreeSlots <= 0)
                        {
                           
                            //update cancellation status of event 
                           const updateEvent = await UPDATE(Events).set({statusCode: 2}).where("ID in", eventIDs);

                        }
                }    
           
             
        } catch (error) {
            req.error(error);
        }
    })


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
            let data = await tx.read(Events).where("ID in", eventIDs);


            if (eventsRes != eventIDs.length) {
                req.error("Action not successfull");
            }else{
                 req.info("Event Cancelled successfully");
            }
            return data;
      
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
            
            let data = await tx.read(Events).where("ID in", eventIDs);


            if (eventsRes != eventIDs.length) {
                req.error("Complete Action not successfull");
            }else{
                 req.info("Event Completed successfully");
            }
            return data;
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
            
            let data = await tx.read(Events).where("ID in", eventIDs);

            if (eventsRes != eventIDs.length) {
                req.error("Block Action not successfull");
            }else{
                 req.info("Event Blocked successfully");
            }
            return data;
      
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
            let data = await tx.read(Events).where("ID in", eventIDs);


            if (eventsRes != eventIDs.length) {
                req.error("Publish Action not successfull");
            }else{
                req.info("Event Published successfully");
            }
            return data;
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("cancelParticipation", async req => {
        try {
            const { Participants } = srv.entities;
            const tx = cds.transaction(req);
            const participants = await tx.run(SELECT.from(Participants).where({ ID: req.params[0] }));
           
            let participantsIDs = [];
            participants.forEach(participant => {

                    participantsIDs.push(participant.ID);
           
            });

            //update cancellation status of participant 
            let participantsRes = await tx.run(
            UPDATE(Participants).set({statusCode : 3 }).where("ID in", participantsIDs));

            let data = await tx.read(Participants).where("ID in", participantsIDs);

            if (participants != participantsIDs.length) {
                req.error("Action not successfull");
            }else{
                 req.info("Event Participation cancelled successfully");
            }
            return data;
      
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
