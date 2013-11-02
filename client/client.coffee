schedule = Meteor.subscribe 'schedule'
volunteers = Meteor.subscribe 'volunteers'
tournaments = Meteor.subscribe 'tournaments'
registrants = Meteor.subscribe 'registrants'

setActiveTournament = (slug) ->
  tournament = Tournaments.findOne slug: slug
  unless tournament
    return 'notFound'
  else
    Session.set 'active-tournament', tournament
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

setActiveUser = (slug) ->
  userDetails = Meteor.users.findOne 'profile.slug': slug
  unless userDetails
    return 'notFound'
  else
    Session.set 'active-user', userDetails
    return false
    
isAdmin = ->
  return Meteor.user() and Meteor.user().profile.admin

Meteor.Router.add
  '/': 'home',
  '/profile': 'profileDetails',
  '/profile/edit': 'profileEdit',
  '/users': ->
    return if isAdmin() then 'users' else 'notAuthorised'
  '/user/create': ->
    return if isAdmin() then 'userCreate' else 'notAuthorised'
  '/user/edit/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveUser(slug) or 'userCreate'
  '/user/:slug': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveUser(slug) or 'userDetails'
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
  '/tournaments': 'tournaments' 
  '/tournament/create': ->
    return if isAdmin() then 'createTournament' else 'notAuthorised'
  '/tournament/:slug/roles': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) or 'setupRoles' 
  '/tournament/:slug/teams': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) or 'setupTeams' 
  '/tournament/:slug/registrants': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) or 'setupRegistrants' 
  '/tournament/:slug/shifts': (slug) ->
    unless isAdmin() then return 'notAuthorised'
    return setActiveTournament(slug) or 'setupShifts' 
  '/tournament/:slug': (slug) ->
    return setActiveTournament(slug) or 'tournamentDetails'
  '/tournament/:slug/register': (slug) ->
    return setActiveTournament(slug) or 'register'
  '/tournament/:slug/preferences': (slug) ->
    return setActiveTournament(slug) or 'preferences'
  '/tournament/:slug/schedule': (slug) ->
    setActiveTournament(slug) 
    if isAdmin() then 'schedule' else 'userSchedule'
  '*': 'notFound'

Template.activeTournament.tournament = ->
  tournament = Session.get 'active-tournament'
  return tournament 

# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'