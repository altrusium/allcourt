unsetActiveShift = ->
  Session.set 'active-shift', null

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  role = Session.get 'active-role'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam

setActiveDay = ->
  activeDay = $('#day option:selected').val()
  Session.set 'active-day', activeDay

setActiveShift = ->
  tournament = Session.get('active-tournament')
  activeShiftDefId = $('#shift option:selected').val()
  activeDay = moment(Session.get('active-day')).toISOString()
  activeShift = (shift for shift in tournament.shifts when shift.shiftDefId is activeShiftDefId and moment(shift.day).toISOString() is activeDay)[0]
  Session.set 'active-shift', activeShift

getShiftStatus = (confirmed, needed) ->
  status = 'good'
  ratio = confirmed/needed
  if needed is 0 then return
  if ratio < 0.8 then status = 'almost'
  if confirmed is 0 or ratio < 0.5 then status = 'bad'
  status

getSortedShiftDefsForTeam = (tournament, teamId) ->
  timeFormat = 'h:mm a'
  unless teamId then return []
  shiftDefs = for def in tournament.shiftDefs when def.teamId is teamId
    def.startTime = moment(def.startTime).format timeFormat
    def.endTime = moment(def.endTime).format timeFormat
    def
  shiftDefs.sort (def1, def2) ->
    date1 = moment def1.startTime, timeFormat
    date2 = moment def2.startTime, timeFormat
    date1 - date2
  shiftDefs

getSortedShiftsForTeam = (tournament, teamId) ->
  teamShifts = (shift for shift in tournament.shifts when shift.teamId is teamId)
  teamShifts.sort (shift1, shift2) ->
    date1 = new Date(shift1.startTime)
    date2 = new Date(shift2.startTime)
    date1 - date2

getSortedTournamentDays = (tournament) ->
  days = tournament.days.sort (date1, date2) ->
    date1 - date2
  sortedDays = for day in days
    dayInfo = # was dayShifts
      date: moment(day).toISOString()
      dayOfWeek: moment(day).format('ddd')
      dayOfMonth: moment(day).format('Do')

# not used in this file, but will be useful in preferences and setupShifts
augmentDaysWithShifts = (days, shifts) ->
  shiftDays = for day in days
    day.activeShifts = (shift for shift in shifts when moment(shift.day).toISOString() is moment(day.date).toISOString())
    day

augmentDayShiftsWithConfirmedCount = (days, shifts, confirmed) ->
  shiftDays = for day in days
    day.activeShifts = for shift in shifts when moment(shift.day).toISOString() is moment(day.date).toISOString()
      shift.confirmedCount = (c for c in confirmed when shift.shiftId is c.shiftId).length
      shift.status = getShiftStatus shift.confirmedCount, shift.count
      shift
    day

getFullName = (id) ->
  Meteor.users.findOne(id).profile.fullName

getVolunteers = (id, idType) ->
  activeDay = Session.get('active-day')
  tournament = Session.get('active-tournament')
  tId = tournament._id
  activeTeamId = Session.get('active-team').teamId
  schedule = Schedule.find(tournamentId: tId).fetch()
  registrants = Registrants.find(tournamentId: tId).fetch()
  shifts = (shift for shift in tournament.shifts when moment(shift.day).toISOString() is moment(activeDay).toISOString() and shift[idType] is id)
  for shift in shifts 
    confirmed = for user in schedule when user.shiftId is shift.shiftId
      user.fullName = getFullName user.userId
      user
    keen = for user in registrants when _.contains(user.shifts, shift.shiftId)
      user.fullName = getFullName user.userId
      user
    # keep only the ones who have not backed out (those no longer keen)
    shift.confirmed = _.filter confirmed, (reg) ->
      _.contains _.pluck(keen, 'userId'), reg.userId
    # remove the ones who have backed out (those no longer keen)
    shift.backedOut = _.reject confirmed, (reg) ->
      _.contains _.pluck(keen, 'userId'), reg.userId
    # remove duplicates that have already been confirmed (in the schedule)
    shift.keen = _.reject keen, (reg) ->
      _.contains _.pluck(schedule, 'userId'), reg.userId

  shifts.sort (a, b) ->
    moment(a.startTime).toDate() - moment(b.startTime).toDate()

addUserToActiveShift = (userId) ->
  Schedule.insert {
    tournamentId: Session.get('active-tournament')._id,
    shiftId: Session.get('active-shift').shiftId,
    userId: userId
  }

removeUserFromShift = (userId) ->
  schedule = Schedule.findOne(
    tournamentId: Session.get('active-tournament')._id
    shiftId: Session.get('active-shift').shiftId
    userId: userId
  )
  Schedule.remove schedule._id




Template.schedule.created = ->
  for role in Session.get('active-tournament').roles
    if role.roleName is 'Volunteer'
      Session.set 'volunteer-role-id', role.roleId
      return

Template.schedule.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.schedule.activeTeamName = ->
  Session.get('active-team')?.teamName

# Template.schedule.activeShiftName = ->
#   Session.get('active-shift').shiftName

Template.schedule.showingAllDays = ->
  not Session.get('active-day')

Template.schedule.showingOneDay = ->
  Session.get('active-team') and Session.get('active-day') and not Session.get('active-shift')

Template.schedule.showingOneShift = ->
  Session.get('active-team') and Session.get('active-day') and Session.get('active-shift')

Template.schedule.weekDay = ->
  moment(Session.get('active-day')).format('ddd')

Template.schedule.activeDate = ->
  moment(Session.get('active-day')).format('ddd, D MMM')

Template.schedule.activeShiftTimes = ->
  timeFormat = 'h:mm a'
  start = moment(Session.get('active-shift').startTime).format(timeFormat)
  end = moment(Session.get('active-shift').endTime).format(timeFormat)
  '('+start+' - '+end+')'

Template.schedule.teams = ->
  roleId = Session.get 'volunteer-role-id'
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.schedule.markSelectedTeam = ->
  if this.teamName is Session.get('active-team')?.teamName
    return 'selected=selected'

Template.schedule.markSelectedDay = ->
  if this.date is Session.get 'active-day'
    return 'selected=selected'

Template.schedule.markSelectedShift = ->
  if this.shiftDefId is Session.get('active-shift')?.shiftDefId
    return 'selected=selected'

Template.schedule.shifts = ->
  tournament = Session.get 'active-tournament'
  teamId = Session.get('active-team')?.teamId
  confirmed = Schedule.find(tournamentId: tournament._id).fetch()

  shiftDefs = getSortedShiftDefsForTeam tournament, teamId
  shifts = getSortedShiftsForTeam tournament, teamId
  days = getSortedTournamentDays tournament
  shiftDays = augmentDayShiftsWithConfirmedCount days, shifts, confirmed

  result = 
    defs: shiftDefs
    days: shiftDays

Template.schedule.dayVolunteers = ->
  activeTeamId = Session.get('active-team').teamId
  getVolunteers activeTeamId, 'teamId'

Template.schedule.shiftVolunteers = ->
  shiftDefId = Session.get('active-shift').shiftDefId
  getVolunteers shiftDefId, 'shiftDefId'

Template.schedule.events
  'change #team': (evnt, template) ->
    setActiveTeam()

  'change #day': (evnt, template) ->
    setActiveDay()
    if not Session.get('active-day') then unsetActiveShift()

  'change #shift': (evnt, template) ->
    setActiveShift()

  'click .one-shift .action': (evnt, template) ->
    parent = $(evnt.currentTarget).parent()
    userId = parent.data 'user-id'
    action = parent.data 'action'
    if action is 'confirmAdd'
      addUserToActiveShift userId
    else
      removeUserFromShift userId


