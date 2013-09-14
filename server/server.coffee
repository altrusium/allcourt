process.env.MAIL_URL = "smtp://postmaster@allcourt.co.nz:3w2b7k814mn4@smtp.mailgun.org:25"

Meteor.publish 'volunteers', ->
	return Volunteers.find()
	
Meteor.publish 'tournaments', ->
	return Tournaments.find()

Meteor.publish 'tournamentVolunteers', ->
	return TournamentVolunteers.find()

