setActiveRole = ->
  id = $('#role option:selected').val()
  name = $('#role option:selected').text()
  Session.set 'active-role-id', id
  Session.set 'active-role-name', name

setAcceptedShifts = ->
  signupId = Session.get 'signup-id'
  signup = TournamentVolunteers.findOne { _id: signupId }
  Session.set 'accepted-shifts', signup.shifts

getRolePreferences = ->
  signupId = Session.get 'signup-id'
  signup = TournamentVolunteers.findOne { _id: signupId }
  signup and signup.preferences or []

associateVolunteerWithTournament = ->
  vId = Meteor.userId()
  tId = Session.get('active-tournament').tournamentId
  signup = TournamentVolunteers.findOne { tournamentId: tId, volunteerId: vId }
  if signup
    Session.set 'signup-id', signup._id
  else 
    TournamentVolunteers.insert { tournamentId: tId, volunteerId: vId }, (err, id) ->
      unless err
        console.log 'new id is ' + id
        Session.set 'signup-id', id
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success:'
          message: 'You have been successfully signed up. Thank you!'
      else
        Template.userMessages.showMessage
          type: 'error'
          title: 'Sign-up Failed:'
          message: 'An error occurred while signing you up. Please refresh your browser and let us know if this continues.'

saveRolePreferences = (prefs) ->
  signupId = Session.get 'signup-id'
  TournamentVolunteers.update(
    { _id: signupId }, 
    { $set: preferences: prefs}, 
    { $upsert: 1 }, (err) ->
      Template.userMessages.showMessage
        type: 'info'
        title: 'Saved:'
        message: 'The order of your role preferences have been saved.'
        timeout: 2000
  )

Template.tournamentVolunteerSignup.created = ->
  associateVolunteerWithTournament()

Template.tournamentVolunteerSignup.rendered = ->
  setActiveRole()
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
  unless tournament.roles then return
  for role in rolePrefs # add preferences first
    pref = _.find tournament.roles, (item) ->
      if item.roleId is role and !item.found
        item.found = true
        item
    sortedRoles.push pref
  for role in tournament.roles # then the rest of them
    unless role.found
      sortedRoles.push role
  sortedRoles

Template.tournamentVolunteerSignup.acceptedShift = ->
  if _.contains Session.get('accepted-shifts'), this.shiftId
    return 'checked="checked"'

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
  'change #shiftTable [data-shift]': (evnt, template) ->
    input = $(evnt.currentTarget)
    id = input.data 'shift-id'
    checked = input.is ':checked'
    signupId = Session.get 'signup-id'
    showSaved = (action) ->
      Template.userMessages.showMessage
        type: 'info'
        title: action + ':'
        message: 'Your shift schedule has been saved.'
        timeout: 2000
    if checked
      TournamentVolunteers.update { _id: signupId }, { $push: shifts: id }, (err) ->
        unless err then showSaved 'Added'
    else
      TournamentVolunteers.update { _id: signupId }, { $pull: shifts: id }, (err) ->
        unless err then showSaved 'Removed'
    setAcceptedShifts()


