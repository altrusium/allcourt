Volunteers = new Meteor.Collection 'volunteers'
Tournaments = new Meteor.Collection 'tournaments'
TournamentVolunteers = new Meteor.Collection 'tournamentVolunteers'

getRoles = (id) ->
	unless id
		return
	tournament = Tournaments.findOne id, fields: roles: 1
	return tournament.roles
