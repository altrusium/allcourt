# This file basically keeps the Registrations collection in sync
# with the other collections. Called by methods in allcourt.coffee.

@modelHelpers =

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
    tournament = modelHelpers.getTournament tournamentId
    teamAndRole = modelHelpers.getTeamAndRole tournamentId, registrant.teams[0]
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

  upsertTeamRegistration: (userId, reg) ->
    teamRegistration = reg
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
    modelHelpers.removeTeamRegistration userId, reg.registrantId
    Registrations.update userId, existing

