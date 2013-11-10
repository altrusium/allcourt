@allcourt = {}

allcourt.photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

allcourt.isAdmin = ->
  Meteor.user().profile.admin

allcourt.getTournamentLinkHelper = ->
  return {
    tournamentSlug: Session.get('active-tournament').slug,
    userSlug: Session.get('active-user') or Meteor.user().profile.slug
  }
  
