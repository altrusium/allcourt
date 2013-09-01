Meteor.subscribe 'volunteers'
Meteor.subscribe 'tournaments'
Meteor.subscribe 'tournamentVolunteers'

setActiveTournament = (slug) ->
  tournament = Tournaments.findOne slug: slug
  unless tournament
    return 'notFound'
  else
    Session.set 'active-tournament', 
      tournamentId: tournament._id, 
      name: tournament.tournamentName,
      slug: tournament.slug
    return false

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
  '/tournament/list': 'tournamentList'
  '/tournament/roles': 'setupRoles'
  '/tournament/shifts': 'setupShifts'
  '/tournament/:slug': (slug) ->
    return setActiveTournament(slug) || 'tournamentDetails'
  '/tournament/:id/signup': (id) ->
    return setActiveTournament(id) || 'tournamentVolunteerSignup'
  '*': 'notFound'

Handlebars.registerHelper 'setTab', (tabName, options) ->
  Session.set 'selected_tab', tabName 

Session.set 'active-tournament', {tournamentId: '', name: '', slug: ''}

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

Template.userMessages.showMessage = (options) ->
  Session.set 'user-message', 
    title: options.title,
    message: options.message,
    type: 'alert alert-' + options.type
  setTimeout -> 
    Session.set 'user-message', 
      type: '', title: '', message: '',
  , options.timeout || 4000 unless options.type is 'error'

$('button[data-dismiss]').click ->
  Session.set 'user-message',
    type: '', title: '', message: ''
    # type can be 'error', 'success', and 'info'

# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'