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

Meteor.Router.add
  '/': 'home',
  '/volunteers': 'volunteers'
  '/volunteer/create': 'volunteerCreate'
  '/volunteer/list': 'volunteerList'
  '/volunteer/edit/:slug': (slug) ->
    return setActiveVolunteer(slug) || 'volunteerCreate'
  '/volunteer/:slug': (slug) ->
    return setActiveVolunteer(slug) || 'volunteerDetails'
  '/shifts': 'shifts'
  '/tournaments': 'tournaments'
  '/tournament/create': 'setupTournament'
  '/tournament/list': 'tournamentList'
  '/tournament/roles': 'setupRoles'
  '/tournament/shifts': 'setupShifts'
  '/tournament/:slug': (slug) ->
    return setActiveTournament(slug) || 'tournamentDetails'
  '/tournament/:slug/signup': (id) ->
    return setActiveTournament(slug) || 'tournamentVolunteerSignup'
  '*': 'notFound'

Handlebars.registerHelper 'select', (value, options) ->
  $el = $('<select />').html options.fn(this)
  $el.find('[value=' + value + ']').attr({'selected':'selected'})
  return $el.html()

Session.set 'active-tournament', { tournamentId: '', name: '', slug: '' }


Template.activeTournament.tournament = ->
  tournament = Session.get 'active-tournament'
  return tournament || tournamentId: '', name: ''

# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'