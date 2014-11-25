Meteor.methods

  addRegistrant: (details) ->
    existing = Registrants.findOne {userId: details.userId, tournamentId: details.tournamentId}
    unless existing
      registrantId = Registrants.insert details
      # console.log 'id: ' + registrantId
      teamRegistration = modelHelpers.buildTeamRegistration registrantId
      modelHelpers.upsertTeamRegistration details.userId, teamRegistration
    existing?._id || registrantId

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
