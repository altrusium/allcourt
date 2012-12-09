Volunteers = new Meteor.Collection 'volunteers'
Tournaments = new Meteor.Collection 'tournaments'

Meteor.startup ->
  if Meteor.isClient
    filepicker.setKey 'AOu8DnUQ3Tm6caoisKdpnz'

Meteor.methods {
  saveVolunteer: (options) ->
    return Volunteers.insert {
      photoFilename: options.photoFilename
      firstName: options.firstName,
      lastName: options.lastName,
      birthdate: options.birthdate,
      gender: options.gender,
      shirtSize: options.shirtSize,
      primaryEmail: options.primaryEmail,
      secondaryEmail: options.secondaryEmail,
      homePhone: options.homePhone,
      workPhone: options.workPhone,
      mobilePhone: options.mobilePhone,
      address: options.address,
      city: options.city,
      suburb: options.suburb,
      postalCode: options.postalCode,
      notes: options.notes,
    }
  saveTournament: (options, callback) ->
    return Tournaments.insert {
      tournamentName: options.tournamentName,
      days: options.days,
      roles: [],
      shifts: [],
      shiftDefs: []
    }, callback
  addShift: (options, callback) ->
    tournament = Tournaments.findOne options.tournamentId
    newShiftDef = 
      shiftDefId: Meteor.uuid()
      roleId: options.roleId
      shiftName: options.shiftName
      startTime: options.startTime
      endTime: options.endTime
    Tournaments.update options.tournamentId, $push: shiftDefs: newShiftDef
    for day in tournament.days
      newShift = 
        day: day
        active: true
        shiftId: Meteor.uuid()
        roleId: newShiftDef.roleId
        endTime: newShiftDef.endTime
        startTime: newShiftDef.startTime
        shiftDefId: newShiftDef.shiftDefId
      Tournaments.update options.tournamentId, $push: shifts: newShift
}