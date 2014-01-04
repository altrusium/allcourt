Meteor.methods

  addRegistrant: (details) ->
    registrantId = Registrants.insert details
    teamRegistration = modelHelpers.buildTeamRegistration registrantId
    modelHelpers.upsertTeamRegistration details.userId, teamRegistration
    registrantId

  addTeamToRegistrant: (registrantId, teamId) ->
    existing = Registrants.findOne registrantId
    for team in existing.teams
      if team is teamId then found = team
    if found
      teamRegistration = modelHelpers.buildTeamRegistration registrantId
      modelHelpers.upsertTeamRegistration existing.userId, teamRegistration
      return
    Registrants.update registrantId, $push: teams: teamId

  removeTeamFromRegistrant: (registrantId, teamId) ->
    registrant = Registrants.findOne registrantId
    Registrants.update registrantId, $pull: teams: teamId
    # TODO: If there are no more teams now, delete this registrant document
    modelHelpers.removeTeamRegistration registrant.userId, registrantId

  updateRegistrant: (registrant) ->
    Registrants.update({
      userId: registrant.userId
      tournamentId: registrant.tournamentId
      }, $set: {
      'function': registrant.function
      'accessCode': registrant.accessCode.toUpperCase()
    })
    registrant._id = registrant.userId
    modelHelpers.upsertUserRegistration registrant

  createNewUser: (user) ->
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
    newUserId = Accounts.createUser newUser
    modelHelpers.upsertUserRegistration {
      _id: newUserId
      email: newUser.email
      slug: newUser.profile.slug
      gender: newUser.profile.gender
      fullName: newUser.profile.fullName
      photoFilename: newUser.profile.photoFilename
    }
    newUserId

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

  deleteUser: (userId) ->
    Meteor.users.remove userId
    Volunteers.remove userId
    Registrants.remove userId: userId
    Registrations.remove userId

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
