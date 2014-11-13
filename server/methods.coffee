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
    existing = Registrants.findOne
      userId: registrant.userId
      tournamentId: registrant.tournamentId
    isApproved = if registrant.isApproved is undefined then existing.isApproved else registrant.isApproved
    isTeamLead = if registrant.isTeamLead is undefined then existing.isTeamLead else registrant.isTeamLead
    isUserProxy = if registrant.isUserProxy is undefined then existing.isUserProxy else registrant.isUserProxy
    update =
      'function': registrant.function || ''
      'accessCode': registrant.accessCode?.toUpperCase() || ''
      'isApproved': isApproved
      'isTeamLead': isTeamLead
      'isUserProxy': isUserProxy
    Registrants.update existing._id, $set: update
    teamRegistration = modelHelpers.buildTeamRegistration existing._id
    modelHelpers.upsertTeamRegistration existing.userId, teamRegistration

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
        addedBy: user.addedBy || 'self'
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
    if user.admin
      Roles.addUsersToRoles newUserId, ['admin']
    if user.proxy
      Roles.addUsersToRoles newUserId, ['proxy']
    newUserId

  updateUser: (user) ->
    firstName = user.firstName
    lastName = user.lastName
    gender = user.gender || 'female'
    fullName = firstName + ' ' + lastName
    slug = firstName.replace(/\s/g,'') + lastName.replace(/\s/g,'')
    Meteor.users.update user._id, $set: profile: {
      email: user.email.toLowerCase()
      firstName: firstName
      lastName: lastName
      fullName: fullName
      photoFilename: user.photoFilename
      gender: gender
      addedBy: user.addedBy
      slug: slug
      isNew: user.isNew
    }
    modelHelpers.upsertUserRegistration {
      _id: user._id
      slug: slug
      email: user.email
      gender: gender
      fullName: fullName
      photoFilename: user.photoFilename
    }
    if user.admin
      Roles.addUsersToRoles user._id, ['admin']
    else
      Roles.removeUsersFromRoles user._id, ['admin']

    if user.proxy
      Roles.addUsersToRoles user._id, ['proxy']
    else
      Roles.removeUsersFromRoles user._id, ['proxy']
    false

  deleteUser: (userId) ->
    Meteor.users.remove userId
    Volunteers.remove userId
    Registrants.remove userId: userId
    Registrations.remove userId

  createNewVolunteer: (volunteer) ->
    # Rewrite this with more coffee flavour
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
      tennisClub: volunteer.tennisClub || '',
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
      tennisClub: volunteer.tennisClub,
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

  unregisterUserFromTournament: (userId, tournamentId) =>
    registrant = Registrants.findOne userId: userId, tournamentId: tournamentId
    if registrant
      Registrants.remove _id: registrant._id
      Registrations.update userId, $pull: registrations: registrantId: registrant._id
    else
      throw 'Registrant not found for this tournament'

  sendVerificationEmail: (userId) ->
    Accounts.sendVerificationEmail userId

  sendEmail: (options) ->
    this.unblock()
    Email.send options
