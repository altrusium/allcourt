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

getActiveTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())

getPreviousTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) < new Date())

setActiveTournament = ->
  id = $('#tournament option:selected').val()
  tournament = Tournaments.findOne id, fields: roles: 1, teams: 1
  Session.set 'active-tournament', tournament

setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament.roles, (role) ->
    if role.roleId is rId then return role
  Session.set 'active-role', activeRole

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  role = Session.get 'active-role'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam





Template.tournaments.created = ->
  Session.set 'active-tournament', null

Template.tournaments.isAdmin = ->
  Meteor.user().profile.admin

Template.tournaments.activeTournaments = ->
  getActiveTournaments()

Template.tournaments.previousTournaments = ->
  getPreviousTournaments()




Template.tournamentDetails.activeTournamentSlug = ->
  return Session.get('active-tournament').slug



Template.createTournament.rendered = ->
  $('.tournamentDatepicker').datepicker format: 'dd M yyyy'
  $('#firstDateIcon').click ->
    $('#firstDate').datepicker 'show'
  $('#lastDateIcon').click ->
    $('#lastDate').datepicker 'show'

Template.createTournament.tournaments = ->
  getSortedTournaments()

Template.createTournament.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.createTournament.events 
  'click #saveTournament': (evnt, template) ->
    firstDay = moment(template.find('#firstDate').value, 'DD MMM YYYY')
    lastDay = moment(template.find('#lastDate').value, 'DD MMM YYYY')
    length = lastDay.diff(firstDay, 'days') 
    options = 
      tournamentName: template.find('#tournamentName').value
      slug: template.find('#tournamentName').value.replace(/\s/g, '')
      firstDay: firstDay.toDate()
      lastDay: lastDay.toDate()
      days: for count in [1..length + 1]
        moment(firstDay).add('days', count).toDate()
    Meteor.call 'saveTournament', options, (err, id) ->
        $('#tournamentName').val ''
  'click [data-action=delete]': (evnt, template) ->
    id = $(evnt.currentTarget).data 'tournament-id'
    Tournaments.remove id




Template.setupRoles.noTournamentsYet = ->
  Tournaments.find().count() is 0

Template.setupRoles.tournaments = ->
  getSortedTournaments()

Template.setupRoles.activeTournaments = ->
  getActiveTournaments()

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
    id = Session.get('active-tournament')._id
    name = template.find('#roleName').value
    newRole = roleId: Meteor.uuid(), roleName: name
    Tournaments.update(id, $push: roles: newRole)
    $('#roleName').val('').focus()

  'click #copyRoles': (evnt, template) ->
    # RoleIDs are only unique within a tournament, NOT across them
    fromId = $('#copyFrom option:selected').val()
    toId = Session.get('active-tournament')._id
    fromRoles = Tournaments.findOne(fromId, fields: roles: 1).roles
    Tournaments.update toId, $set: roles: fromRoles

  'click [data-action=delete]': (evnt, template) ->
    id = Session.get('active-tournament')._id
    roleToDelete = $(evnt.currentTarget).data 'role'
    roles = Session.get('active-tournament').roles
    keepingRoles = (role for role in roles when role.roleId isnt roleToDelete)
    Tournaments.update id, $set: roles: keepingRoles
    teams = Session.get('active-tournament').teams
    keepingTeams = (team for team in teams when team.roleId isnt roleToDelete)
    Tournaments.update id, $set: teams: keepingTeams




Template.setupTeams.rendered = ->
  setActiveRole()

Template.setupTeams.activeTournaments = ->
  getActiveTournaments()

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
    id = Session.get('active-tournament')._id
    teamToDelete = $(evnt.currentTarget).data 'team'
    teams = Session.get('active-tournament').teams
    keepingTeams = (team for team in teams when team.teamId isnt teamToDelete)
    Tournaments.update id, $set: teams: keepingTeams





emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

setSearchableUserList = ->
  users = Meteor.users.find({}).map (user) ->
    usr = id: user._id, fullName: user.profile.firstName + ' ' + user.profile.lastName
  Session.set 'user-list', users
  emptySearchResults()

associateUserWithTournament = (userId) ->
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team').teamId
  signup = Registrants.findOne { tournamentId: tId, userId: userId }
  if signup
    Session.set 'signup-id', signup._id
    Registrants.update signup._id, $push: teams: teamId
  else 
    Registrants.insert { 
      userId: userId, 
      teams: [teamId],
      tournamentId: tId, 
      addedBy: Meteor.userId()
    }, (err, id) ->
      unless err
        Session.set 'signup-id', id
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success:'
          message: 'User has been successfully registered.'
      else
        Template.userMessages.showMessage
          type: 'error'
          title: 'Sign-up Failed:'
          message: 'An error occurred while registering user. Please refresh the browser and let us know if this continues.'

Template.setupRegistrants.created = ->
  setSearchableUserList()

Template.setupRegistrants.rendered = ->
  setActiveRole()
  setActiveTeam()

Template.setupRegistrants.activeTournaments = ->
  getActiveTournaments()

Template.setupRegistrants.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupRegistrants.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')._id
    return 'selected=selected'

Template.setupRegistrants.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected=selected'

Template.setupRegistrants.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.setupRegistrants.roles = ->
  id = Session.get('active-tournament')._id
  unless id then return
  tournament = Tournaments.findOne id, fields: roles: 1 
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.setupRegistrants.registrantsExist = ->
  registrants = Template.setupRegistrants.registrants()
  registrants.length > 0 and not Session.get('search-results')?

Template.setupRegistrants.registrants = ->
  registrants = []
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team')?.teamId
  unless tId and teamId then return []
  Registrants.find({ tournamentId: tId }).forEach (reg) ->
    if _.contains reg.teams, teamId
      registrants.push reg.userId
  users = for id in registrants
    user = Meteor.users.findOne({ _id: id })?.profile
    user.id = id
    user

Template.setupRegistrants.searchResults = ->
  Session.get 'search-results'

Template.setupRegistrants.activeTeamName = ->
  return Session.get('active-team').teamName

Template.setupRegistrants.events
  'change #role': (evnt, template) ->
    setActiveRole()
    setActiveTeam()

  'change #team': (evnt, template) ->
    setActiveTeam()

  'click #addTeam': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    rId = Session.get('active-role').roleId
    name = template.find('#teamName').value
    newTeam = roleId: rId, teamId: Meteor.uuid(), teamName: name
    Tournaments.update(tId, $push: 'teams': newTeam)
    $('#teamName').val('').focus()

  'click [data-action=delete]': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    uId = $(evnt.currentTarget).data 'user'
    reg = Registrants.findOne 'tournamentId': tId, 'userId': uId
    Registrants.update reg._id, $pull: teams: Session.get('active-team').teamId

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    unless query
      emptySearchResults()
      return
    users = Session.get 'user-list'
    searcher = new Fuse users, keys: ['fullName']
    results = searcher.search query
    Session.set 'search-results', results

  'click [data-action=register]': (evnt, template) ->
    userId = $(evnt.currentTarget).data 'id'
    associateUserWithTournament userId
    emptySearchResults()



Template.setupShifts.rendered = ->
  setActiveTournament()
  setActiveRole()
  # This is a terrible hack, but it works until I can figure out
  # why subsequent renders are preventing this control from showing
  $('.timepicker-default').each ->
    $(this).data 'timepicker', null
  $('.bootstrap-timepicker').remove()
  $('.timepicker-default').timepicker minuteStep: 30, showInputs: false
  $('.icon-info-sign').popover()

Template.setupShifts.activeTournamentName = ->
  Session.get('active-tournament').tournamentName

Template.setupShifts.activeRoleName = ->
  Session.get('active-role').roleName

Template.setupShifts.noRolesYet = ->
  id = Session.get('active-tournament')._id
  tournament = Tournaments.findOne id, fields: roles: 1
  tournament && tournament.roles.length is 0

Template.setupShifts.shiftsToShow = ->
  Session.get('active-tournament')._id && Session.get('active-role').roleId

Template.setupShifts.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')._id
    return 'selected=selected'

Template.setupShifts.markSelectedRole = ->
  if this.roleName is Session.get('active-role').roleName
    return 'selected=selected'

Template.setupShifts.tournaments = ->
  getSortedTournaments()

Template.setupShifts.roles = ->
  id = Session.get('active-tournament')._id
  if id
    tournament = Tournaments.findOne(id, fields: roles: 1)
    return tournament && tournament.roles

Template.setupShifts.editingShift = ->
  this.shiftId is Session.get 'editing-shift-id'

Template.setupShifts.zeroClass = ->
  'zero' if this.count is '0'
 
Template.setupShifts.shiftDefs = ->
  tId = Session.get('active-tournament')._id
  rId = Session.get('active-role').roleId
  if tId
    tournament = Tournaments.findOne tId, {fields: {shiftDefs: 1}, sort: {shiftDefs: startTime: 1}}
    shiftDefs = for def in tournament.shiftDefs when def.roleId is rId
      def.startTime = moment(def.startTime).format('h:mm a')
      def.endTime = moment(def.endTime).format('h:mm a')
      def

Template.setupShifts.shifts = ->
  # TODO: This needs refactoring
  tId = Session.get('active-tournament')._id
  rId = Session.get('active-role').roleId
  unless tId
    return
  tournament = Tournaments.findOne tId, {fields: shiftDefs: 1, shifts: 1, days: 1}
  # sortAllShiftDefinitions
  sortedShiftDefs = tournament.shiftDefs.sort (def1, def2) ->
    date1 = new Date(def1.startTime)
    date2 = new Date(def2.startTime)
    if date1 > date2 then return 1
    if date1 < date2 then return -1
    return 0
  # formatShiftDefinitionTimes
  shiftDefs = for def in sortedShiftDefs when def.roleId is rId
    def.startTime = moment(def.startTime).format('h:mm a')
    def.endTime = moment(def.endTime).format('h:mm a')
    def
  # getShiftsForRole
  roleShifts = (shift for shift in tournament.shifts when shift.roleId is rId)
  # sortShifts
  sortedShifts = roleShifts.sort (shift1, shift2) ->
    date1 = new Date(shift1.startTime)
    date2 = new Date(shift2.startTime)
    if date1 > date2 then return 1
    if date1 < date2 then return -1
    return 0
  # sortTournamentDays
  sortedDays = tournament.days.sort (date1, date2) ->
    return date1 - date2
  # getDaysWithShifts
  shiftDays = for day in sortedDays
    dayShifts = 
      dayOfWeek: moment(day).format('ddd')
      dayOfMonth: moment(day).format('Do')
      activeShifts: (shift for shift in sortedShifts when shift.day.valueOf() is day.valueOf())
  # return the result
  result = 
    defs: shiftDefs
    days: shiftDays

Template.setupShifts.events
  'change #tournament': (evnt, template) ->
    setActiveTournament()
  'change #role': (evnt, template) ->
    setActiveRole()
  'click #addShift': (evnt, template) ->
    options = 
      tournamentId: $('#tournament option:selected').val()
      roleId: $('#role option:selected').val()
      startTime: moment($('#setupShiftsStartTime').val(), 'h:m a').toDate()
      endTime: moment($('#setupShiftsEndTime').val(), 'h:m a').toDate()
      shiftName: $('#shiftName').val()
      count: $('#shiftCount').val()
    Meteor.call 'addShift', options
  'click th [data-delete-shiftdef-id]': (evnt, template) ->
    id = Session.get('active-tournament')._id
    shiftDefId = $(evnt.currentTarget).data 'delete-shiftdef-id'
    Tournaments.update id, $pull: shifts: shiftDefId: shiftDefId
    Tournaments.update id, $pull: shiftDefs: shiftDefId: shiftDefId
  'click .shift-count': (evnt, template) ->
    id = $(evnt.currentTarget).closest('[data-shift-id]').data 'shift-id'
    Session.set 'editing-shift-id', id
  'click [data-save-shift-count]': (evnt, template) ->
    id = Session.get('active-tournament')._id
    shiftId = $(evnt.currentTarget).closest('[data-shift-id]').data 'shift-id'
    count = $(evnt.currentTarget).closest('div').find('input').val()
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.count = count
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift
    Session.set 'editing-shift-id', ''
  'click td [data-deactivate-shift-id]': (evnt, template) ->
    id = Session.get('active-tournament').id
    shiftId = $(evnt.currentTarget).data 'deactivate-shift-id'
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = false
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift
  'click td [data-activate-shift-id]': (evnt, template) ->
    id = Session.get('active-tournament')._id
    shiftId = $(evnt.currentTarget).data 'activate-shift-id'
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = true
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift

