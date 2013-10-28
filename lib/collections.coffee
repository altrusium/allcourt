@Volunteers = new Meteor.Collection 'volunteers'
@Registrants = new Meteor.Collection 'registrants'
@Tournaments = new Meteor.Collection 'tournaments'

Meteor.users.allow
  insert: (userId, doc) ->
    Meteor.user().profile.admin
  update: (userId, doc) ->
    Meteor.user().profile.admin
  remove: (userId, doc) ->
    Meteor.user().profile.admin

Volunteers.allow
  insert: (userId, doc) ->
    Meteor.userId() is doc._id or Meteor.user().profile.admin
  update: (userId, doc) ->
    Meteor.userId() is doc._id or Meteor.user().profile.admin
  remove: (userId, doc) ->
    Meteor.user().profile.admin

Tournaments.allow
  insert: (userId, doc) ->
    Meteor.user().profile.admin
  update: (userId, doc) ->
    Meteor.user().profile.admin
  remove: (userId, doc) ->
    Meteor.user().profile.admin

Registrants.allow
  insert: (userId, doc) ->
    true
  update: (userId, doc) ->
    true
  remove: (userId, doc) ->
    Meteor.user().profile.admin

