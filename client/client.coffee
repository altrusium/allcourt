setActiveTournament = ->
  slug = this.params?.tournamentSlug
  tournament = Tournaments.findOne slug: slug
  Session.set 'active-tournament', tournament

setActiveVolunteer = ->
  slug = this.params.userSlug
  userDetails = Meteor.users.findOne 'profile.slug': slug
  volunteer = Volunteers.findOne userDetails?._id
  Session.set 'active-volunteer', volunteer

setActiveUser = ->
  slug = this.params.userSlug
  user = Meteor.users.findOne 'profile.slug': slug
  Session.set 'active-user', user
    
onlyShow = (template, router) ->
  router.render()
  router.render(template)
  router.stop()

mustBeSignedIn = ->
  unless Meteor.user() 
    onlyShow 'home', this
  window.scrollTo 0, 0

mustBeAnAdmin = ->
  unless allcourt.isAdmin() then onlyShow 'notFound', this 

Router.configure 
  layoutTemplate: 'main'
  notFoundTemplate: 'notFound'

Router.before mustBeSignedIn, except: ['home']
Router.before mustBeAnAdmin, except: [
  'home', 
  'profileDetails', 
  'profileEdit', 
  'tournaments',
  'register',
  'preferences',
  'userSchedule'
]

Router.map ->
  this.route 'home',
    path: '/'

  this.route 'profileDetails',
    path: '/profile'

  this.route 'profileEdit',
    path: '/profile/edit'

  this.route 'users',
    path: '/users'

  this.route 'accreditation',
    path: '/accreditation'
      
  this.route 'userCreate',
    path: '/user/create'
    before: ->
      Session.set 'active-user', null

  this.route 'userEdit',
    path: '/user/edit/:userSlug'
    template: 'userCreate'
    before: ->
      setActiveUser.call(this)
      setActiveVolunteer.call(this)
    data: ->
      Session.get 'active-user'

  this.route 'userDetails',
    path: 'user/:userSlug'
    before: setActiveUser
    data: ->
      Session.get 'active-user'

  this.route 'userPreferences',
    path: 'user/:userSlug/preferences/:tournamentSlug'
    before: ->
      setActiveUser.call(this)
      setActiveTournament.call(this)
    data: ->
      Session.get('active-user') and Session.get('active-tournament')

  this.route 'registrantBadge',
    layoutTemplate: 'blank'
    path: 'registrant/:userSlug/:tournamentSlug/badge'
    before: ->
      setActiveUser.call(this)
      setActiveTournament.call(this)
    data: ->
      Session.get('active-user') and Session.get('active-tournament')

  this.route 'registrantDetails',
    path: 'registrant/:userSlug/:tournamentSlug'
    before: ->
      setActiveUser.call(this)
      setActiveTournament.call(this)
    data: ->
      Session.get('active-user') and Session.get('active-tournament')

  # '/volunteers': ->
  #   return if allcourt.isAdmin() then 'volunteers' else 'notAuthorised'
  # '/volunteer/create': ->
  #   return if allcourt.isAdmin() then 'volunteerCreate' else 'notAuthorised'
  # '/volunteer/list': ->
  #   return if allcourt.isAdmin() then 'volunteerList' else 'notAuthorised'
  # '/volunteer/edit/:slug': (slug) ->
  #   unless allcourt.isAdmin() then return 'notAuthorised'
  #   return setActiveVolunteer(slug) or 'volunteerCreate'
  # '/volunteer/:slug': (slug) ->
  #   unless allcourt.isAdmin() then return 'notAuthorised'
  #   return setActiveVolunteer(slug) or 'volunteerDetails'

  this.route 'tournaments',
    path: '/tournaments'

  this.route 'createTournament',
    path: '/tournament/create'

  this.route 'setupRoles',
    path: '/:tournamentSlug/roles'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'setupTeams',
    path: '/:tournamentSlug/teams'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'setupRegistrants',
    path: '/:tournamentSlug/registrants'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'setupShifts',
    path: '/:tournamentSlug/shifts'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'register',
    path: '/:tournamentSlug/register'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'preferences',
    path: '/:tournamentSlug/preferences'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'schedule',
    path: '/:tournamentSlug/schedule'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'
      
  this.route 'userSchedule',
    path: '/:tournamentSlug/schedule/:userSlug'
    before: ->
      setActiveTournament.call(this)
      setActiveUser.call(this)
    data: ->
      Session.get('active-tournament')? and Session.get('active-user')?
      
  this.route 'tournamentDetails',
    path: '/:tournamentSlug'
    before: setActiveTournament
    data: ->
      Session.get 'active-tournament'




# Template is in allcourt.html
Template.activeTournament.tournament = ->
  Session.get 'active-tournament'


# For debugging and styling
# Session.set 'user-message',
#   type: 'error'
#   title: 'Back again!'
#   message: 'Don\'t worry. I\'m not staying long'