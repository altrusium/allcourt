getTournamentName = (tournamentId) ->
  tournament = Tournaments.findOne tournamentId, fields: tournamentName: 1
  tournament.tournamentName

getRoleName = (teamId) ->
  role = null
  tournament = Tournaments.findOne tournamentId, fields: teams: 1, roles: 1
  for team in tournament.teams when team.teamId is teamId
    role = (role for role in tournament.roles when role.roleId is team.roleId)
  role.roleName

getTeamName = (teamId) ->
  tournament = Tournaments.findOne tournamentId, fields: teams: 1
  team = (team for team in tournament.teams when team.teamId is teamId)
  team.teamName

buildTeamRegistration = (registrantId) ->
  registration = {}
  registrant = Registrants.findOne registrantId
  registration.registrantId = registrantId
  registration.tournamentId = registrant.tournamentId
  registration.tournamentName = getTournamentName registrant.tournamentId
  registration.teamName = getTeamName registrant.teams[0]
  registration.roleName = getRoleName registrant.teams[0]
  registration.function = registrant.function
  registration.accessCode = registrant.accessCode
  registration

Meteor.methods =

  upsertUserRegistration: (user) ->
    theUser = user
    selector = {}
    existing = Registrations.findOne _id:user.userId
    if existing
      selector._id = existing._id
      if user.email then existing.email = user.email
      if user.gender then existing.gender = user.gender
      if user.fullName then existing.fullName = user.fullName
      if user.photoFilename then existing.photoFilename = user.photoFilename
      theUser = existing
    result = Registrations.upsert selector, theUser

  upsertTeamRegistration: (userId, reg) ->
    teamRegistration = reg
    existing = Registrations.findOne userId
    unless existing then return
    existingReg = _.find existing.registrations, (thisReg) ->
      thisReg.registrantId is reg.registrantId
    if existingReg
      if reg.roleName then existingReg.roleName = reg.roleName
      if reg.teamName then existingReg.teamName = reg.teamName
      if reg.function then existingReg.function = reg.function
      if reg.accessCode then existingReg.accessCode = reg.accessCode
      if reg.registrantId then existingReg.registrantId = reg.registrantId
      if reg.tournamentId then existingReg.tournamentId = reg.tournamentId
      if reg.tournamentName then existingReg.tournamentName = reg.tournamentName
      teamRegistration = existingReg
    Meteor.call 'removeTeamRegistration', userId, reg.registrantId
    existing.registrations.push teamRegistration
    Registrations.update userId, existing

  removeTeamRegistration: (userId, regId) ->
    Registrations.update userId, $pull: registrations: registrantId: regId

  addTeamToRegistrant: (registrantId, teamId) ->
    existing = Registrants.findOne _id: registrantId
    for team in existing.teams
      if team.teamId is teamId then found = team
    if found then return
    Registrants.update registrantId, $push: teams: teamId
    teamRegistration = buildTeamRegistration registrantId
    Meteor.call 'upsertTeamRegistration', existing.userId, teamRegistration

  updateRegistrant: (registrant) ->
    Registrants.update({
      userId: registrant.userId
      tournamentId: registrant.tournamentId
      }, $set: {
      'function': registrant.function
      'accessCode': registrant.accessCode.toUpperCase()
    })
    Meteor.call 'upsertUserRegistration', registrant

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
    Meteor.call 'createRegistration',
      _id: newUserId
      email: newUser.email
      gender: newUser.profile.gender
      fullName: newUser.profile.fullName
      photoFilename: newUser.profile.photoFilename

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
    Meteor.call 'createRegistration',
      _id: user._id
      email: user.email
      gender: user.gender
      fullName: user.fullName
      photoFilename: user.photoFilename

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
