photoRoot = 'http://s3-ap-southeast-2.amazonaws.com/shifty-photos/'

Template.userDetails.detail = ->
  user = Session.get 'active-user'
  profile = user.profile
  user.isMale = profile.gender is 'male'
  user.photoFilename = profile.photoFilename
  user.firstName = profile.firstName
  user.lastName = profile.lastName
  user.primaryEmail = profile.email
  user.slug = profile.slug
  return user

Template.userDetails.photoRoot = ->
  return photoRoot

Template.userDetails.availableTournamentsExist = ->
  tournaments = Template.volunteerDetails.availableTournaments()
  return tournaments.length > 0

Template.userDetails.availableTournaments = ->
  tournaments = Tournaments.find({}, fields: {tournamentName: 1, days: 1}).fetch()
  futureTournaments = for tournament in tournaments
    tournamentStartDate = new Date tournament.days[0]
    tournament if new Date() - tournamentStartDate < 0

Template.userDetails.myTournamentsExist = ->
  return false

Template.userDetails.myTournaments = ->
  return []

Template.userDetails.events =
  'click #deleteVolunteer': (evnt, template) ->
    $('#deleteModal').modal()
  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get('active-volunteer')._id
    Volunteers.remove id, ->
      Meteor.users.remove id, ->
      Meteor.Router.to '/volunteer/list'
      Template.userMessages.showMessage 
        type: 'info',
        title: 'Deleted!',
        message: 'The volunteer was deleted'
  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()
  'click #editProfile': (evnt, template) ->
    Meteor.Router.to '/user/edit/' + Session.get('active-user').profile.slug

