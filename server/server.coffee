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

Meteor.publish null, ->
  return Meteor.users.find {}, fields: username: 1, email: 1, profile: 1

Meteor.publish 'schedule', ->
  return Schedule.find()

Meteor.publish 'volunteers', ->
  return Volunteers.find()

Meteor.publish 'tournaments', ->
  return Tournaments.find()

Meteor.publish 'registrants', ->
  return Registrants.find()

Meteor.publish 'user-list-with-team', (teamId, tournamentId) ->
  selector = registrations: { teamId: teamId, tournamentId: tournamentId }
  return Registrations.find selector

Meteor.publish 'user-list-with-role', (roleId, tournamentId) ->
  selector = registrations: { roleId: roleId, tournamentId: tournamentId }
  return Registrations.find selector

Meteor.publish 'user-list-with-name', (searchString) ->
  registrations = Registrations.find({}).fetch()
  searcher = new FuseSearch registrations, keys: ['fullName']
  searcher.search searchString
