userId = ''
myTournaments = null

getCalculatedAge = (birthdate) ->
  if birthdate then moment().diff(moment(birthdate, 'DD MMM YYYY'), 'years')

getTeamInfo = (tournamentId, teamId) ->
  tournament = Tournaments.findOne tournamentId
  _.find tournament.teams, (team) ->
    team.teamId is teamId

Template.userDetails.detail = ->
  user = Session.get 'active-user'
  volunteerInfo = Volunteers.findOne user._id
  profile = user.profile
  user.isMale = profile.gender is 'male'
  user.photoFilename = profile.photoFilename
  user.firstName = profile.firstName
  user.lastName = profile.lastName
  user.email = profile.email
  user.slug = profile.slug
  if volunteerInfo
    user.age = getCalculatedAge volunteerInfo.birthdate
    user.shirtSize = volunteerInfo.shirtSize
    user.homePhone = volunteerInfo.homePhone
    user.mobilePhone = volunteerInfo.mobilePhone
    user.notes = volunteerInfo.notes
  return user

Template.userDetails.photoRoot = ->
  return allcourt.photoRoot

Template.userDetails.myTournamentsExist = ->
  userId = Session.get('active-user')._id
  myTournaments = allcourt.userTournaments userId

Template.userDetails.myTournaments = ->
  result = for myT in myTournaments
    reg = Registrants.findOne userId: userId, tournamentId: myT._id
    myT.teams = for team in reg?.teams
      getTeamInfo myT._id, team
    myT
  result

Template.userDetails.events =
  'click #deleteVolunteer': (evnt, template) ->
    $('#deleteModal').modal()

  'click #deleteConfirmed': (evnt, template) ->
    id = Session.get('active-user')._id
    Meteor.call 'deleteUser', id, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: 'Error!',
          message: 'The user was not deleted. Reason: ' + err.reason
      else
        Template.userMessages.showMessage
          type: 'info',
          title: 'Deleted!',
          message: 'The user was deleted'
        Router.go 'users'

  'click #deleteCancelled': (evnt, template) ->
    $('#deleteModal').hide()

  'click #editProfile': (evnt, template) ->
    Router.go 'userEdit', userSlug: Session.get('active-user').profile.slug

  'click [data-shifts-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    teamId = anchor.data('team-id')
    teamName = anchor.data('team-name')
    tournamentSlug = anchor.data('tournament-slug')
    userSlug = Session.get('active-user').profile.slug
    Session.set 'active-team', { teamId: teamId, teamName: teamName }
    Router.go 'userPreferences', {
      userSlug: userSlug,
      tournamentSlug: tournamentSlug
    }
    false

  'click [data-details-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    teamId = anchor.data('team-id')
    teamName = anchor.data('team-name')
    tournamentSlug = anchor.data('tournament-slug')
    userSlug = Session.get('active-user').profile.slug
    Session.set 'active-team', { teamId: teamId, teamName: teamName }
    Router.go 'registrantDetails', {
      userSlug: userSlug,
      tournamentSlug: tournamentSlug
    }
    false

  'click [data-badge-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    teamId = anchor.data('team-id')
    teamName = anchor.data('team-name')
    tournamentSlug = anchor.data('tournament-slug')
    userSlug = Session.get('active-user').profile.slug
    Session.set 'active-team', { teamId: teamId, teamName: teamName }
    Router.go 'registrantBadge', {
      userSlug: userSlug,
      tournamentSlug: tournamentSlug
    }
    false
