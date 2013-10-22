@Volunteers = new Meteor.Collection 'volunteers'
@Tournaments = new Meteor.Collection 'tournaments'
@TournamentVolunteers = new Meteor.Collection 'tournamentVolunteers'

Meteor.users.allow
  insert: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
  update: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
  remove: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'

Volunteers.allow
  insert: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
  update: (userId, doc) ->
    return Meteor.userId() is doc._id or Meteor.user().profile.role is 'admin'
  remove: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'

Tournaments.allow
  insert: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
  update: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
  remove: (userId, doc) ->
    return Meteor.user().profile.role is 'admin'
