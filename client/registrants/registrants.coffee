setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament.roles, (role) ->
    if role.roleId is rId then return role
  Session.set 'active-role', activeRole

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam

setAcceptedShifts = ->
  signupId = Session.get 'signup-id'
  signup = Registrants.findOne { _id: signupId }
  Session.set 'accepted-shifts', signup.shifts

associateUserWithTournament = (userId) ->
  setActiveTeam()
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
        setAcceptedShifts()
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success:'
          message: 'You have successfully registered. Thank you!'
      else
        Template.userMessages.showMessage
          type: 'error'
          title: 'Sign-up Failed:'
          message: 'A registration error occurred. Please refresh your browser and let us know if this continues.'

getTeamPreferences = ->
  signupId = Session.get 'signup-id'
  signup = Registrants.findOne { _id: signupId }
  signup and signup.teams or []

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

createNewVolunteer = (options, callback) ->
  Volunteers.insert { 
    _id: options._id,
    birthdate: options.birthdate || '',
    shirtSize: options.shirtSize || '',
    homePhone: options.homePhone || '',
    mobilePhone: options.mobilePhone || '',
    address: options.address || '',
    city: options.city || '',
    suburb: options.suburb || '',
    postalCode: options.postalCode || '',
    notes: options.notes || ''
  }, callback




Template.register.rendered = ->
  setActiveRole()

Template.register.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.register.roles = ->
  tournament = Session.get 'active-tournament'
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.register.events
  'change #role': (evnt, template) ->
    setActiveRole()
    setActiveTeam()
  'change #team': (evnt, template) ->
    setActiveTeam()
  'click #registerButton': (evnt, template) ->
    userId = Meteor.userId()
    slug = Session.get('active-tournament').slug
    if not $('#agreed').prop('checked')
      window.scrollTo 0, 0
      Template.userMessages.showMessage
        type: 'error'
        title: 'Agree? '
        message: 'To continue, you must agree to the terms by checking the box.'
    else
      associateUserWithTournament userId
      if Session.get('active-team').teamName = 'Volunteer'
        createNewVolunteer _id: userId, (err) ->
          if err
            Template.userMessages.showMessage
              type: 'error'
              title: 'Uh oh! '
              message: 'There was an error creating your volunteer record. Reason: ' + err.reason
      Meteor.Router.to '/tournament/' + slug + '/preferences'
    false




Template.preferences.rendered = ->
  setActiveTeam()
  $('#sortableTeams').disableSelection()
  $('#sortableTeams').sortable 
    forcePlaceholderSize: true 
    stop: (evnt, ui) ->
      teams = $('#sortableTeams').sortable('toArray').slice(0, 4)
      saveTeamPreferences teams

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

Template.preferences.acceptedShift = ->
  if _.contains Session.get('accepted-shifts'), this.shiftId
    return 'checked="checked"'

Template.preferences.activeTeamName = ->
  Session.get('active-team').teamName

Template.preferences.markSelectedTeam = ->
  if this.teamName is Session.get('active-team').teamName
    return 'selected=selected'

Template.preferences.shifts = ->
  # TODO: This needs refactoring
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team').teamId
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
  shiftDefs = for def in sortedShiftDefs when def.teamId is teamId
    def.startTime = moment(def.startTime).format('h:mm a')
    def.endTime = moment(def.endTime).format('h:mm a')
    def
  # getShiftsForTeam
  teamShifts = (shift for shift in tournament.shifts when shift.teamId is teamId)
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

Template.preferences.events
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



Template.schedule.activeTournamentSlug = ->
  Session.get('active-tournament').slug

