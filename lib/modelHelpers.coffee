@modelHelpers =

  getTournamentName: (tournamentId) ->
    tournament = Tournaments.findOne tournamentId, fields: tournamentName: 1
    tournament.tournamentName

  getRoleName: (teamId) ->
    role = null
    tournament = Tournaments.findOne tournamentId, fields: teams: 1, roles: 1
    for team in tournament.teams when team.teamId is teamId
      role = (role for role in tournament.roles when role.roleId is team.roleId)
    role.roleName

  getTeamName: (teamId) ->
    tournament = Tournaments.findOne tournamentId, fields: teams: 1
    team = (team for team in tournament.teams when team.teamId is teamId)
    team.teamName

  buildTeamRegistration: (registrantId) ->
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
      if reg.roleName then existingReg.roleName = reg.roleName
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
