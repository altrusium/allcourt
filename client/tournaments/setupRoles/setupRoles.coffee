getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    date2 - date1
  return list

getMyTournaments = ->
  results = []
  myId = Meteor.userId()
  myTournamentIds = Registrants.find({ 'userId': myId },
    fields: 'tournamentId': 1).fetch()
  getSortedTournaments().forEach (tournament) ->
    myTournamentIds.forEach (my) ->
      if my.tournamentId is tournament._id
        results.push tournament
  results

getActiveTournaments = ->
  mine = getMyTournaments()
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())
  result = _.reject result, (tournament) ->
    _.find mine, (myT) ->
      myT._id is tournament._id

getPreviousTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) < new Date())




Template.setupRoles.noTournamentsYet = ->
  Tournaments.find().count() is 0

Template.setupRoles.tournaments = ->
  getSortedTournaments()

Template.setupRoles.activeTournaments = ->
  getActiveTournaments()

Template.setupRoles.isAdmin = ->
  allcourt.isAdmin()

Template.setupRoles.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.setupRoles.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupRoles.previousTournaments = ->
  getPreviousTournaments()

Template.setupRoles.copyableTournaments = ->
  id = Session.get('active-tournament')._id
  list = getSortedTournaments()
  result = (t for t in list when t._id isnt id)

Template.setupRoles.markSelected = ->
  if this._id is Session.get('active-tournament')._id
    return 'selected=selected'

Template.setupRoles.rolesExist = ->
  id = Session.get('active-tournament')._id
  unless id
    return false
  tournament = Tournaments.findOne id, fields: roles: 1
  return Object.keys(tournament.roles).length > 0

Template.setupRoles.roles = ->
  id = Session.get('active-tournament')._id
  unless id then return
  tournament = Tournaments.findOne id, fields: roles: 1
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.setupRoles.activeTournamentName = ->
  return Session.get('active-tournament').tournamentName

Template.setupRoles.events
  'click #addRole': (evnt, template) ->
    newId = Meteor.uuid()
    id = Session.get('active-tournament')._id
    name = template.find('#roleName').value
    newRole = roleId: newId, roleName: name
    defaultTeam = roleId: newId, teamId: newId, teamName: 'Default ' + name +
      ' Team'
    Tournaments.update(id, $push: roles: newRole)
    Tournaments.update(id, $push: teams: defaultTeam)
    $('#roleName').val('').focus()

  'click #copyRoles': (evnt, template) ->
    # RoleIDs are only unique within a tournament, NOT across them
    fromId = $('#copyFrom option:selected').val()
    toId = Session.get('active-tournament')._id
    fromRoles = Tournaments.findOne(fromId, fields: roles: 1).roles
    fromTeams = Tournaments.findOne(fromId, fields: teams: 1).teams
    Tournaments.update toId, $set: roles: fromRoles
    Tournaments.update toId, $set: teams: fromTeams

  'click [data-action=delete]': (evnt, template) ->
    Session.set 'deleting-role', $(evnt.currentTarget).data 'role'
    $('#deleteModal').modal()

  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get('active-tournament')._id
    roleToDelete = Session.get 'deleting-role'
    roles = Session.get('active-tournament').roles
    keepingRoles = (role for role in roles when role.roleId isnt roleToDelete)
    Tournaments.update id, $set: roles: keepingRoles
    teams = Session.get('active-tournament').teams
    keepingTeams = (team for team in teams when team.roleId isnt roleToDelete)
    Tournaments.update id, $set: teams: keepingTeams

  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()

