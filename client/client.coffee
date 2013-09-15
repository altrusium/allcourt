volunteers = Meteor.subscribe 'volunteers'
tournaments = Meteor.subscribe 'tournaments'
tournamentVolunteers = Meteor.subscribe 'tournamentVolunteers'

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

setActiveVolunteer = (slug) ->
  if volunteers.ready()
    volunteer = Volunteers.findOne slug: slug
    unless volunteer
      return 'notFound'
    else
      Session.set 'active-volunteer', volunteer
      return false
  else 
    return 'loading'

isAdmin = ->
  return Meteor.user() && Meteor.user().profile.type is 'admin'

Meteor.Router.add
  '/': 'home',
  '/volunteers': ->
    return if isAdmin() then 'volunteers' else 'notAuthorised'
  '/volunteer/create': ->
    return if isAdmin() then 'volunteerCreate' else 'notAuthorised'
  '/volunteer/list': ->
    return if isAdmin() then 'volunteerList' else 'notAuthorised'
  '/volunteer/edit/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveVolunteer(slug) || 'volunteerCreate'
  '/volunteer/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveVolunteer(slug) || 'volunteerDetails'
  '/shifts': ->
    return if isAdmin() then 'shifts' else 'notAuthorised'
  '/tournaments': ->
    return if isAdmin() then 'tournaments' else 'notAuthorised'
  '/tournament/create': ->
    return if isAdmin() then 'setupTournament' else 'notAuthorised'
  '/tournament/list': ->
    return if isAdmin() then 'tournamentList' else 'notAuthorised'
  '/tournament/roles': ->
    return if isAdmin() then 'setupRoles' else 'notAuthorised'
  '/tournament/shifts': ->
    return if isAdmin() then 'setupShifts' else 'notAuthorised'
  '/tournament/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) || 'tournamentDetails'
  '/tournament/:slug/signup': (id) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) || 'tournamentVolunteerSignup'
  '*': 'notFound'

Session.set 'active-tournament', { tournamentId: '', name: '', slug: '' }

Template.activeTournament.tournament = ->
  tournament = Session.get 'active-tournament'
  return tournament || tournamentId: '', name: ''

# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'