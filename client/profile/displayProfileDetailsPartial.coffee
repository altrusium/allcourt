Template.displayProfileDetails.profileDetails = ->
  user = Meteor.user()
  details = user.profile || {}
  if details.photoFilename
    details.photoFile = allcourt.photoRoot + details.photoFilename
  details.isMale = details.gender is 'male'
  details

Template.displayProfileDetails.events =
  'click #editProfile': (evnt, template) ->
    Router.go 'profileEdit'
    false
