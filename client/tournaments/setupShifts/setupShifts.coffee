setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  role = Session.get 'active-role'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam

isAdmin = ->
  Meteor.user().profile.admin




Template.setupShifts.created = ->
  for role in Session.get('active-tournament').roles
    if role.roleName is 'Volunteer'
      Session.set 'volunteer-role-id', role.roleId
      return

Template.setupShifts.rendered = ->
  setActiveTeam()
  # This is a terrible hack, but it works until I can figure out
  # why subsequent renders are preventing this control from showing
  $('.timepicker-default').each ->
    $(this).data 'timepicker', null
  $('.bootstrap-timepicker').remove()
  $('.timepicker-default').timepicker minuteStep: 30, showInputs: false
  $('.icon-info-sign').popover()

Template.setupShifts.isAdmin = ->
  isAdmin()

Template.setupShifts.activeTeamName = ->
  Session.get('active-team')?.teamName

Template.setupShifts.markSelectedTeam = ->
  if this.teamName is Session.get('active-team')?.teamName
    return 'selected=selected'

Template.setupShifts.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupShifts.teams = ->
  teams = []
  tournament = Session.get 'active-tournament'
  for team in tournament.teams
    if team.roleId is Session.get 'volunteer-role-id'
      teams.push team
  teams

Template.setupShifts.editingShift = ->
  this.shiftId is Session.get 'editing-shift-id'

Template.setupShifts.zeroClass = ->
  'zero' if this.count is '0'

Template.setupShifts.shiftDefs = ->
  # tId = Session.get('active-tournament')._id
  # teamId = Session.get('active-team').teamId
  # if tId and teamId
  #   tournament = Tournaments.findOne tId, {fields: {shiftDefs: 1}, sort: {shiftDefs: startTime: 1}}
  #   shiftDefs = for def in tournament.shiftDefs when def.teamId is teamId
  #     def.startTime = moment(def.startTime).format('h:mm a')
  #     def.endTime = moment(def.endTime).format('h:mm a')
  #     def
  tournament = Session.get 'active-tournament'
  teamId = Session.get('active-team')?.teamId
  shiftDefs = for def in tournament.shiftDefs when def.teamId is teamId
    def.startTime = moment(def.startTime).format('h:mm a')
    def.endTime = moment(def.endTime).format('h:mm a')
    def

# This function is identical to Template.preferences.shifts
Template.setupShifts.shifts = ->
  # TODO: This could use some refactoring
  timeFormat = 'h:mm a'
  tournament = Session.get 'active-tournament'
  teamId = Session.get('active-team')?.teamId
  # Get shifts for team
  shiftDefs = for def in tournament.shiftDefs when def.teamId is teamId
    def.startTime = moment(def.startTime).format timeFormat
    def.endTime = moment(def.endTime).format timeFormat
    def
  # Sort shift definitions
  shiftDefs.sort (def1, def2) ->
    date1 = moment def1.startTime, timeFormat
    date2 = moment def2.startTime, timeFormat
    date1 - date2
  # sort shifts
  teamShifts = (shift for shift in tournament.shifts when shift.teamId is teamId)
  sortedShifts = teamShifts.sort (shift1, shift2) ->
    date1 = new Date(shift1.startTime)
    date2 = new Date(shift2.startTime)
    date1 - date2
  # sort tournament days
  sortedDays = tournament.days.sort (date1, date2) ->
    return date1 - date2
  # get days with shifts
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
  'change #team': (evnt, template) ->
    setActiveTeam()

  'click #addShift': (evnt, template) ->
    options = 
      tournamentId: Session.get('active-tournament')._id
      teamId: $('#team option:selected').val()
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
    tournament = Session.get('active-tournament')
    id = tournament._id
    shiftId = $(evnt.currentTarget).closest('[data-shift-id]').data 'shift-id'
    count = $(evnt.currentTarget).closest('div').find('input').val()
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.count = count
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift
    Session.set 'editing-shift-id', ''

  'click td [data-deactivate-shift-id]': (evnt, template) ->
    tournament = Session.get('active-tournament')
    id = tournament._id
    shiftId = $(evnt.currentTarget).data 'deactivate-shift-id'
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = false
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift

  'click td [data-activate-shift-id]': (evnt, template) ->
    tournament = Session.get('active-tournament')
    id = tournament._id
    shiftId = $(evnt.currentTarget).data 'activate-shift-id'
    targetShift = (shift for shift in tournament.shifts when shift.shiftId is shiftId)[0]
    targetShift.active = true
    Tournaments.update id, $pull: shifts: shiftId: shiftId
    Tournaments.update id, $push: shifts: targetShift

