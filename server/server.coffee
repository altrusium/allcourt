process.env.MAIL_URL = "smtp://postmaster@allcourt.co.nz:3w2b7k814mn4@smtp.mailgun.org:25"

Accounts.emailTemplates.siteName = 'All-court (allcourt.co.nz)'
Accounts.emailTemplates.from = 'All-court Admin <admin@allcourt.co.nz>'
Accounts.emailTemplates.resetPassword.subject = (user) ->
  'Resetting your All-court password'
Accounts.emailTemplates.resetPassword.text = (user, url) ->
	msg = "Hi #{user.profile.firstName},\n\n
To reset your password on allcourt.co.nz, simply click the link below and enter a new password on the resulting page.\n\n
#{url}\n\n\n
All the best,\n\n
Don Smith\n
allcourt.co.nz"
	msg

Meteor.publish 'volunteers', ->
	return Volunteers.find()
	
Meteor.publish 'tournaments', ->
	return Tournaments.find()

Meteor.publish 'tournamentVolunteers', ->
	return TournamentVolunteers.find()

