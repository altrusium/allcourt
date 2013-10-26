setActiveTeam = ->
  id = $('#team option:selected').val()
  name = $('#team option:selected').text()
  Session.set 'active-team-id', id
  Session.set 'active-team-name', name

setAcceptedShifts = ->
  signupId = Session.get 'signup-id'
  signup = Registrants.findOne { _id: signupId }
  Session.set 'accepted-shifts', signup.shifts

getTeamPreferences = ->
  signupId = Session.get 'signup-id'
  signup = Registrants.findOne { _id: signupId }
  signup and signup.teams or []

associateVolunteerWithTournament = ->
  vId = Meteor.userId()
  tId = Session.get('active-tournament')._id
  signup = Registrants.findOne { tournamentId: tId, volunteerId: vId }
  if signup
    Session.set 'signup-id', signup._id
  else 
    Registrants.insert { tournamentId: tId, volunteerId: vId }, (err, id) ->
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

saveTeamPreferences = (prefs) ->
  signupId = Session.get 'signup-id'
  Registrants.update(
    { _id: signupId }, 
    { $set: teams: prefs}, 
    { $upsert: 1 }, (err) ->
      Template.userMessages.showMessage
        type: 'info'
        title: 'Saved:'
        message: 'The order of your team preferences have been saved.'
        timeout: 2000
  )

getVolunteerRoleId = ->
  tournament = Session.get('active-tournament')
  role = (role for role in tournament.roles when role.roleName is 'Volunteer')
  role[0].roleId

Template.registration.created = ->
  associateVolunteerWithTournament()

Template.registration.rendered = ->
  setActiveTeam()
  $('#sortableTeams').disableSelection()
  $('#sortableTeams').sortable 
    forcePlaceholderSize: true 
    stop: (evnt, ui) ->
      teams = $('#sortableTeams').sortable('toArray').slice(0, 4)
      saveTeamPreferences teams

Template.registration.days = ->
  id = Session.get('active-tournament')._id
  tournament = Tournaments.findOne id, fields: days: 1
  days = tournament.days
  formattedDays = for day in days
    dayOfWeek: moment(day).format 'ddd'
    dayOfMonth: moment(day).format 'do'

Template.registration.teams = ->
  sortedTeams = []
  teamPrefs = getTeamPreferences()
  id = Session.get('active-tournament')._id
  roleId = getVolunteerRoleId()
  tournament = Tournaments.findOne id, fields: teams: 1
  unless tournament.teams then return
  # Get the roleId of the Volunteers role and add that to the conditional below
  for team in teamPrefs # add preferences first
    pref = _.find tournament.teams, (item) ->
      if item.teamId is team and !item.found
        item.found = true
        item
    sortedTeams.push pref
  for team in tournament.teams when team.roleId is roleId # then the rest of them
    unless team.found
      sortedTeams.push team
  sortedTeams

Template.registration.acceptedShift = ->
  if _.contains Session.get('accepted-shifts'), this.shiftId
    return 'checked="checked"'

Template.registration.activeTeamName = ->
  Session.get 'active-team-name'

Template.registration.markSelectedTeam = ->
  if this.teamName is Session.get 'active-team-name'
    return 'selected=selected'

Template.registration.shifts = ->
  # TODO: This needs refactoring
  tId = Session.get('active-tournament')._id
  rId = Session.get 'active-team-id'
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
  shiftDefs = for def in sortedShiftDefs when def.teamId is rId
    def.startTime = moment(def.startTime).format('h:mm a')
    def.endTime = moment(def.endTime).format('h:mm a')
    def
  # getShiftsForTeam
  teamShifts = (shift for shift in tournament.shifts when shift.teamId is rId)
  # sortShifts
  sortedShifts = teamShifts.sort (shift1, shift2) ->
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

Template.registration.events
  'change #team': (evnt, template) ->
    setActiveTeam()
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
      Registrants.update { _id: signupId }, { $push: shifts: id }, (err) ->
        unless err then showSaved 'Added'
    else
      Registrants.update { _id: signupId }, { $pull: shifts: id }, (err) ->
        unless err then showSaved 'Removed'
    setAcceptedShifts()



