setActiveRole = ->
  rId = $('#role option:selected').val()
  tournament = Session.get 'active-tournament'
  activeRole = _.find tournament.roles, (role) ->
    if role.roleId is rId then return role
  Session.set 'active-role', activeRole

setActiveTeam = ->
  tId = $('#team option:selected').val()
  tournament = Session.get 'active-tournament'
  activeTeam = _.find tournament.teams, (team) ->
    if team.teamId is tId then return team
  Session.set 'active-team', activeTeam

associateUserWithTournament = (userId) ->
  setActiveTeam()
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team').teamId
  signup = Registrants.findOne { tournamentId: tId, userId: userId }
  Registrants.insert { 
    userId: userId, 
    teams: [teamId],
    tournamentId: tId, 
    addedBy: Meteor.userId()
  }, (err, id) ->
    unless err
      Session.set 'reg-id', id
      setAcceptedShifts()
      Template.userMessages.showMessage
        type: 'info'
        title: 'Success:'
        message: 'You have successfully registered. Thank you!'
    else
      Template.userMessages.showMessage
        type: 'error'
        title: 'Sign-up Failed:'
        message: 'A registration error occurred. Please refresh your browser and let us know if this continues.'

createNewVolunteer = (options, callback) ->
  Volunteers.insert { 
    _id: options._id,
    birthdate: options.birthdate || '',
    shirtSize: options.shirtSize || '',
    homePhone: options.homePhone || '',
    mobilePhone: options.mobilePhone || '',
    address: options.address || '',
    city: options.city || '',
    suburb: options.suburb || '',
    postalCode: options.postalCode || '',
    notes: options.notes || ''
  }, callback




Template.register.rendered = ->
  setActiveRole()

Template.register.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.register.roles = ->
  tournament = Session.get 'active-tournament'
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.register.events
  'change #role': (evnt, template) ->
    setActiveRole()
    setActiveTeam()
  'change #team': (evnt, template) ->
    setActiveTeam()
  'click #registerButton': (evnt, template) ->
    userId = Meteor.userId()
    slug = Session.get('active-tournament').slug
    if not $('#agreed').prop('checked')
      window.scrollTo 0, 0
      Template.userMessages.showMessage
        type: 'error'
        title: 'Agree? '
        message: 'To continue, you must agree to the terms by checking the box.'
    else
      associateUserWithTournament userId
      if Session.get('active-team').teamName = 'Volunteer'
        createNewVolunteer _id: userId, (err) ->
          if err
            Template.userMessages.showMessage
              type: 'error'
              title: 'Uh oh! '
              message: 'There was an error creating your volunteer record. Reason: ' + err.reason
      Router.go 'preferences', tournamentSlug: slug
    false
