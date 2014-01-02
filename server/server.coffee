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
  criteria = teamId: teamId, tournamentId: tournamentId
  selector = registrations: $elemMatch: criteria
  return Registrations.find selector, sort: fullName: 1

Meteor.publish 'user-list-with-role', (roleId, tournamentId) ->
  criteria = roleId: roleId, tournamentId: tournamentId
  selector = registrations: $elemMatch: criteria
  return Registrations.find selector, sort: fullName: 1
