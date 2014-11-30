@serverMethods =

  addRegistrant: (details) ->
    existing = Registrants.findOne { userId: details.userId, tournamentId: details.tournamentId }
    unless existing
      registrantId = Registrants.insert details
      serverMethods.upsertTeamRegistration details.userId, registrantId
    existing?._id || registrantId

  addTeamToRegistrant: (registrantId, teamId) ->
    existing = Registrants.findOne registrantId
    for team in existing.teams
      if team is teamId then found = team
    if found
      serverMethods.upsertTeamRegistration existing.userId, registrantId
      return
    Registrants.update registrantId, $push: teams: teamId

  removeTeamFromRegistrant: (registrantId, teamId) ->
    registrant = Registrants.findOne registrantId
    Registrants.update registrantId, $pull: teams: teamId
    # TODO: If there are no more teams now, delete this registrant document
    serverMethods.removeTeamRegistration registrant.userId, registrantId

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
    serverMethods.upsertTeamRegistration existing.userId, existing._id

  getRegistration: (id) ->
    Registrations.findOne id

  getRegistrations: (criteria) ->
    Registrations.find(criteria).fetch()

  addRegistration: (user) ->
    unless user._id # if the user just registered
      newUser = Meteor.users.findOne 'profile.email': user.email
      user._id = newUser._id
    user.registrations = []
    Registrations.insert user

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

  getTournament: (tournamentId) ->
    Tournaments.findOne tournamentId, fields: tournamentName:1, slug:1

  getTeamAndRole: (tournamentId, teamId) ->
    theTeam = null
    theRole = null
    tournament = Tournaments.findOne tournamentId, fields: teams: 1, roles: 1
    for team in tournament.teams when team.teamId is teamId
      theRole = (r for r in tournament.roles when r.roleId is team.roleId)[0]
      theTeam = team
    [theTeam, theRole]

  buildTeamRegistration: (registrantId) ->
    reg = {}
    registrant = Registrants.findOne registrantId
    tournamentId = registrant.tournamentId
    tournament = serverMethods.getTournament tournamentId
    teamAndRole = serverMethods.getTeamAndRole tournamentId, registrant.teams[0]
    reg.registrantId = registrantId
    reg.tournamentId = registrant.tournamentId
    reg.tournamentName = tournament.tournamentName
    reg.tournamentSlug = tournament.slug
    reg.teamId = teamAndRole[0].teamId
    reg.teamName = teamAndRole[0].teamName
    reg.roleId = teamAndRole[1].roleId
    reg.roleName = teamAndRole[1].roleName
    reg.function = registrant.function
    reg.accessCode = registrant.accessCode
    reg

  upsertUserRegistration: (user) ->
    existing = Registrations.findOne user._id, fields: _id: 0
    if existing
      if user.slug then existing.slug = user.slug
      if user.email then existing.email = user.email
      if user.gender then existing.gender = user.gender
      if user.fullName then existing.fullName = user.fullName
      if user.photoFilename then existing.photoFilename = user.photoFilename
      Registrations.update user._id, $set: existing
    else
      user.registrations = []
      Registrations.insert user

  removeTeamRegistration: (userId, regId) ->
    Registrations.update userId, $pull: registrations: registrantId: regId

  upsertTeamRegistration: (userId, registrantId) ->
    teamRegistration = serverMethods.buildTeamRegistration registrantId
    reg = teamRegistration
    existing = Registrations.findOne userId
    unless existing then return # couldn't find the registration
    existingReg = _.find existing.registrations, (thisReg) ->
      thisReg.registrantId is reg.registrantId
    if existingReg
      if reg.roleId then existingReg.roleId = reg.roleId
      if reg.roleName then existingReg.roleName = reg.roleName
      if reg.teamId then existingReg.teamId = reg.teamId
      if reg.teamName then existingReg.teamName = reg.teamName
      if reg.function then existingReg.function = reg.function
      if reg.accessCode then existingReg.accessCode = reg.accessCode
      if reg.registrantId then existingReg.registrantId = reg.registrantId
      if reg.tournamentId then existingReg.tournamentId = reg.tournamentId
      if reg.tournamentName then existingReg.tournamentName = reg.tournamentName
      if reg.tournamentSlug then existingReg.tournamentSlug = reg.tournamentSlug
      teamRegistration = existingReg
    else
      existing.registrations.push teamRegistration
    serverMethods.removeTeamRegistration userId, reg.registrantId
    Registrations.update userId, existing

Meteor.methods serverMethods
