setSignupId = ->
  vId = Meteor.userId()
  tId = Session.get('active-tournament').tournamentId
  signup = TournamentVolunteers.findOne { tournamentId: tId, volunteerId: vId }
  Session.set 'signup-id', signup._id

setActiveRole = ->
  id = $('#role option:selected').val()
  name = $('#role option:selected').text()
  Session.set 'active-role-id', id
  Session.set 'active-role-name', name

getRolePreferences = ->
  signupId = Session.get 'signup-id'
  tournament = TournamentVolunteers.findOne { _id: signupId }#, { fields: preferences: 1 }
  tournament.preferences

associateVolunteerWithTournament = ->
  setSignupId()
  signup = Session.get 'signup-id'
  unless signup
    TournamentVolunteers.insert { tournamentId: tId, volunteerId: vId }

saveRolePreferences = (prefs) ->
  signupId = Session.get 'signup-id'
  TournamentVolunteers.update { _id: signupId }, { $set: preferences: prefs}, $upsert: 1

Template.tournamentVolunteerSignup.created = ->
  associateVolunteerWithTournament()

Template.tournamentVolunteerSignup.rendered = ->
  $('#sortableRoles').disableSelection()
  $('#sortableRoles').sortable 
    forcePlaceholderSize: true 
    stop: (evnt, ui) ->
      preferences = $('#sortableRoles').sortable('toArray').slice(0, 4)
      saveRolePreferences preferences

Template.tournamentVolunteerSignup.days = ->
  id = Session.get('active-tournament').tournamentId
  tournament = Tournaments.findOne id, fields: days: 1
  days = tournament.days
  formattedDays = for day in days
    dayOfWeek: moment(day).format 'ddd'
    dayOfMonth: moment(day).format 'do'

Template.tournamentVolunteerSignup.roles = ->
  sortedRoles = []
  rolePrefs = getRolePreferences()
  id = Session.get('active-tournament').tournamentId
  tournament = Tournaments.findOne id, fields: roles: 1
  for role in rolePrefs
    pref = _.find tournament.roles, (item) ->
      if item.roleId is role and !item.found
        item.found = true
        item
    sortedRoles.push pref
  for role in tournament.roles
    unless role.found
      sortedRoles.push role
  sortedRoles

Template.tournamentVolunteerSignup.activeRoleName = ->
  Session.get 'active-role-name'

Template.tournamentVolunteerSignup.markSelectedRole = ->
  if this.roleName is Session.get 'active-role-name'
    return 'selected=selected'

Template.tournamentVolunteerSignup.shifts = ->
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
      activeShifts: (shift for shift in sortedShifts when shift.day.valueOf() is day.valueOf())
  # return the result
  result = 
    defs: shiftDefs
    days: shiftDays

Template.tournamentVolunteerSignup.events
  'change #role': (evnt, template) ->
    setActiveRole()




