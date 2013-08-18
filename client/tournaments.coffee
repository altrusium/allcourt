getSortedTournamentList = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list




Template.tournamentDetails.tournamentId = ->
  return Session.get('active-tournament').tournamentId




Template.setupTournament.rendered = ->
  $('.tournamentDatepicker').datepicker format: 'dd M yyyy'
  $('#firstDateIcon').click ->
    $('#firstDate').datepicker 'show'
  $('#lastDateIcon').click ->
    $('#lastDate').datepicker 'show'

Template.setupTournament.tournaments = ->
  getSortedTournamentList()

Template.setupTournament.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.setupTournament.events 
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
    # Todo: Need to make sure slug is unique
    console.log options.slug
    Meteor.call 'saveTournament', options, (err, id) ->
        $('#tournamentName').val ''
  'click [data-action=delete]': (evnt, template) ->
    id = $(evnt.currentTarget).data 'tournament-id'
    Tournaments.remove id




Template.tournamentList.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.tournamentList.tournaments = ->
  getSortedTournamentList()




Template.setupRoles.setActiveTournament = ->
    id = $('#tournament option:selected').val()
    name = $('#tournament option:selected').text()
    Session.set 'active-tournament', {tournamentId: id, name: name}

Template.setupRoles.noTournamentsYet = ->
  Tournaments.find().count() is 0

Template.setupRoles.tournaments = ->
  getSortedTournamentList()

Template.setupRoles.copyableTournaments = ->
  Tournaments.find _id: $ne: Session.get('active-tournament').tournamentId

Template.setupRoles.markSelected = ->
  if this._id is Session.get('active-tournament').tournamentId
    return 'selected=selected'

Template.setupRoles.rolesExist = ->
  id = Session.get('active-tournament').tournamentId
  unless id
    return false
  tournament = Tournaments.findOne id, fields: roles: 1
  return Object.keys(tournament.roles).length > 0

Template.setupRoles.roles = ->
  id = Session.get('active-tournament').tournamentId
  getRoles id

Template.setupRoles.activeTournamentName = ->
  return Session.get('active-tournament').name

Template.setupRoles.events
  'change #tournament': (evnt, template) ->
    Template.setupRoles.setActiveTournament()

  'click #addRole': (evnt, template) ->
    id = Session.get('active-tournament').tournamentId
    name = template.find('#roleName').value
    newRole = roleId: Meteor.uuid(), roleName: name
    Tournaments.update(id, $push: roles: newRole)
    $('#roleName').val('').focus()

  'click #copyRoles': (evnt, template) ->
    # RoleIDs are only unique within a tournament, NOT across them
    fromId = $('#copyFrom option:selected').val()
    toId = Session.get('active-tournament').tournamentId
    fromRoles = Tournaments.findOne(fromId, fields: roles: 1).roles
    Tournaments.update toId, $set: roles: fromRoles

  'click [data-action=delete]': (evnt, template) ->
    keepingRoles = []
    id = Session.get('active-tournament').tournamentId
    roleToDelete = $(evnt.currentTarget).data 'role'
    roles = Template.setupRoles.roles()
    keepingRoles = (role for role in roles when role.roleName isnt roleToDelete)
    Tournaments.update id, $set: roles: keepingRoles

Template.setupRoles.rendered = ->
  Template.setupRoles.setActiveTournament()




Template.setupShifts.setActiveTournament = ->
    id = $('#tournament option:selected').val()
    name = $('#tournament option:selected').text()
    Session.set 'active-tournament', {tournamentId: id, name: name}

Template.setupShifts.activeTournamentName = ->
  return Session.get('active-tournament').name

Template.setupShifts.setActiveRole = ->
    id = $('#role option:selected').val()
    name = $('#role option:selected').text()
    Session.set 'active-role-id', id
    Session.set 'active-role-name', name

Template.setupShifts.activeRoleName = ->
  return Session.get 'active-role-name'

Template.setupShifts.noRolesYet = ->
  id = Session.get('active-tournament').tournamentId
  tournament = Tournaments.findOne id, fields: roles: 1
  return tournament && tournament.roles.length is 0

Template.setupShifts.shiftsToShow = ->
  return Session.get('active-tournament').tournamentId && Session.get('active-role-id')

Template.setupShifts.markSelectedTournament = ->
  if this._id is Session.get('active-tournament').tournamentId
    return 'selected=selected'

Template.setupShifts.markSelectedRole = ->
  if this.roleName is Session.get 'active-role-name'
    return 'selected=selected'

Template.setupShifts.tournaments = ->
  getSortedTournamentList()

Template.setupShifts.roles = ->
  id = Session.get('active-tournament').tournamentId
  if id
    tournament = Tournaments.findOne(id, fields: roles: 1)
    return tournament && tournament.roles

Template.setupShifts.editingShift = ->
  return this.shiftId is Session.get 'editing-shift-id'

Template.setupShifts.zeroClass = ->
  return 'zero' if this.count is '0'
 
Template.setupShifts.shiftDefs = ->
  tId = Session.get('active-tournament').tournamentId
  rId = Session.get 'active-role-id'
  if tId
    tournament = Tournaments.findOne tId, {fields: {shiftDefs: 1}, sort: {shiftDefs: startTime: 1}}
    shiftDefs = for def in tournament.shiftDefs when def.roleId is rId
      def.startTime = moment(def.startTime).format('h:mm a')
      def.endTime = moment(def.endTime).format('h:mm a')
      def

Template.setupShifts.shifts = ->
  # TODO: This needs refactoring
  tId = Session.get('active-tournament').tournamentId
  rId = Session.get 'active-role-id'
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
      activeShifts: (shift for shift in sortedShifts when shift.day is day)
  # return the result
  result = 
    defs: shiftDefs
    days: shiftDays

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
      count: $('#shiftCount').val()
    Meteor.call 'addShift', options
  'click th [data-delete-shiftdef-id]': (evnt, template) ->
    id = Session.get('active-tournament').tournamentId
    shiftDefId = $(evnt.currentTarget).data 'delete-shiftdef-id'
    Tournaments.update id, $pull: shifts: shiftDefId: shiftDefId
    Tournaments.update id, $pull: shiftDefs: shiftDefId: shiftDefId
  'click .shift-count': (evnt, template) ->
    id = $(evnt.currentTarget).closest('[data-shift-id]').data 'shift-id'
    Session.set 'editing-shift-id', id
  'click [data-save-shift-count]': (evnt, template) ->
    id = Session.get('active-tournament').tournamentId
    shiftId = $(evnt.currentTarget).closest('[data-shift-id]').data 'shift-id'
    count = $(evnt.currentTarget).closest('div').find('input').val()
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.count = count
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift
    Session.set 'editing-shift-id', ''
  'click td [data-deactivate-shift-id]': (evnt, template) ->
    id = Session.get('active-tournament').tournamentId
    shiftId = $(evnt.currentTarget).data 'deactivate-shift-id'
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = false
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift
  'click td [data-activate-shift-id]': (evnt, template) ->
    id = Session.get('active-tournament').tournamentId
    shiftId = $(evnt.currentTarget).data 'activate-shift-id'
    tournament = Tournaments.findOne id, fields: shifts: 1
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = true
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift

Template.setupShifts.rendered = ->
  Template.setupShifts.setActiveTournament()
  Template.setupShifts.setActiveRole()
  # This is a terrible hack, but it works until I can figure out
  # why subsequent renders are preventing this control from showing
  $('.timepicker-default').each ->
    $(this).data 'timepicker', null
  $('.bootstrap-timepicker').remove()
  $('.timepicker-default').timepicker minuteStep: 30, showInputs: false
  $('.icon-info-sign').popover()
