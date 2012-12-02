Template.setupTournament.rendered = ->
  $('.tournamentDatepicker').datepicker format: 'dd M yyyy'
  $('#firstDateIcon').click ->
    $('#firstDate').datepicker 'show'
  $('#lastDateIcon').click ->
    $('#lastDate').datepicker 'show'

Template.setupTournament.tournaments = ->
  return Tournaments.find {}, 
    'sort': 'firstDay': 'desc',
    'fields': ['tournamentName': 1, 'lastDay': 1]

Template.setupTournament.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.setupTournament.events 
  'click #saveTournament': (evnt, template) ->
    # unless saveTournamentIsValid template
    #   return
    options = 
      tournamentName: template.find('#tournamentName').value
      firstDay: template.find('#firstDate').value
      lastDay: template.find('#lastDate').value
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






Template.setupShifts.rendered = ->
  $('.timepicker-default').timepicker({'minuteStep': 30})

Template.setupShifts.startDate = ->
  return moment().add('months', 6).toDate()

Template.setupShifts.endDate = ->
  return moment().add('months', 6).add('weeks', 1).toDate()
