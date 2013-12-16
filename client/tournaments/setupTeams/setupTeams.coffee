getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list

getMyTournaments = ->
  results = []
  myId = Meteor.userId()
  myTournamentIds = Registrants.find({ 'userId': myId }, fields: 'tournamentId': 1).fetch()
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

setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament.roles, (role) ->
    if role.roleId is rId then return role
  Session.set 'active-role', activeRole




Template.setupTeams.rendered = ->
  setActiveRole()

Template.setupTeams.activeTournaments = ->
  getActiveTournaments()

Template.setupTeams.isAdmin = ->
  allcourt.isAdmin()

Template.setupTeams.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.setupTeams.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupTeams.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')._id
    return 'selected=selected'

Template.setupTeams.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected=selected'

Template.setupTeams.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.setupTeams.teamsExist = ->
  teams = Template.setupTeams.teams()
  teams.length > 0

Template.setupTeams.roles = ->
  id = Session.get('active-tournament')._id
  unless id then return
  tournament = Tournaments.findOne id, fields: roles: 1 
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.setupTeams.activeRoleName = ->
  return Session.get('active-role').roleName

Template.setupTeams.events
  'change #role': (evnt, template) ->
    setActiveRole()

  'click #addTeam': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    rId = Session.get('active-role').roleId
    name = template.find('#teamName').value
    newTeam = roleId: rId, teamId: Meteor.uuid(), teamName: name
    Tournaments.update(tId, $push: 'teams': newTeam)
    $('#teamName').val('').focus()

  'click [data-action=delete]': (evnt, template) ->
    Session.set 'deleting-team', $(evnt.currentTarget).data 'team'
    $('#deleteModal').modal()

  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get('active-tournament')._id
    teamToDelete = Session.get 'deleting-team'
    teams = Session.get('active-tournament').teams
    keepingTeams = (team for team in teams when team.teamId isnt teamToDelete)
    Tournaments.update id, $set: teams: keepingTeams

  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()
    
