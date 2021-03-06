setActiveRegistrant = ->
  userId = Meteor.userId()
  tId = Session.get('active-tournament')._id
  reg = -> null until registrantsSubscription.ready()
  reg = Registrants.findOne { userId: userId, tournamentId: tId }
  Session.set 'active-registrant', reg

setAcceptedShifts = ->
  signupId = Session.get 'reg-id'
  signup = -> null until registrantsSubscription.ready()
  signup = Registrants.findOne { _id: signupId }
  Session.set 'accepted-shifts', signup.shifts

getRegistrant = ->
  tId = Session.get('active-tournament')._id
  uId = Meteor.userId()
  reg = Registrants.findOne tournamentId: tId, userId: uId

getVolunteerRoleId = ->
  tournament = Session.get('active-tournament')
  role = (role for role in tournament.roles when role.roleName is 'Volunteer')
  role[0].roleId

setActiveTeam = ->
  teamId = $('#sortableTeams').sortable('toArray')[0]
  tournament = Session.get 'active-tournament'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is teamId then return team
  Session.set 'active-team', activeTeam

getTeamPreferences = ->
  registrant = Session.get 'active-registrant'
  registrant and registrant.teams or []




Template.preferences.created = ->
  setActiveRegistrant()

Template.preferences.rendered = ->
  $('#sortableTeams').disableSelection()
  $('#sortableTeams').sortable
    forcePlaceholderSize: true
    stop: (evnt, ui) ->
      registrantId = Session.get('active-registrant')._id
      teams = $('#sortableTeams').sortable('toArray').slice(0, 4)
      services.registrationService.saveTeamPreferences registrantId, teams
      setActiveTeam()
  setActiveTeam()

Template.preferences.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.preferences.isTeamLead = ->
  reg = getRegistrant()
  reg.isTeamLead

Template.preferences.isUserProxy = ->
  reg = getRegistrant()
  reg.isUserProxy

Template.preferences.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.preferences.days = ->
  id = Session.get('active-tournament')._id
  tournament = Tournaments.findOne id, fields: days: 1
  days = tournament.days
  formattedDays = for day in days
    dayOfWeek: moment(day).format 'ddd'
    dayOfMonth: moment(day).format 'do'

Template.preferences.teams = ->
  sortedTeams = []
  teamPrefs = getTeamPreferences()
  tournament = Session.get 'active-tournament'
  roleId = getVolunteerRoleId()
  # Get the roleId of the Volunteers role and add that to the conditional below
  for myTeam in teamPrefs # add preferences first
    pref = _.find tournament.teams, (team) ->
      if team.teamId is myTeam and not team.found
        team.found = true
        team
    sortedTeams.push pref
  for team in tournament.teams when team.roleId is roleId #then the rest of them
    unless team.found
      sortedTeams.push team
  sortedTeams

Template.preferences.acceptedShift = ->
  _.contains Session.get('active-registrant').shifts, this.shiftId

Template.preferences.activeTeamName = ->
  Session.get('active-team')?.teamName

Template.preferences.hasTarget = (count) ->
  count isnt '0'

# This function is identical to Template.setupShifts.shifts
Template.preferences.shifts = ->
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
  teamShifts = (s for s in tournament.shifts when s.teamId is teamId)
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
      activeShifts: (shift for shift in sortedShifts \
        when shift.day.valueOf() is day.valueOf())
  # return the result
  result =
    defs: shiftDefs
    days: shiftDays

Template.preferences.events

  'change #shiftTable [data-shift]': (evnt, template) ->
    input = $(evnt.currentTarget)
    id = input.data 'shift-id'
    checked = input.is ':checked'
    signupId = Session.get('active-registrant')._id
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

  'click #continueButton': (evnt, template) ->
    Router.go 'profileEdit'
