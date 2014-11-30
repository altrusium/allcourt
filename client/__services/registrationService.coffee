@services = @services or {}

services.registrationService =

  saveTeamPreferences: (registrantId, prefs) ->
    registrant = Registrants.findOne registrantId
    registration = Registrations.findOne registrant.userId
    Registrants.update(
      { _id: registrantId },
      { $set: teams: prefs },
      { $upsert: 1 }, (err) ->
        if err
          Template.userMessages.showMessage
            type: 'error'
            title: 'Not saved:'
            message: 'Team preferences were not saved.'
        else
          Meteor.call 'upsertTeamRegistration', registrant.userId, registrantId
          Template.userMessages.showMessage
            type: 'info'
            title: 'Saved:'
            message: 'The order of your team preferences have been saved.'
            timeout: 2000
    )
