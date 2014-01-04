setUserIdsWithTeam = (teamId) ->
  tournamentId = Session.get('active-tournament')?._id
  # showBusyIndicator()
  Meteor.subscribe 'user-list-with-team', teamId, tournamentId, ->
    # hideBusyIndicator()

setUserIdsWithRole = (roleId) ->
  tournamentId = Session.get('active-tournament')?._id
  # showBusyIndicator()
  Meteor.subscribe 'user-list-with-role', roleId, tournamentId, ->
    # hideBusyIndicator()

resetCategoryFilters = ->
  Session.set 'active-team', null
  Session.set 'active-role', null
  Session.set 'active-tournament', null

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

setActiveTournament = (id) ->
  tournament = Tournaments.findOne _id: id
  Session.set 'active-tournament', tournament

setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament?.roles, (role) ->
    role.roleId is rId
  Session.set 'active-role', activeRole

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  role = Session.get 'active-role'
  activeTeam = _.find tournament?.teams, (team) ->
    team.teamId is tId
  Session.set 'active-team', activeTeam

sendUserSearchQuery = (query) ->
  submitUserSearch query, (results) ->
    for user in results
      user.isMale = user.gender is 'male'
    Session.set 'search-results', results




Template.users.rendered = ->
  Session.set 'active-volunteer', null

Template.users.destroyed = ->
  emptySearchResults()

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
  if Session.get('search-results') then return Session.get('search-results')
  if Session.get 'active-team'
    setUserIdsWithTeam Session.get('active-team').teamId
  else if Session.get 'active-role'
    setUserIdsWithRole Session.get('active-role').roleId
  Registrations.find {}

Template.users.totalCount = ->
  Registrations.find({}).count()



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
      setActiveRole()

  'change #team': (evnt, template) ->
    emptySearchResults()
    if $('option:selected', evnt.currentTarget).val() is 'allteams'
      Session.set 'active-team', null
    else
      setActiveTeam()

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    if query
      resetCategoryFilters()
      sendUserSearchQuery query
    else
      emptySearchResults()
    false

