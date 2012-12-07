Template.setupTournament.rendered = ->
  $('.tournamentDatepicker').datepicker format: 'dd M yyyy'
  $('#firstDateIcon').click ->
    $('#firstDate').datepicker 'show'
  $('#lastDateIcon').click ->
    $('#lastDate').datepicker 'show'

Template.setupTournament.tournaments = ->
  return Tournaments.find {}, 
    'sort': 'firstDay': -1,
    'fields': ['tournamentName': 1, 'lastDay': 1]

Template.setupTournament.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.setupTournament.events 
  'click #saveTournament': (evnt, template) ->
    firstDay = moment(template.find('#firstDate').value, 'DD MMM YYYY')
    lastDay = moment(template.find('#lastDate').value, 'DD MMM YYYY')
    length = lastDay.diff(firstDay, 'days') 
    options = 
      tournamentName: template.find('#tournamentName').value
      firstDay: firstDay.toDate()
      lastDay: lastDay.toDate()
      days: for count in [1..length + 1]
        moment(firstDay).add('days', count).toDate()
    Meteor.call 'saveTournament', options, (err, id) ->
        $('#tournamentName').val ''
  'click [data-action=delete]': (evnt, template) ->
    id = $(evnt.currentTarget).data 'tournament-id'
    Tournaments.remove id




Template.setupRoles.setActiveTournament = ->
    id = $('#tournament option:selected').val()
    name = $('#tournament option:selected').text()
    Session.set 'active-tournament-id', id
    Session.set 'active-tournament-name', name

Template.setupRoles.noTournamentsYet = ->
  Tournaments.find().count() == 0

Template.setupRoles.tournaments = ->
  Tournaments.find {},
    sort: firstDay: -1
    fields: tournamentName: 1

Template.setupRoles.copyableTournaments = ->
  Tournaments.find _id: $ne: Session.get 'active-tournament-id'

Template.setupRoles.markSelected = ->
  if this._id is Session.get 'active-tournament-id'
    return 'selected=selected'

Template.setupRoles.rolesExist = ->
  id = Session.get 'active-tournament-id'
  unless id
    return false
  tournament = Tournaments.findOne id, fields: roles: 1
  return Object.keys(tournament.roles).length > 0

Template.setupRoles.roles = ->
  id = Session.get 'active-tournament-id'
  unless id
    return
  tournament = Tournaments.findOne id, fields: roles: 1
  return tournament.roles

Template.setupRoles.activeTournamentName = ->
  return Session.get 'active-tournament-name'

Template.setupRoles.events
  'change #tournament': (evnt, template) ->
    Template.setupRoles.setActiveTournament()

  'click #addRole': (evnt, template) ->
    id = Session.get 'active-tournament-id'
    name = template.find('#roleName').value
    newRole = roleId: Meteor.uuid(), roleName: name
    Tournaments.update(id, $push: roles: newRole)
    $('#roleName').val('').focus()

  'click #copyRoles': (evnt, template) ->
    # RoleIDs are only unique within a tournament, NOT across them
    fromId = $('#copyFrom option:selected').val()
    toId = Session.get 'active-tournament-id'
    fromRoles = Tournaments.findOne(fromId, fields: roles: 1).roles
    Tournaments.update toId, $set: roles: fromRoles

  'click [data-action=delete]': (evnt, template) ->
    keepingRoles = []
    id = Session.get 'active-tournament-id'
    roleToDelete = $(evnt.currentTarget).data 'role'
    roles = Template.setupRoles.roles()
    keepingRoles = (role for role in roles when role.roleName isnt roleToDelete)
    Tournaments.update id, $set: roles: keepingRoles

Template.setupRoles.rendered = ->
  Template.setupRoles.setActiveTournament()




Template.setupShifts.setActiveTournament = ->
    id = $('#tournament option:selected').val()
    name = $('#tournament option:selected').text()
    Session.set 'active-tournament-id', id
    Session.set 'active-tournament-name', name

Template.setupShifts.activeTournamentName = ->
  return Session.get 'active-tournament-name'

Template.setupShifts.setActiveRole = ->
    id = $('#role option:selected').val()
    name = $('#role option:selected').text()
    Session.set 'active-role-id', id
    Session.set 'active-role-name', name

Template.setupShifts.activeRoleName = ->
  return Session.get 'active-role-name'

Template.setupShifts.markSelectedTournament = ->
  if this._id is Session.get 'active-tournament-id'
    return 'selected=selected'

Template.setupShifts.markSelectedRole = ->
  if this.roleName is Session.get 'active-role-name'
    return 'selected=selected'

Template.setupShifts.tournaments = ->
  Tournaments.find {},
    sort: firstDay: -1
    fields: tournamentName: 1

Template.setupShifts.roles = ->
  id = Session.get 'active-tournament-id'
  if id
    tournament = Tournaments.findOne(id, fields: roles: 1)
    return tournament && tournament.roles
 
Template.setupShifts.shiftDefs = ->
  tId = Session.get 'active-tournament-id'
  rId = Session.get 'active-role-id'
  if tId
    tournament = Tournaments.findOne tId, fields: shiftDefs: 1
    shiftDefs = for def in tournament.shiftDefs when def.roleId is rId
      def.startTime = moment(def.startTime).format('h:mm a')
      def.endTime = moment(def.endTime).format('h:mm a')
      def

Template.setupShifts.shifts = ->
  tId = Session.get 'active-tournament-id'
  rId = Session.get 'active-role-id'
  if tId
    tournament = Tournaments.findOne(tId, {fields: shifts: 1, days: 1})
    shiftData = for day in tournament.days
      dayShifts = 
        dayOfWeek: moment(day).format('ddd')
        dayOfMonth: moment(day).format('Do')
        activeShifts: (shift for shift in tournament.shifts when shift.day is day)

Template.setupShifts.events
  'change #tournament': (evnt, template) ->
    Template.setupShifts.setActiveTournament()
  'change #role': (evnt, template) ->
    Template.setupShifts.setActiveRole()
  'click #addShift': (evnt, template) ->
    options = 
      tournamentId: $('#tournament option:selected').val()
      roleId: $('#role option:selected').val()
      startTime: moment($('#setupShiftsStartTime').val(), 'h:m a').toDate()
      endTime: moment($('#setupShiftsEndTime').val(), 'h:m a').toDate()
      shiftName: $('#shiftName').val()
    Meteor.call 'addShift', options
  # 'click [data-delete-shiftdef-id]': (evnt, template) ->
  'click [data-delete-shift-id]': (evnt, template) ->
    id = Session.get 'active-tournament-id'
    target = $(evnt.currentTarget)
    shiftId = target.data 'delete-shift-id'
    date = target.data 'date'
    newShift = 
      day: date
      active: false
      shiftId: shiftId 
    Tournaments.update id, $pull: shifts: shiftId: shiftId, day: date
    Tournaments.update id, $push: shifts: newShift

Template.setupShifts.rendered = ->
  Template.setupShifts.setActiveTournament()
  Template.setupShifts.setActiveRole()
  # This is a terrible hack, but it works until I can figure out
  # why subsequent renders are preventing this control from showing
  $('.timepicker-default').each ->
    $(this).data 'timepicker', null
  $('.bootstrap-timepicker').remove()
  $('.timepicker-default').timepicker minuteStep: 30, showInputs: false
