Meteor.subscribe 'volunteers'
Meteor.subscribe 'tournaments'
Meteor.subscribe 'tournamentVolunteers'

setActiveTournament = (id) ->
  tournament = Tournaments.findOne id
  unless tournament
    return 'notFound'
  else
    Session.set 'active-tournament', 
      tournamentId: tournament._id, name: tournament.tournamentName
    return 'tournamentDetails'

Meteor.Router.add
  '/': 'home',
  '/volunteers': 'volunteers'
  '/volunteers/create': 'volunteersCreate'
  '/volunteers/list': 'volunteersList'
  '/volunteer/:id': (id) ->
    Session.set 'active-volunteer-id', id
    return 'volunteerDetails'
  '/shifts': 'shifts'
  '/tournaments': 'tournaments'
  '/tournament/create': 'setupTournament'
  '/tournament/roles': 'setupRoles'
  '/tournament/shifts': 'setupShifts'
  '/tournament/:id': (id) ->
    return setActiveTournament(id)
  '/tournament/:id/signup': (id) ->
    return setActiveTournament(id)
  '*': 'notFound'

Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected_tab', tabName 

Session.set 'active-tournament', {tournamentId: '', name: ''}

Session.set 'user-message',
  type: '', title: '', message: ''

tabIsSelected = (tab) ->
  return tab is Session.get 'selected_tab'

Template.tabs.tabSelected = (tab) ->
  return if tabIsSelected tab then 'active' else ''

Template.activeTournament.tournament = ->
  tournament = Session.get 'active-tournament'
  return tournament || tournamentId: '', name: ''

Template.userMessages.message = ->
  msg = Session.get 'user-message'
  return msg || type: '', title: '', message: ''

$('button[data-dismiss]').click ->
  Session.set 'user-message',
    type: '', title: '', message: ''

# For debugging and styling
# Session.set 'user-message',
#   type: 'alert'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'