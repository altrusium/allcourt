createEmailAddress = ->
  firstName = $('#firstName').val()
  lastName = $('#lastName').val()
  name = emailHelper.prepareName firstName, lastName
  address = name + emailHelper.addressSuffix

setActiveContext = ->
  tournament = Session.get('active-tournament')
  teams = tournament.teams
  roles = tournament.roles
  proxyReg = Registrants.findOne
    userId: Meteor.userId()
    tournamentId: tournament._id
  team = (team for team in teams \
    when team.teamId is proxyReg.teams[0])[0]
  Session.set 'active-team', team
  role = (role for role in roles \
    when role.roleId is team.roleId)[0]
  Session.set 'active-role', role

getPossibleRegistrants = ->
  # get ID of active tournament
  tId = Session.get('active-tournament')._id
  # get signed in user's registration
  proxyId = Meteor.userId()
  reg = Registrations.findOne proxyId
  instance = (r for r in reg.registrations when r.tournamentId is tId)
  role = r.roleName
  team = r.teamName
  registrations = Registrations.find { registrations: $elemMatch: roleName: role, teamName: team }, {sort: fullName: 1}

setActiveUser = (id) ->
  Session.set 'active-user', Meteor.users.findOne id

setActiveRegistration = (id) ->
  registration = Registrants.findOne id
  Session.set 'active-registration', registration

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value
    function: template.find('#function').value

getExistingUserDetails = (id) ->
  user = Session.get 'active-user'
  details = user.profile
  details._id = user._id
  details.isNew = false
  details

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

unregisterUserFromTournament = (userId) =>
  tournamentId = Session.get('active-tournament')._id
  Meteor.call 'unregisterUserFromTournament', userId, tournamentId, (err) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The user was not unregistered. Reason: ' + err.reason



Template.userRegistration.created = ->
  setActiveContext()
  Session.set 'active-tab', 'registered'

Template.userRegistration.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.userRegistration.photoRoot = ->
  return photoHelper.photoRoot

Template.userRegistration.notRegisteredUsers = ->
  notRegistered = []
  tId = Session.get('active-tournament')._id
  possibles = getPossibleRegistrants().fetch()
  for reg in possibles
    found = 0
    for r in reg.registrations
      if r.tournamentId is tId then found++
      reg.registration = reg.registration || r
    if not found then notRegistered.push reg
  notRegistered

Template.userRegistration.registeredUsers = ->
  registered = []
  tId = Session.get('active-tournament')._id
  possibles = getPossibleRegistrants().fetch()
  for reg in possibles
    for r in reg.registrations when r.tournamentId is tId
      reg.registration = r
      registered.push reg
  registered

Template.userRegistration.registeredTabIsActive = ->
  if Session.get('active-tab') is 'registered' then return 'active'

Template.userRegistration.notRegisteredTabIsActive = ->
  if Session.get('active-tab') is 'notRegistered' then return 'active'

Template.userRegistration.addEditTabIsActive = ->
  if Session.get('active-tab') is 'addEdit' then return 'active'

Template.userRegistration.tournamentName = ->
  return Session.get('active-tournament').tournamentName

Template.userRegistration.roleName = ->
  return Session.get('active-role').roleName

Template.userRegistration.teamName = ->
  return Session.get('active-team').teamName

Template.userRegistration.registrationDetails = ->
  unless Session.get('active-user') then return {}
  user = Session.get('active-user').profile
  registration = Session.get('active-registration')
  unless (user and registration) then return {}
  user.isMale = user.gender is 'male'
  user.isFemale = user.gender isnt 'male'
  user.function = registration.function
  if user.photoFilename
    user.photoPath = photoHelper.photoRoot + user.photoFilename
  user



Template.userRegistration.events =

  'click [data-edit]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    setActiveUser anchor.data 'user-id'
    if anchor.data 'registrant-id'
      setActiveRegistration anchor.data 'registrant-id'
      registration = Session.get 'active-registration'
    Session.set 'active-tab', 'addEdit'
    false

  'click [data-register]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    userId = anchor.data 'user-id'
    setActiveUser userId
    user = getExistingUserDetails userId
    associateUserWithTournament user


  'click [data-unregister]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    userId = anchor.data 'user-id'
    unregisterUserFromTournament userId

  'click .registered-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'registered'

  'click .not-registered-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'notRegistered'

  'click .add-edit-tab': (evnt, template) ->
    Session.set 'active-registration', null
    Session.set 'active-user', null
    Session.set 'active-tab', 'addEdit'

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

