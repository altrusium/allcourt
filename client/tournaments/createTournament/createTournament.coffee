getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list




Template.createTournament.rendered = ->
  $('.tournamentDatepicker').datepicker format: 'dd M yyyy'
  $('#firstDateIcon').click ->
    $('#firstDate').datepicker 'show'
  $('#lastDateIcon').click ->
    $('#lastDate').datepicker 'show'

Template.createTournament.tournaments = ->
  getSortedTournaments()

Template.createTournament.tournamentsExist = ->
  return Tournaments.find().count() > 0

Template.createTournament.events
  'click #saveTournament': (evnt, template) ->
    firstDay = moment(template.find('#firstDate').value, 'DD MMM YYYY')
    lastDay = moment(template.find('#lastDate').value, 'DD MMM YYYY')
    length = lastDay.diff(firstDay, 'days')
    options =
      tournamentName: template.find('#tournamentName').value
      slug: template.find('#tournamentName').value.replace(/\s/g, '')
      firstDay: firstDay.toDate()
      lastDay: lastDay.toDate()
      days: for count in [0..length]
        moment(firstDay).add('days', count).toDate()
    Meteor.call 'saveTournament', options, (err, id) ->
      $('#tournamentName').val ''
  'click [data-action=delete]': (evnt, template) ->
    id = $(evnt.currentTarget).data 'tournament-id'
    Tournaments.remove id

