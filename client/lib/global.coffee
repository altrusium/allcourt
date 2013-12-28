@allcourt = {}

allcourt.photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

allcourt.isAdmin = ->
  Meteor.user().profile.admin

allcourt.getTournamentLinkHelper = ->
  return {
    tournamentSlug: Session.get('active-tournament').slug,
    userSlug: Session.get('active-user') or Meteor.user().profile.slug
  }

allcourt.removeWhitespace = (namePart) ->
  unless namePart then return ''
  return namePart.replace /\s/g, ''

allcourt.makeLowercase = (string) ->
  unless string then return ''
  return string.toLowerCase()

allcourt.prepNameForEmail = (first, last) ->
  unless first then return ''
  prepped = allcourt.removeWhitespace first
  prepped = allcourt.makeLowercase prepped
  if last then prepped = prepped + '.' + allcourt.prepNameForEmail last
  prepped