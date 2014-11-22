@Schedule = new Meteor.Collection 'schedule'
@Volunteers = new Meteor.Collection 'volunteers'
@Registrants = new Meteor.Collection 'registrants'
@Tournaments = new Meteor.Collection 'tournaments'
@Registrations = new Meteor.Collection 'registrations'

if Meteor.isClient
  @scheduleSubscription = Meteor.subscribe 'schedule'
  @volunteersSubscription = Meteor.subscribe 'volunteers'
  @tournamentsSubscription = Meteor.subscribe 'tournaments'
  @registrantsSubscription = Meteor.subscribe 'registrants'

Meteor.users.allow
  insert: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'
  update: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'
  remove: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'

Schedule.allow
  insert: (userId, doc) ->
    true
  update: (userId, doc) ->
    true
  remove: (userId, doc) ->
    true

Volunteers.allow
  insert: (userId, doc) ->
    Meteor.userId() is doc._id or Roles.userIsInRole Meteor.user(), 'admin'
  update: (userId, doc) ->
    Meteor.userId() is doc._id or Roles.userIsInRole Meteor.user(), 'admin'
  remove: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'

Tournaments.allow
  insert: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'
  update: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'
  remove: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'

Registrants.allow
  insert: (userId, doc) ->
    true
  update: (userId, doc) ->
    true
  remove: (userId, doc) ->
    Roles.userIsInRole Meteor.user(), 'admin'

Registrations.allow
  insert: (userId, doc) ->
    Meteor.userId() is doc._id or Roles.userIsInRole Meteor.user(), 'admin'
  update: (userId, doc) ->
    Meteor.userId() is doc._id or Roles.userIsInRole Meteor.user(), 'admin'
  remove: (userId, doc) ->
    Meteor.userId() is doc._id or Roles.userIsInRole Meteor.user(), 'admin'

