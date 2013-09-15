Meteor.startup ->
  if Meteor.isClient
    filepicker.setKey 'AOu8DnUQ3Tm6caoisKdpnz'

insertNewVolunteer = (options, callback) ->
  Volunteers.insert { 
    slug: options.firstName + options.lastName,
    photoFilename: options.photoFilename,
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
    notes: options.notes
  }, callback

updateVolunteer = (options, callback) ->
  Volunteers.update _id: options._id, { 
    slug: options.firstName + options.lastName,
    photoFilename: options.photoFilename,
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
    notes: options.notes
  }, callback

Meteor.methods 
  saveVolunteer: (options, callback) ->
    if options._id
      updateVolunteer options, callback
    else
      insertNewVolunteer options, callback
    
  saveTournament: (options, callback) ->
    # Todo: Need to make sure slug is unique
    Tournaments.insert {
      tournamentName: options.tournamentName,
      slug: options.slug,
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
        count: options.count
        shiftId: Meteor.uuid()
        roleId: newShiftDef.roleId
        endTime: newShiftDef.endTime
        startTime: newShiftDef.startTime
        shiftDefId: newShiftDef.shiftDefId
      Tournaments.update options.tournamentId, $push: shifts: newShift



