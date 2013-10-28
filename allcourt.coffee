Meteor.methods 

  createNewUser: (options) ->
    newUser = 
      email: options.email
      profile:
        email: options.email
        firstName: options.firstName
        lastName: options.lastName
        fullName: options.firstName + ' ' + options.lastName
        photoFilename: options.photoFilename
        gender: options.gender || 'female'
        slug: options.firstName + options.lastName
    Accounts.createUser newUser

  updateUser: (options) ->
    firstName = options.firstName
    lastName = options.lastName
    Meteor.users.update options._id, $set: profile: {
      email: options.email,
      firstName: firstName,
      lastName: lastName,
      fullName: firstName + ' ' + lastName,
      photoFilename: options.photoFilename,
      gender: options.gender || 'female',
      slug: options.firstName + options.lastName,
      }

  createNewVolunteer: (options) ->
    Volunteers.insert { 
      _id: options._id,
      birthdate: options.birthdate || '',
      shirtSize: options.shirtSize || '',
      homePhone: options.homePhone || '',
      mobilePhone: options.mobilePhone || '',
      address: options.address || '',
      city: options.city || '',
      suburb: options.suburb || '',
      postalCode: options.postalCode || '',
      notes: options.notes || ''
    }

  updateVolunteer: (options) ->
    Volunteers.update _id: options._id, { 
      birthdate: options.birthdate,
      shirtSize: options.shirtSize,
      homePhone: options.homePhone,
      mobilePhone: options.mobilePhone,
      address: options.address,
      city: options.city,
      suburb: options.suburb,
      postalCode: options.postalCode,
      notes: options.notes
    }

  saveTournament: (options) ->
    # Todo: Need to make sure slug is unique (bug #1)
    newId = Meteor.uuid()
    Tournaments.insert {
      tournamentName: options.tournamentName,
      slug: options.slug,
      days: options.days,
      roles: [ roleId: newId, roleName: 'Volunteer'],
      teams: [ teamId: newId, roleId: newId, teamName: 'Default Volunteer Team'],
      shifts: [],
      shiftDefs: []
    }

  addShift: (options) ->
    tournament = Tournaments.findOne options.tournamentId
    newShiftDef = 
      shiftDefId: Meteor.uuid()
      teamId: options.teamId
      shiftName: options.shiftName
      startTime: options.startTime
      endTime: options.endTime
    Tournaments.update options.tournamentId, $push: shiftDefs: newShiftDef
    for day in tournament.days
      newShift = 
        day: day
        count: options.count
        shiftId: Meteor.uuid()
        teamId: newShiftDef.teamId
        endTime: newShiftDef.endTime
        startTime: newShiftDef.startTime
        shiftDefId: newShiftDef.shiftDefId
      Tournaments.update options.tournamentId, $push: shifts: newShift



