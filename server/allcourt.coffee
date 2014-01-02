Meteor.methods =

  addTeamToRegistrant: (registrantId, teamId) ->
    existing = Registrants.findOne _id: registrantId
    for team in existing.teams
      if team.teamId is teamId then found = team
    if found then return
    Registrants.update registrantId, $push: teams: teamId
    teamRegistration = modelHelpers.buildTeamRegistration registrantId
    modelHelpers.upsertTeamRegistration existing.userId, teamRegistration

  updateRegistrant: (registrant) ->
    Registrants.update({
      userId: registrant.userId
      tournamentId: registrant.tournamentId
      }, $set: {
      'function': registrant.function
      'accessCode': registrant.accessCode.toUpperCase()
    })
    modelHelpers.upsertUserRegistration registrant

  createNewUser: (user) ->
    console.log 'creating new user'
    newUser =
      email: user.email
      profile:
        email: user.email.toLowerCase()
        firstName: user.firstName
        lastName: user.lastName
        fullName: user.firstName + ' ' + user.lastName
        photoFilename: user.photoFilename
        gender: user.gender || 'female'
        slug: user.firstName + user.lastName
        admin: user.admin
        isNew: user.isNew
    console.log 'creating new registration'
    modelHelpers.upsertUserRegistration {
      _id: newUserId
      email: newUser.email
      slug: newUser.profile.slug
      gender: newUser.profile.gender
      fullName: newUser.profile.fullName
      photoFilename: newUser.profile.photoFilename
    }
    newUserId = Accounts.createUser newUser

  updateUser: (user) ->
    firstName = user.firstName
    lastName = user.lastName
    Meteor.users.update user._id, $set: profile: {
      email: user.email.toLowerCase(),
      firstName: firstName,
      lastName: lastName,
      fullName: firstName + ' ' + lastName,
      photoFilename: user.photoFilename,
      gender: user.gender || 'female',
      slug: firstName.replace(/\s/g,'') + lastName.replace(/\s/g,''),
      admin: user.admin,
      isNew: user.isNew
    }
    modelHelpers.upsertUserRegistration {
      _id: user._id
      slug: user.slug
      email: user.email
      gender: user.gender
      fullName: user.fullName
      photoFilename: user.photoFilename
    }
    false

  createNewVolunteer: (volunteer) ->
    Volunteers.insert {
      _id: volunteer._id,
      birthdate: volunteer.birthdate || '',
      shirtSize: volunteer.shirtSize?.toUpperCase() || '',
      homePhone: volunteer.homePhone || '',
      mobilePhone: volunteer.mobilePhone || '',
      address: volunteer.address || '',
      city: volunteer.city || '',
      suburb: volunteer.suburb || '',
      postalCode: volunteer.postalCode || '',
      notes: volunteer.notes || ''
    }

  updateVolunteer: (volunteer) ->
    Volunteers.update _id: volunteer._id, {
      birthdate: volunteer.birthdate,
      shirtSize: volunteer.shirtSize?.toUpperCase(),
      homePhone: volunteer.homePhone,
      mobilePhone: volunteer.mobilePhone,
      address: volunteer.address,
      city: volunteer.city,
      suburb: volunteer.suburb,
      postalCode: volunteer.postalCode,
      notes: volunteer.notes
    }

  saveTournament: (tournament) ->
    # Todo: Need to make sure slug is unique (bug #1)
    newId = Meteor.uuid()
    Tournaments.insert {
      tournamentName: tournament.tournamentName,
      slug: tournament.slug,
      days: tournament.days,
      roles: [ roleId: newId, roleName: 'Volunteer'],
      teams: [ teamId: newId, roleId: newId,
        teamName: 'Default Volunteer Team'],
      shifts: [],
      shiftDefs: []
    }

  addShift: (shift) ->
    tournament = Tournaments.findOne shift.tournamentId
    newShiftDef =
      shiftDefId: Meteor.uuid()
      teamId: shift.teamId
      shiftName: shift.shiftName
      startTime: shift.startTime
      endTime: shift.endTime
    Tournaments.update shift.tournamentId, $push: shiftDefs: newShiftDef
    for day in tournament.days
      newShift =
        day: day
        count: shift.count
        shiftId: Meteor.uuid()
        teamId: newShiftDef.teamId
        endTime: newShiftDef.endTime
        startTime: newShiftDef.startTime
        shiftDefId: newShiftDef.shiftDefId
      Tournaments.update shift.tournamentId, $push: shifts: newShift

  sendVerificationEmail: (userId) ->
    Accounts.sendVerificationEmail userId

  sendEmail: (options) ->
    this.unblock()
    Email.send options
