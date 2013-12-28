updatePage = (file) ->
  $('#photoImg').fadeIn(400).attr 'src', allcourt.photoRoot + file.key
  $('#photoPlaceholder').removeClass('empty').find('h4, p, .loading').remove()
  $('#photoFilename').val file.key
  $('#pickPhoto').removeAttr 'disabled'

storePhoto = (file) ->
  filepicker.store file
  , (storedFile) ->
    updatePage storedFile
  , (err) ->
    console.log err
    Template.userMessages.showMessage
      type: 'error',
      title: 'Photo upload error',
      message: 'Please refresh the page and start over.
                We apologise for the inconvenience.'

resizePhoto = (file) ->
  filepicker.convert file,
    {width: 200, height: 200, align: 'faces', format: 'png', fit: 'crop'}
    , (convertedFile) ->
      storePhoto convertedFile
    , (err) ->
      console.log err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Photo upload error',
        message: 'Please refresh the page and start over.
                  We apologise for the inconvenience.'

processPhoto = ->
  filepicker.pick mimetypes: 'image/*'
  , (file) ->
    $('#photoImg').attr 'src', ''
    msg = '<h4 class="wait-message">Processing<br> your<br> photo</h4>
      <img src="/img/loading.gif" class="loading" /><p>Please complete
      the form while you wait.</p>'
    $(msg).appendTo '#photoPlaceholder'
    $('#pickPhoto').attr 'disabled', 'disabled'
    resizePhoto file
  , (err) ->
    console.log err

initializeControls = ->
  $('#pickPhoto').click ->
    processPhoto()

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

sortUsers = (users) ->
  sortedUsers = []
  if users.length
    sortedUsers = _.sortBy users, (user) ->
      user?.fullName
  sortedUsers

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
  user = Meteor.users.findOne _id: id
  Session.set 'active-user', user

setActiveTournament = (id) ->
  tournament = Tournaments.findOne _id: id
  Session.set 'active-tournament', tournament

setActiveRegistration = (id) ->
  registration = Registrants.findOne _id: id
  Session.set 'active-registration', registration

setActiveRole = (forceChange) ->
  activeRole = Session.get('active-role')
  if forceChange or not activeRole
    rId = $('#role option:selected').val()
    tournament = Session.get 'active-tournament'
    activeRole = _.find tournament.roles, (role) ->
      if role.roleId is rId then return role
    Session.set 'active-role', activeRole

setActiveTeam = (forceChange) ->
  activeTeam = Session.get('active-team')
  if forceChange or not activeTeam
    tId = $('#team option:selected').val()
    tournament = Session.get 'active-tournament'
    role = Session.get 'active-role'
    activeTeam = _.find tournament.teams, (team) ->
      if team.teamId is tId then return team
    Session.set 'active-team', activeTeam

getActiveTournaments = ->
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())

getTournamentRegistrations = (userId) ->
  registrants = -> null until registrantsSubscription.ready()
  user = Meteor.users.findOne userId
  registrants = Registrants.find userId: userId
  registrants.map (reg) ->
    t = Tournaments.findOne { _id: reg.tournamentId },
        { fields: days: 0, shifts: 0, shiftDefs: 0 }
    tourney = {
      regId: reg._id,
      id: t._id,
      tournamentSlug: t.slug,
      name: t.tournamentName,
      function: reg.function,
      accessCode: reg.accessCode,
      registrantSlug: user.profile.slug,
      canPrintBadge: user.profile?.photoFilename and reg.accessCode
    }
    teamsRoleId = (teamObj.roleId for teamObj in t.teams \
      when teamObj.teamId is reg.teams[0])[0]
    roleObj = for r in t.roles when r.roleId is teamsRoleId
      id: r.roleId, name: r.roleName
    tourney.role = roleObj[0]
    teamObj = for tTeam in t.teams when tTeam.teamId is reg.teams[0]
      id: tTeam.teamId, name: tTeam.teamName
    if tourney.role then tourney.role.team = teamObj[0]
    tourney

setSearchableUserList = ->
  users = Meteor.users.find({}).map (user) ->
    usr =
      id: user._id
      email: user.profile.email
      isNew: user.profile.isNew
      fullName: user.profile.fullName
      isMale: user.profile.gender is 'male'
      photoFilename: user.profile.photoFilename
      tournaments: getTournamentRegistrations user._id
  Session.set 'user-list', sortUsers users
  emptySearchResults()

getUserFormValues = (template) ->
  user = Session.get('active-user')
  firstName = template.find('#firstName').value
  lastName = template.find('#lastName').value
  values =
    firstName: firstName
    lastName: lastName
    admin: user?.profile?.admin
    isNew: user?.profile?.isNew
    email: user?.profile?.email or firstName.replace(/\s/g, '').toLowerCase()+
      '.'+lastName.replace(/\s/g, '').toLowerCase() + '@has-no-email.co.nz'
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value
    function: template.find('#function').value
    accessCode: template.find('#accessCode').value

associateUserWithTournament = (userId, userOptions) ->
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team').teamId
  registration = Registrants.findOne { tournamentId: tId, userId: userId }
  if registration
    Registrants.update registration._id, {
      $push: {teams: teamId},
      $set: {function: userOptions.function, accessCode: userOptions.accessCode}
    }
    setActiveRegistration registration._id
    setActiveUser userId
  else
    Registrants.insert {
      userId: userId,
      teams: [teamId],
      tournamentId: tId,
      function: userOptions.function,
      accessCode: userOptions.accessCode,
      addedBy: Meteor.userId()
    }, (err, id) ->
      unless err
        setActiveRegistration id
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success:'
          message: 'User has been successfully registered.'
        setActiveUser userId
      else
        Template.userMessages.showMessage
          type: 'error'
          title: 'Sign-up Failed:'
          message: 'An error occurred while registering user. Please refresh
            the browser and let us know if this continues.'

addNewRegistrant = (template) ->
  userOptions = getUserFormValues template
  Meteor.call 'createNewUser', userOptions, (err, id) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The new registrant was not saved successfully. Reason: ' +
          err.reason
    else
      associateUserWithTournament id, userOptions

updateActiveRegistrant = (template) ->
  userOptions = getUserFormValues template
  Meteor.call 'updateUser', userOptions, (err) ->
    if err
      Template.userMessages.showMessage
        type: 'error',
        title: 'Uh oh!',
        message: 'The user information was not updated. Reason: ' + err.reason
    else
      associateUserWithTournament Session.get('active-user')._id, userOptions




Template.accreditation.created = ->
  Session.set 'active-tab', 'find'
  setSearchableUserList()

Template.accreditation.rendered = ->
  initializeControls()

Template.accreditation.photoRoot = ->
  return allcourt.photoRoot

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
    return 'selected=selected'

Template.accreditation.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected=selected'

Template.accreditation.markSelectedTeam = ->
  if this.teamId is Session.get('active-team')?.teamId
    return 'selected=selected'

Template.accreditation.registrationDetails = ->
  unless Session.get('active-user') then return {}
  user = Session.get('active-user').profile
  registration = Session.get('active-registration')
  details = {
    isMale: user.gender is 'male'
    photoFilename: user.photoFilename
    photoPath: allcourt.photoRoot + user.photoFilename
    firstName: user.firstName
    lastName: user.lastName
    function: registration.function
    accessCode: registration.accessCode
  }

Template.accreditation.userSlug = ->
  Session.get('active-user')?.profile?.slug

Template.accreditation.tournamentSlug = ->
  Session.get('active-tournament')?.slug

Template.accreditation.canPrintActiveBadge = ->
  Session.get('active-user')?.profile?.photoFilename and
    Session.get('active-registration').accessCode



Template.accreditation.events =

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    unless query
      emptySearchResults()
      return
    Session.set 'active-team', null
    Session.set 'active-role', null
    Session.set 'active-tournament', null
    users = Session.get 'user-list'
    searcher = new Fuse users, keys: ['fullName']
    results = searcher.search query
    Session.set 'search-results', results
    false

  'click [data-details-link]': (evnt, template) ->
    anchor = $(evnt.currentTarget)
    registrationId = anchor.data('registration-id')
    setActiveRegistration registrationId
    registration = Session.get('active-registration')
    setActiveUser registration.userId
    setActiveTournament registration.tournamentId
    team = (team for team in Session.get('active-tournament').teams \
      when team.teamId is registration.teams[0])[0]
    Session.set 'active-role', roleId: team?.roleId
    Session.set 'active-team', team
    Session.set 'active-tab', 'addEdit'
    false

  'change #tournament': (evnt, template) ->
    id = $('option:selected', evnt.currentTarget).val()
    emptySearchResults()
    Session.set 'active-team', null
    Session.set 'active-role', null
    setActiveTournament id

  'change #role': (evnt, template) ->
    forceChange = true
    setActiveRole forceChange
    setActiveTeam forceChange

  'change #team': (evnt, template) ->
    forceChange = true
    setActiveTeam forceChange

  'change input[name=gender]': (evnt, template) ->
    $('.photo-placeholder').toggleClass 'male female'

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
    if Session.get('active-user')
      updateActiveRegistrant template
    else
      addNewRegistrant template

