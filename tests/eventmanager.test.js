const cds = require('@sap/cds')

describe('Events: OData Protocol Level Testing', () => {

    jest.setTimeout(20*1000)
    const app = require('express')()
    const request = require('supertest')(app)

    beforeAll(async () => {
        await cds.deploy(__dirname + '/../srv/eventmanager-service').to('sqlite::memory:')
        await cds.serve('EventManager').from(__dirname + '/../srv/eventmanager-service').in(app)
    })
     
   it('Service $metadata document', async () => { 
     const response = await request 
       .get('/eventmanager/$metadata') 
       .expect('Content-Type', /^application\/xml/) 
       .expect(200) 
 
 
     const expectedVersion = '<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">' 
     const expectedBooksEntitySet = '<EntitySet Name="Events" EntityType="EventManager.Events">' 
     expect(response.text.includes(expectedVersion)).toBeTruthy() 
     expect(response.text.includes(expectedBooksEntitySet)).toBeTruthy() 
   }) 

    
   it('Get with select, expand and localized', async () => { 
     const response = await request 
       .get('/eventmanager/Events?$select=ID,title,description,date,maxParticipantsNumber,participantsFeeAmount,currency') 
       .expect('Content-Type', /^application\/json/) 
       .expect(200) 
 
 
     expect(response.body.value).toEqual([ 
       { 
         ID: "1", title: "SAP Teched", description: "SME Teched @Palma", maxParticipantsNumber: 1000, participantsFeeAmount: 100 , "date": "2020-03-01T00:00:00Z"
       },
       { 
         ID: "2", title: "ByD All Hands", description: "SME All Hands @Bangalore", maxParticipantsNumber: 100, participantsFeeAmount: 200 , "date": "2021-05-01T00:00:00Z"
       }
     ]) 
   }) 
})

describe('Events : CDS Service Level Testing', () => { 
   let srv, Events 
 
 
   beforeAll(async () => { 
     srv = await cds.serve('EventManager').from(__dirname + '/../srv/eventmanager-service') 
     Events = srv.entities.Events 
     expect(Events).toBeDefined() 
   }) 
 
 
   it('GETs all events', async () => { 
     const events = await srv.read(Events, b => { b.title }) 
 
 
     expect(events).toMatchObject([ 
       { title: 'SAP Teched' }, 
       { title: 'ByD All Hands' }
     ]) 
   }) 
})
