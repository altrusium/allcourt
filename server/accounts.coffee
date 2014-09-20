Accounts.emailTemplates.siteName = 'All-Court (allcourt.co.nz)'
Accounts.emailTemplates.from = 'All-Court Admin <admin@allcourt.co.nz>'

Accounts.emailTemplates.resetPassword.subject = (user) ->
  'Resetting your All-Court password'

Accounts.emailTemplates.resetPassword.text = (user, url) ->
  msg = "Hi #{user.profile.firstName},\n\n
To reset your password on allcourt.co.nz, simply click the
link below and enter a new password on the resulting page.\n\n
#{url}\n\n\n
All the best,\n\n
Don Smith\n
allcourt.co.nz"
  msg

userMatchingSlugAlreadyExists = (slug) ->
  Meteor.users.findOne 'profile.slug': slug

getUserCredentialService = (slug) ->
  service = 'a password'
  user = Meteor.users.findOne {'profile.slug': slug}, {services:1}
  if user.services.facebook then service = 'facebook'
  if user.services.google then service = 'google'
  service

Accounts.onCreateUser (options, user) ->
  user.profile = user.profile || options.profile || {}
  facebook = user.services && user.services.facebook
  google = user.services && user.services.google
  if facebook
    user.profile.email = facebook.email
    user.profile.firstName = facebook.first_name
    user.profile.lastName = facebook.last_name
    user.profile.gender = facebook.gender
  if google
    user.profile.email = google.email
    user.profile.firstName = google.given_name
    user.profile.lastName = google.family_name
    user.profile.gender = google.gender
  user.profile.fullName = user.profile.firstName + ' ' + user.profile.lastName
  user.profile.slug = user.profile.firstName.replace(' ','') +
    user.profile.lastName.replace(' ','')
  user.profile.gender = user.profile.gender || 'female'

  if userMatchingSlugAlreadyExists user.profile.slug
    existingService = getUserCredentialService user.profile.slug
    throw new Meteor.Error 409, 'User matching this name
      already exists.', 'Try using ' + existingService + ' to
      sign in and let us know if this persists.'
  else
    return user


