createEmailAddress = ->
  firstName = $('#firstName').val()
  lastName = $('#lastName').val()
  name = emailHelper.prepareName firstName, lastName
  address = name + emailHelper.addressSuffix

sendUserSearchQuery = (query) ->
  # submitUserSearch is global and defined in app/lib/streams.coffee
  submitUserSearch query, (results) ->
    for user in results
      user.isMale = user.gender is 'male'
      for reg in user.registrations
        reg.slug = user.slug
        reg.canPrintBadge = user.photoFilename and reg.accessCode
    Session.set 'search-results', results

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

getSortedTournaments = ->
  tournaments = Tournaments.find {}, fields: tournamentName: 1, slug: 1, days: 1
  list = tournaments.fetch()
  list.sort (t1, t2) ->
    date1 = new Date(t1.days[0])
    date2 = new Date(t2.days[0])
    if date1 > date2 then return -1
    if date1 < date2 then return 1
    return 0
  return list

setActiveUser = (id) ->
  Session.set 'active-user', Meteor.users.findOne id

setActiveTournament = (id) ->
  tournament = Tournaments.findOne _id: id
  Session.set 'active-tournament', tournament

setActiveRegistration = (id) ->
  registration = Registrants.findOne id
  Session.set 'active-registration', registration

setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament.roles, (role) ->
    if role.roleId is rId then return role
  Session.set 'active-role', activeRole

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  role = Session.get 'active-role'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam

getActiveTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value
    function: template.find('#function').value
    accessCode: template.find('#accessCode').value

updateRegistration = (userDetails) ->
  teamId = Session.get('active-team').teamId
  registrantId = Session.get('active-registration')._id
  userDetails.userId = userDetails._id
  userDetails.tournamentId = Session.get('active-tournament')._id
  try
    Meteor.call 'updateRegistrant', userDetails
    Meteor.call 'addTeamToRegistrant', registrantId, teamId
    setActiveUser userDetails._id
    setActiveRegistration registrantId
    Template.userMessages.showMessage
      type: 'info'
      title: 'Success:'
      message: 'User has been successfully registered.'
  catch err
    Template.userMessages.showMessage
      type: 'error'
      title: 'Registration Failed:'
      message: 'An error has occurred. Reason: ' + err.reason

associateUserWithTournament = (userDetails) ->
  details =
    userId: userDetails._id
    addedBy: Meteor.userId()
    function: userDetails.function
    accessCode: userDetails.accessCode
    teams: [Session.get('active-team').teamId]
    tournamentId: Session.get('active-tournament')._id
  Meteor.call 'addRegistrant', details, (err, id) ->
    unless err
      Template.userMessages.showMessage
        type: 'info'
        title: 'Success:'
        message: 'User has been successfully registered.'
      setActiveUser userDetails._id
      setActiveRegistration id
    else
      Template.userMessages.showMessage
        type: 'error'
        title: 'Sign-up Failed:'
        message: 'An error occurred while registering user. Please refresh
          the browser and let us know if this continues.'

addVolunteerRecord = (id) ->
  isVolunteer = $("#role option:selected").text() is 'Volunteer'
  if isVolunteer
    volunteer = Volunteers.findOne id
    unless volunteer
      Meteor.call 'createNewVolunteer', _id: id, (err) ->
        if err
          Template.userMessages.showMessage
            type: 'error'
            title: 'Uh oh! '
            message: 'There was an error creating your volunteer record.
              Reason: ' + err.reason

addNewRegistrant = (template) ->
  userDetails = getUserFormValues template
  userDetails.email = createEmailAddress()
  userDetails.isNew = false
  Meteor.call 'createNewUser', userDetails, (err, id) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The new registrant was not saved successfully. Reason: ' +
          err.reason
    else
      userDetails._id = id
      addVolunteerRecord id
      associateUserWithTournament userDetails

updateActiveRegistrant = (user, template) ->
  userDetails = getUserFormValues template
  userDetails._id = user._id
  userDetails.email = user.profile.email
  userDetails.isNew = user.profile.isNew
  Meteor.call 'updateUser', userDetails, (err) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The user information was not updated. Reason: ' + err.reason
    else
      updateRegistration userDetails




Template.accreditation.created = ->
  Session.set 'active-tab', 'find'

Template.accreditation.rendered = ->
  if Session.get('active-user')?.profile.photoFilename
    $('.photo-placeholder').removeClass 'empty'

Template.accreditation.photoRoot = ->
  return photoHelper.photoRoot

Template.accreditation.findTabIsActive = ->
  if Session.get('active-tab') is 'find' then return 'active'

Template.accreditation.addEditTabIsActive = ->
  if Session.get('active-tab') is 'addEdit' then return 'active'

Template.accreditation.users = ->
  Session.get 'search-results'

Template.accreditation.tournaments = ->
  getActiveTournaments()

Template.accreditation.roles = ->
  tournament = Session.get 'active-tournament'
  unless tournament then return []
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.accreditation.teams = ->
  roleId = Session.get('active-role')?.roleId
  unless roleId then return []
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.accreditation.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')?._id
    return 'selected'

Template.accreditation.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected'

Template.accreditation.markSelectedTeam = ->
  if this.teamId is Session.get('active-team')?.teamId
    return 'selected'

Template.accreditation.registrationDetails = ->
  unless Session.get('active-user') then return {}
  user = Session.get('active-user').profile
  registration = Session.get('active-registration')
  unless (user and registration) then return {}
  user.isMale = user.gender is 'male'
  user.isFemale = user.gender isnt 'male'
  user.function = registration.function
  user.accessCode = registration.accessCode
  if user.photoFilename
    user.photoPath = photoHelper.photoRoot + user.photoFilename
  user

Template.accreditation.userSlug = ->
  Session.get('active-user')?.profile?.slug

Template.accreditation.tournamentSlug = ->
  Session.get('active-tournament')?.slug

Template.accreditation.canPrintActiveBadge = ->
  Session.get('active-user')?.profile?.photoFilename and
    Session.get('active-registration')?.accessCode



Template.accreditation.events =

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    if query
      sendUserSearchQuery query
      Session.set 'active-team', null
      Session.set 'active-role', null
      Session.set 'active-tournament', null
    else
      emptySearchResults()
    false

  'click [data-details-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    setActiveUser anchor.data 'user-id'
    setActiveRegistration anchor.data 'registrant-id'
    registration = Session.get 'active-registration'
    setActiveTournament registration.tournamentId

    team = (team for team in Session.get('active-tournament').teams \
      when team.teamId is registration.teams[0])[0]
    Session.set 'active-role', roleId: team?.roleId
    Session.set 'active-team', team
    Session.set 'active-tab', 'addEdit'
    emptySearchResults()
    false

  'change #tournament': (evnt, template) ->
    id = $('option:selected', evnt.currentTarget).val()
    emptySearchResults()
    Session.set 'active-team', null
    Session.set 'active-role', null
    setActiveTournament id

  'change #role': (evnt, template) ->
    setActiveRole()
    setActiveTeam()

  'change #team': (evnt, template) ->
    setActiveTeam()

  'click .find-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'find'

  'click .add-edit-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'addEdit'

  'submit .navbar-search': (evnt, template) ->
    false

  'click #saveRegistrant': (evnt, template) ->
    user = Session.get 'active-user'
    if user
      updateActiveRegistrant user, template
    else
      addNewRegistrant template

  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')

