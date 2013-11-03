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

sendNotificationEmail = (tournament, role, team) ->
  fullName = Meteor.user().profile.fullName
  Meteor.call 'sendEmail',
    from: 'All-Court Registrations <postmaster@allcourt.co.nz>',
    to: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'],
    replyTo: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'], 
    subject: 'New user registration on allcourt.co.nz',
    text: "#{fullName}, thank you for registering as a #{role} (#{team}) at #{tournament}.\n\nIf you have any questions, just reply to this message and someone from Tennis Auckland will get back to you as soon as they can.\n\nAll-Court is still under development, so we appreciate your patience, but please let us know if you run into anything unexpected.\n\nWarm regards,\nTennis Auckland"

setAcceptedShifts = ->
  signupId = Session.get 'reg-id'
  signup = Registrants.findOne { _id: signupId }
  Session.set 'accepted-shifts', signup.shifts

associateUserWithTournament = (userId) ->
  setActiveTeam()
  tId = Session.get('active-tournament')._id
  roleName = Session.get('active-role').roleName
  tournamentName = Session.get('active-tournament').tournamentName
  teamId = Session.get('active-team').teamId
  teamName = Session.get('active-team').teamName
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
      sendNotificationEmail tournamentName, roleName, teamName
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
