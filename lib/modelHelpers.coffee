@modelHelpers =

  getTournamentName: (tournamentId) ->
    tournament = Tournaments.findOne tournamentId, fields: tournamentName: 1
    tournament.tournamentName

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
    teamAndRole = modelHelpers.getTeamAndRole tournamentId, registrant.teams[0]
    reg.registrantId = registrantId
    reg.tournamentId = registrant.tournamentId
    reg.tournamentName = modelHelpers.getTournamentName tournamentId
    reg.teamId = teamAndRole[0].teamId
    reg.teamName = teamAndRole[0].teamName
    reg.roleId = teamAndRole[1].roleId
    reg.roleName = teamAndRole[1].roleName
    reg.function = registrant.function
    reg.accessCode = registrant.accessCode
    reg

  upsertUserRegistration: (id, user) ->
    existing = Registrations.findOne id, fields: _id: 0
    if id and existing
      if user.slug then existing.slug = user.slug
      if user.email then existing.email = user.email
      if user.gender then existing.gender = user.gender
      if user.fullName then existing.fullName = user.fullName
      if user.photoFilename then existing.photoFilename = user.photoFilename
      Registrations.update id, $set: existing
    else
      user._id = id
      user.registrations = []
      Registrations.insert user

  removeTeamRegistration: (userId, regId) ->
    Registrations.update userId, $pull: registrations: registrantId: regId

  upsertTeamRegistration: (userId, reg) ->
    teamRegistration = reg
    existing = Registrations.findOne userId
    unless existing then return
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
      teamRegistration = existingReg
    modelHelpers.removeTeamRegistration userId, reg.registrantId
    existing.registrations.push teamRegistration
    Registrations.update userId, existing

