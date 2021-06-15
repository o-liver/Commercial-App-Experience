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
            const eventID = req.data.parent_ID;

            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: eventID });
   
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
                      
            const participantID = req.ID;
            if( req.email !== 'undefined' && req.email ) {
                // Check the validity of email after update of participant
                if ( validateEmail(req.email ) === false ) {
                    // invalid email
                    req.error("Invalid Email ID: "+req.email, +"please enter valid email ");  
                }else{
                    //update cancellation status of event 
                    const updateEvent = await UPDATE("sap.cae.eventmanagement.Participants").set({email: req.email}).where({ ID: participantID });
                }
            }
             if( req.mobileNumber !== 'undefined' && req.mobileNumber ) {
                // Check the validity of Phone after update of participant
                if ( validatePhone(req.mobileNumber ) === false ) {
                    // invalid phone
                    req.error("Invalid Email ID: "+req.email, +"please enter valid email ");  
                }else{
                    //update phone
                    const updateEvent = await UPDATE("sap.cae.eventmanagement.Participants").set({email: req.phone}).where({ ID: participantID });
                }
             }
        } catch (error) {
            req.error(error);
        }
    })

          // set the available slots acordingly and set the blocked status ( incase its the last available slot )
       srv.after("CREATE", "Participants", async req => {
        try {

            const eventID = req.parent_ID;
            const participantID = req.ID;
            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: eventID });
            const updateParticipant = await UPDATE("sap.cae.eventmanagement.Participants").set({statusCode: 2 }).where({ ID: participantID });
            const availableFreeSlots = events[0].availableFreeSlots - 1;
            const updateEvent = await UPDATE("sap.cae.eventmanagement.Events").set({ availableFreeSlots: availableFreeSlots , 
                                                           statusCode: (availableFreeSlots === 0 ? 2 : events[0].statusCode)})
                                                    .where({ ID: eventID });
        } catch (error) {
            req.error(error);
        }
    })
    
    // set the event status to booked based on confirmed slots
   srv.after("UPDATE", "Events", async req => {
        try {
                      
            const id = req.ID;
           
            const events = await SELECT.from("sap.cae.eventmanagement.Events").columns("availableFreeSlots").where({ ID: id });
            
                if ( events[0].availableFreeSlots != undefined){
                        if ( events[0].availableFreeSlots <= 0)
                        {
                           
                            //update cancellation status of event 
                           const updateEvent = await UPDATE("sap.cae.eventmanagement.Events").set({statusCode: 2}).where({ ID: id });

                        }
                }    
           
             
        } catch (error) {
            req.error(error);
        }
    })


        /* dont allow completed events to be deleted */
    srv.on("DELETE", "Events", async (req, next) => {

         const result = await SELECT.from("sap.cae.eventmanagement.Events").columns("statusCode").where({ ID: req.data.ID });
        //TODO: check the correct status codes (lifeCycle at Operation level?)
        if (result[0].statusCode === 1 || result[0].statusCode === 2 || result[0].statusCode === 3 || result[0].statusCode === 4) {
            //TODO: how to send localized error messages?
            req.reject(409, "Deletion is rejected : Cannot delete Events which are Published / Blocked / Completed (try cancelling and deleting an event)");
            return req;
        } else {
            // send info message
            req.info("Event "+result.identifier+" Deleted successfully");
            return await next();
           
        }
    });

    srv.on("cancel", async req => {
        try {
            const id = (req.params.pop()).ID;
            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });
            // if saved / active instance exist then allow action 
            if (events.length === 1){
                let eventIdentifier ;

                events.forEach(event => {
                    eventIdentifier = event.identifier;
                    if (event.statusCode === 3){
                        req.error("Action not successfull : Completed event "+eventIdentifier +" cannot be cancelled");
                    }
                });

                //update cancellation status of event 
                let eventsRes = await
                UPDATE("sap.cae.eventmanagement.Events").set({statusCode : 5 }).where({ ID: id });
                
                // get the updated event record to be returned from this method ( for refresh of UI with updated data)
                let data = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });


                if (eventsRes === 1) {
                    req.info("Event "+eventIdentifier +" Cancelled successfully");
                }else{
                    req.error("Event "+eventIdentifier +" Cancel action failed , try after some time");
                }
            
                return data;
            }
            // incase event is not saved / not active then throw error
            else{
                req.error("Save the Event and try the action again");
            }

      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("complete", async req => {
        try {
            const id = (req.params.pop()).ID;
            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });
            // if saved / active instance exist then allow action 
            if (events.length === 1){
                let eventIdentifier ;

                events.forEach(event => {
                    eventIdentifier = event.identifier;
                    if (event.statusCode === 3){
                        req.error("Action not successfull : Completed event "+eventIdentifier +" cannot be completed");
                    }
                });

                //update complete status of event 
                let eventsRes = await
                UPDATE("sap.cae.eventmanagement.Events").set({statusCode : 3 }).where({ ID: id });
                
                // get the updated event record to be returned from this method ( for refresh of UI with updated data)
                let data = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });


                if (eventsRes === 1) {
                    req.info("Event "+eventIdentifier +" Completed successfully");
                }else{
                    req.error("Event "+eventIdentifier +" Complete action failed , try after some time");
                }
            
                return data;
            }
            // incase event is not saved / not active then throw error
            else{
                req.error("Save the Event and try the action again");
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("block", async req => {
        try {
            const id = (req.params.pop()).ID;
            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });
            // if saved / active instance exist then allow action 
            if (events.length === 1){
                let eventIdentifier ;

                events.forEach(event => {
                    eventIdentifier = event.identifier;
                    if (event.statusCode === 3){
                        req.error("Action not successfull : Completed event "+eventIdentifier +" cannot be blocked");
                    }
                });

                //update block status of event 
                let eventsRes = await
                UPDATE("sap.cae.eventmanagement.Events").set({statusCode : 4 }).where({ ID: id });
                
                // get the updated event record to be returned from this method ( for refresh of UI with updated data)
                let data = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });


                if (eventsRes === 1) {
                    req.info("Event "+eventIdentifier +" Blocked successfully");
                }else{
                    req.error("Event "+eventIdentifier +" Block action failed , try after some time");
                }
            
                return data;
            }
            // incase event is not saved / not active then throw error
            else{
                req.error("Save the Event and try the action again");
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("publish", async req => {
        try {
            const id = (req.params.pop()).ID;
            const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });
            
            // if saved / active instance exist then allow action 
            if (events.length === 1){
                let eventIdentifier ;

                events.forEach(event => {
                    eventIdentifier = event.identifier;
                    if (event.statusCode === 3){
                        req.error("Action not successfull : Completed event "+eventIdentifier +" cannot be published");
                    }
                });

                //update publish status of event 
                let eventsRes = await
                UPDATE("sap.cae.eventmanagement.Events").set({statusCode : 1 }).where({ ID: id });
                
                // get the updated event record to be returned from this method ( for refresh of UI with updated data)
                let data = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: id });


                if (eventsRes === 1) {
                    req.info("Event '"+eventIdentifier +"' Published successfully");
                }else{
                    req.error("Event '"+eventIdentifier +"' Publish action failed , try after some time");
                }
            
                return data;
            }
            // incase event is not saved / not active then throw error
            else{
                req.error("Save the Event and try the action again");
            }
      
        } catch (error) {
            req.error(error);
        }

     });

     srv.on("cancelParticipation", async req => {
        try {

            const id = (req.params.pop()).ID;
            const isActiveEntity = (req.params.pop()).IsActiveEntity;

            let participantData = await SELECT.from("sap.cae.eventmanagement.Participants").where({ ID: id });

            let participantsRes;            
 
            // return error on execution of action on draft instance
            if (participantData.length === 1){
                //update cancellation status of participant 
                participantsRes = await 
                UPDATE("sap.cae.eventmanagement.Participants").set({statusCode : 3 }).where({ ID: id });

                participantData = await SELECT.from("sap.cae.eventmanagement.Participants").where({ ID: id });
                          
            

                if (participantsRes !== 1) {
                    req.error("Participation of Participant with ID : '"+participantData[0].identifier+"' cancellation failed , try after some time ");
                }else{
                    req.info("Participation of Participant with ID : '"+participantData[0].identifier+"' cancelled successfully");
                }
                

                //await tx.commit();
                return participantData;
            }
            else{
                req.error("Cannot execute the action 'Cancel Participation' on Draft instance of Event (Save the Event and try again)"); 
            }
      
        } catch (error) {
            req.error(error);
        }

     });    
     
     srv.on("confirmParticipation", async req => {
        try {

            const id = (req.params.pop()).ID;
            const eventID = (req.params.pop()).ID;
            //const isActiveEntity = (req.params.pop()).IsActiveEntity;

            let participantData = await SELECT.from("sap.cae.eventmanagement.Participants").where({ ID: id });
            
            // Check if the action is called for inactive (draft) instance / active (saved) instnace 
            //const { Participants } = srv.entities;
            //const tx = srv.transaction(req);//cds.db.transaction(req);
            //let participantData = await tx.read(Participants).where({ ID: id , IsActiveEntity: false  });

            let participantsRes;            
 
            // return error on execution of action on draft instance
            if (participantData.length === 1){

                // reduce the available slots by 1
                const events = await SELECT.from("sap.cae.eventmanagement.Events").where({ ID: eventID });
                const availableFreeSlots = events[0].availableFreeSlots - 1;

                // update the available slots and status of event ( if the available slots is zero then set the event status to blocked)
                const updateEvent = await UPDATE("sap.cae.eventmanagement.Events").set({ availableFreeSlots: availableFreeSlots , 
                                                           statusCode: (availableFreeSlots === 0 ? 2 : events[0].statusCode)})
                                                    .where({ ID: eventID });

                //update cancellation status of participant 
                participantsRes = await 
                UPDATE("sap.cae.eventmanagement.Participants").set({statusCode : 2 }).where({ ID: id });

                participantData = await SELECT.from("sap.cae.eventmanagement.Participants").where({ ID: id });
                          
            

                if (participantsRes !== 1) {
                    req.error("Participation of Participant with ID : '"+participantData[0].identifier+"' confirmation failed , try after some time ");
                }else{
                    req.info("Participation of Participant with ID : '"+participantData[0].identifier+"' confirmed successfully");
                }
                

                //await tx.commit();
                return participantData;
            }
            else{
                req.error("Cannot execute the action 'Confirm Participation' on Draft instance of Event (Save the Event and try again)"); 
            }
      
        } catch (error) {
            req.error(error);
        }

        

     });   

     
    srv.before("PATCH", "Participants", async req => {
        try {
            
            const participantID = req.data.ID;
            if( req.data.email !== 'undefined' && req.data.email ) {
                // Check the validity of email after update of participant
                if ( validateEmail(req.data.email ) === false ) {
                    // invalid email
                    req.error("Invalid Email ID: "+req.data.email, +"please enter valid email ");  
                }else{
                    //update cancellation status of event 
                    const updateEvent = await UPDATE("sap.cae.eventmanagement.Participants").set({email: req.data.email}).where({ ID: participantID });
                }
            }
             if( req.data.mobileNumber !== 'undefined' && req.data.mobileNumber ) {
                // Check the validity of Phone after update of participant
                if ( validatePhone(req.data.mobileNumber ) === false ) {
                    // invalid phone
                    req.error("Invalid Mobile number: "+req.data.mobileNumber, +"please enter valid mobile number ");  
                }else{
                    //update phone
                    const updateEvent = await UPDATE("sap.cae.eventmanagement.Participants").set({email: req.data.mobileNumber}).where({ ID: participantID });
                }
             }
        } catch (error) {
            //req.error(error);
        }
    })
     
    
    /*
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
    */


})
