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

Router.onBeforeAction mustBeSignedIn, except: ['home']
Router.onBeforeAction mustBeAnAdmin, except: [
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
    onBeforeAction: ->
      Session.set 'active-user', null

  this.route 'userEdit',
    path: '/user/edit/:userSlug'
    template: 'userCreate'
    onBeforeAction: ->
      setActiveUser.call(this)
      setActiveVolunteer.call(this)
    data: ->
      Session.get 'active-user'

  this.route 'userDetails',
    path: 'user/:userSlug'
    onBeforeAction: setActiveUser
    data: ->
      Session.get 'active-user'

  this.route 'userPreferences',
    path: 'user/:userSlug/preferences/:tournamentSlug'
    onBeforeAction: ->
      setActiveUser.call(this)
      setActiveTournament.call(this)
    data: ->
      Session.get('active-user') and Session.get('active-tournament')

  this.route 'registrantBadge',
    layoutTemplate: 'blank'
    path: 'registrant/:userSlug/:tournamentSlug/badge'
    onBeforeAction: ->
      setActiveUser.call(this)
      setActiveTournament.call(this)
    data: ->
      Session.get('active-user') and Session.get('active-tournament')

  this.route 'registrantDetails',
    path: 'registrant/:userSlug/:tournamentSlug'
    onBeforeAction: ->
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
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'setupTeams',
    path: '/:tournamentSlug/teams'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'setupRegistrants',
    path: '/:tournamentSlug/registrants'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'setupShifts',
    path: '/:tournamentSlug/shifts'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'register',
    path: '/:tournamentSlug/register'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'preferences',
    path: '/:tournamentSlug/preferences'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'schedule',
    path: '/:tournamentSlug/schedule'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'

  this.route 'userSchedule',
    path: '/:tournamentSlug/schedule/:userSlug'
    onBeforeAction: ->
      setActiveTournament.call(this)
      setActiveUser.call(this)
    data: ->
      Session.get('active-tournament')? and Session.get('active-user')?

  this.route 'tournamentDetails',
    path: '/:tournamentSlug'
    onBeforeAction: setActiveTournament
    data: ->
      Session.get 'active-tournament'
