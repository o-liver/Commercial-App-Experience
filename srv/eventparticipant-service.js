const cds = require('@sap/cds')


/** Service implementation for Event Management service */

module.exports = cds.service.impl(srv => {

    srv.after('CREATE', 'Participants', each => _initialiseStatus(each))
    
    /** Function to initialize the available free slots in an event along with status  */ 
    function _initialiseStatus (each) { 
        //set the status of event to be inProcess
        each.statusCode = 1
    } 

            /* dont allow completed Participants to be deleted */
    srv.on("DELETE", "Participants", async (req, next) => {
         const { Participants } = srv.entities;
         const tx = srv.transaction(req);
         const result = await tx.read(Participants).columns("statusCode").where({ ID: req.data.ID,
                                                              IsActiveEntity: true });
        //TODO: check the correct status codes (lifeCycle at Operation level?)
        if (result[0].statusCode === 2 || result[0].statusCode === 3) {
            //TODO: how to send localized error messages?
            req.reject(409, "Deletion is rejected : Cannot delete confirmed / cancelled participation");
            return req;
        } else {
            //Call default implementation for 'on'
            return await next();
        }
    });

    

})
