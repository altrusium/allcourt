getUserIdsOnTeam = (teamId) ->
  users = []
  roleId = Session.get('active-role').roleId
  tournamentId = Session.get('active-tournament')._id
  for user in Session.get('user-list')
    for tournament in user.tournaments when tournament.id is tournamentId
      if tournament.role?.team?.id is teamId then users.push user
  users

getUserIdsWithRole = (roleId) ->
  users = []
  tournamentId = Session.get('active-tournament')._id
  for user in Session.get('user-list')
    for tournament in user.tournaments when tournament.id is tournamentId
      if tournament.role?.id is roleId then users.push user
  users

getUserIdsAtTournament = (tournamentId) ->
  unless Session.get 'user-list' then setSearchableUserList()
  users = []
  for user in Session.get('user-list')
    for tournament in user.tournaments when tournament.id is tournamentId
      users.push user
  users

sortUsers = (users) ->
  sortedUsers = []
  if users.length
    sortedUsers = _.sortBy users, (user) ->
      user?.fullName
  sortedUsers

getUserAccessCode = (userId) ->
  # TODO: get access code from the registrants collection
  return 'ABC'

getTournamentRegistrations = (userId) ->
  registrants = Registrants.find userId: userId
  registrants.map (reg) ->
    t = Tournaments.findOne { _id: reg.tournamentId }, { fields: days: 0, shifts: 0, shiftDefs: 0 }
    tourney = id: t._id, name: t.tournamentName
    teamsRoleId = (teamObj.roleId for teamObj in t.teams when teamObj.teamId is reg.teams[0])[0]
    roleObj = for r in t.roles when r.roleId is teamsRoleId
      id: r.roleId, name: r.roleName 
    tourney.role = roleObj[0]
    teamObj = for tTeam in t.teams when tTeam.teamId is reg.teams[0]
      id: tTeam.teamId, name: tTeam.teamName
    if tourney.role then tourney.role.team = teamObj[0]
    tourney

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

setSearchableUserList = ->
  users = Meteor.users.find({}).map (user) ->
    usr = 
      id: user._id
      slug: user.profile.slug
      email: user.profile.email
      isNew: user.profile.isNew
      fullName: user.profile.fullName
      accessCode: getUserAccessCode user._id
      photoFilename: user.profile.photoFilename
      tournaments: getTournamentRegistrations user._id
  Session.set 'user-list', sortUsers users
  emptySearchResults()

setActiveTournament = (id) ->
  tournament = Tournaments.findOne _id: id
  Session.set 'active-tournament', tournament

setActiveRole = (forceChange) ->
  activeRole = Session.get('active-role')
  if forceChange or not activeRole
    rId = $('#role option:selected').val()
    tournament = Session.get 'active-tournament'
    activeRole = _.find tournament?.roles, (role) ->
      if role.roleId is rId then return role
    Session.set 'active-role', activeRole

setActiveTeam = (forceChange) ->
  activeTeam = Session.get('active-team')
  if forceChange or not activeTeam
    tId = $('#team option:selected').val()
    tournament = Session.get 'active-tournament'
    role = Session.get 'active-role'
    activeTeam = _.find tournament?.teams, (team) ->
      if team.teamId is tId then return team
    Session.set 'active-team', activeTeam

Template.users.rendered = ->
  Session.set 'active-volunteer', null

Template.users.tournaments = ->
  allcourt.getSortedTournaments()

Template.users.roles = ->
  tournament = Session.get 'active-tournament'
  unless tournament then return []
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.users.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  unless tournament then return []
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.users.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')?._id
    return 'selected=selected'

Template.users.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected=selected'

Template.users.markSelectedTeam = ->
  if this.teamId is Session.get('active-team')?.teamId
    return 'selected=selected'

Template.users.photoRoot = ->
  return allcourt.photoRoot

Template.users.users = ->
  if Session.get 'active-team'
    Session.set 'search-results', getUserIdsOnTeam Session.get('active-team').teamId
  else if Session.get 'active-role'
    Session.set 'search-results', getUserIdsWithRole Session.get('active-role').roleId
  else if Session.get 'active-tournament'
    Session.set 'search-results', getUserIdsAtTournament Session.get('active-tournament')._id
  Session.get 'search-results'

Template.users.totalCount = ->
  Session.get('search-results')?.length



Template.users.events

  'change #tournament': (evnt, template) ->
    id = $('option:selected', evnt.currentTarget).val()
    emptySearchResults()
    Session.set 'active-team', null
    Session.set 'active-role', null
    if id is 'alltournaments'
      Session.set 'active-tournament', null
    else
      setActiveTournament id

  'change #role': (evnt, template) ->
    emptySearchResults()
    Session.set 'active-team', null
    if $('option:selected', evnt.currentTarget).val() is 'allroles'
      Session.set 'active-role', null
    else
      forceChange = true
      setActiveRole forceChange

  'change #team': (evnt, template) ->
    emptySearchResults()
    if $('option:selected', evnt.currentTarget).val() is 'allteams'
      Session.set 'active-team', null
    else
      forceChange = true
      setActiveTeam forceChange

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    unless query
      emptySearchResults()
      return
    Session.set 'active-team', null
    Session.set 'active-role', null
    Session.set 'active-tournament', null
    unless Session.get 'user-list' then setSearchableUserList()
    users = Session.get 'user-list'
    searcher = new Fuse users, keys: ['fullName']
    results = searcher.search query
    Session.set 'search-results', results

