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
  userDetails = Meteor.users.findOne 'profile.slug': slug
  volunteer = userDetails and Volunteers.findOne userDetails._id
  unless volunteer
    return 'notFound'
  else
    volunteer.userDetails = userDetails
    Session.set 'active-volunteer', volunteer
    return false

isAdmin = ->
  return Meteor.user() and Meteor.user().profile.role is 'admin'

Meteor.Router.add
  '/': 'home',
  '/profile': 'profileDetails',
  '/profile/edit': 'profileEdit',
  '/volunteers': ->
    return if isAdmin() then 'volunteers' else 'notAuthorised'
  '/volunteer/create': ->
    return if isAdmin() then 'volunteerCreate' else 'notAuthorised'
  '/volunteer/list': ->
    return if isAdmin() then 'volunteerList' else 'notAuthorised'
  '/volunteer/edit/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveVolunteer(slug) or 'volunteerCreate'
  '/volunteer/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveVolunteer(slug) or 'volunteerDetails'
  '/shifts': ->
    return if isAdmin() then 'shifts' else 'notAuthorised'
  '/tournaments': ->
    return if isAdmin() then 'tournaments' else 'notAuthorised'
  '/tournament/create': ->
    return if isAdmin() then 'setupTournament' else 'notAuthorised'
  '/tournament/list': 'tournamentList'
  '/tournament/roles': ->
    return if isAdmin() then 'setupRoles' else 'notAuthorised'
  '/tournament/shifts': ->
    return if isAdmin() then 'setupShifts' else 'notAuthorised'
  '/tournament/:slug': (slug) ->
    return setActiveTournament(slug) or 'tournamentDetails'
  '/tournament/:slug/signup': (slug) ->
    return setActiveTournament(slug) or 'tournamentVolunteerSignup'
  '*': 'notFound'

Session.set 'active-tournament', { tournamentId: '', name: '', slug: '' }

Template.activeTournament.tournament = ->
  tournament = Session.get 'active-tournament'
  return tournament or tournamentId: '', name: ''

# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'