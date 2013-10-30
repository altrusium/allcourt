photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'




Template.users.rendered = ->
  Session.set 'active-volunteer', null

Template.users.photoRoot = ->
  return photoRoot

Template.users.users = ->
  Meteor.users.find().map (user) ->
    user.isMale = ->
      return user.profile.gender is 'male'
    user.profile

