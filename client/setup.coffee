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
    # unless saveTournamentIsValid template
    #   return
    options = 
      tournamentName: template.find('#tournamentName').value
      firstDay: moment(template.find('#firstDate').value, 'DD MMM YYYY').toDate()
      lastDay: moment(template.find('#lastDate').value, 'DD MMM YYYY').toDate()
    Meteor.call 'saveTournament', options, (err, id) ->
      unless err
        # show sucess alert
        $('#tournamentName').val ''
      else
        # show error alert
  'click [data-action=delete]': (evnt, template) ->
    id = $(evnt.currentTarget).data 'tournament-id'
    console.log "id is " + id
    Tournaments.remove id

# savetournamentisvalid = (tmp) ->
#   firstdate = moment(tmp.find('#firstdate').value, 'dd/mm/yyy')
#   lastdate = moment(tmp.find('#lastdate').value, 'dd/mm/yyy')
#   template.setuptournament.valid.firstday = firstdate && firstdate.isvalid()
#   template.setuptournament.valid.lastday = lastdate && lastdate.isvalid()
#   # template.setuptournament.valid.dateorder = !(firstdate && firstdate.isvalid())
#   return false




Template.setupRoles.noTournamentsYet = ->
  Tournaments.find().count() == 0

Template.setupRoles.tournaments = ->
  Tournaments.find {},
    sort: firstDay: -1
    fields: tournamentName: 1

Template.setupRoles.copyableTournaments = ->
  Tournaments.find _id: $ne: Session.get 'active-tournament-id'

Template.setupRoles.activeTournament = ->
  if Template.setupRoles.noTournamentsYet()
    return
  active = Session.get 'active-tournament'
  unless active
    recent = Tournaments.findOne {}, sort: firstDay: -1
    active = id: recent._id, name: recent.tournamentName
    Session.set 'active-tournament', active
  return active

Template.setupRoles.markSelected = ->
  if this._id is Session.get 'active-tournament-id'
    return 'selected="selected"'

Template.setupRoles.rolesExist = ->
  id = Session.get 'active-tournament-id'
  unless id
    return false
  tournament = Tournaments.findOne id, fields: tournamentName: 1
  return tournament.roles.length > 0

Template.setupRoles.roles = ->
  id = Session.get 'active-tournament-id'
  unless id
    return
  tournament = Tournaments.findOne id, fields: tournamentName: 1
  return tournament.roles

Template.setupRoles.activeTournamentName = ->
  return Session.get 'active-tournament-name'

Template.setupRoles.setActiveTournament = ->
    id = $('#tournament option:selected').val()
    name = $('#tournament option:selected').text()
    Session.set 'active-tournament-id', id
    Session.set 'active-tournament-name', name

Template.setupRoles.events
  'change #tournament': (evnt, template) ->
    Template.setupRoles.setActiveTournament()

  'click #addRole': (evnt, template) ->
    id = Session.get 'active-tournament-id'
    role = template.find('#roleName').value
    Tournaments.update(id, $push: roles: role)

  'click #copyRoles': (evnt, template) ->
    fromId = $('#copyFrom option:selected').val()
    toId = Session.get 'active-tournament-id'
    fromRoles = Tournaments.findOne(fromId, fields: roles: 1).roles
    Tournaments.update toId, $set: roles: fromRoles

  'click [data-action=delete]': (evnt, template) ->
    newRoles = []
    id = Session.get 'active-tournament-id'
    roleToDelete = $(evnt.currentTarget).data 'role'
    roles = Template.setupRoles.roles()
    roles.forEach (role) ->
      unless role is roleToDelete
        newRoles.push role
    Tournaments.update id, $set: roles: newRoles

Template.setupRoles.rendered = ->
  Template.setupRoles.setActiveTournament()




Template.setupShifts.rendered = ->
  $('.timepicker-default').timepicker({'minuteStep': 30})

Template.setupShifts.startDate = ->
  return moment().add('months', 6).toDate()

Template.setupShifts.endDate = ->
  return moment().add('months', 6).add('weeks', 1).toDate()
