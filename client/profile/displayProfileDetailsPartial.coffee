allcourt.photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'



Template.displayProfileDetails.profileDetails = ->
  user = Meteor.user()
  details = user.profile || {}
  if details.photoFilename
    details.photoFile = allcourt.photoRoot + details.photoFilename
  details.isMale = details.gender is 'male'
  details

Template.displayProfileDetails.events =
  'click #editProfile': (evnt, template) ->
    Meteor.Router.to '/profile/edit/'
    false
