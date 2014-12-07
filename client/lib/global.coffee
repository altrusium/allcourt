@allcourt = {}

allcourt.photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

allcourt.isAdmin = ->
  Meteor.user() && Roles.userIsInRole Meteor.user(), 'admin'

allcourt.getTournamentLinkHelper = ->
  return {
    tournamentSlug: Session.get('active-tournament').slug,
    userSlug: Session.get('active-user') or Meteor.user().profile.slug
  }

allcourt.getNoPhotoPath = (gender) ->
  path = '/img/no-female-photo.jpg'
  if gender is 'male'
    path = '/img/no-male-photo.jpg'
  path



