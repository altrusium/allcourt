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

getMyTournaments = ->
  results = []
  myId = Meteor.userId()
  myTournamentIds = Registrants.find({ 'userId': myId },
    fields: 'tournamentId': 1).fetch()
  getSortedTournaments().forEach (tournament) ->
    myTournamentIds.forEach (my) ->
      if my.tournamentId is tournament._id
        results.push tournament
  results

getActiveTournaments = ->
  mine = getMyTournaments()
  list = getSortedTournaments()
  result = (t for t in list when new Date(t.days[t.days.length-1]) > new Date())
  result = _.reject result, (tournament) ->
    _.find mine, (myT) ->
      myT._id is tournament._id

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

emptySearchResults = ->
  Session.set 'search-results', null
  $('#search').val ''

setSearchableUserList = ->
  users = Meteor.users.find({}).map (user) ->
    usr = id: user._id, fullName: user.profile.firstName +
      ' ' + user.profile.lastName
  Session.set 'user-list', users
  emptySearchResults()

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value

associateUserWithTournament = (userId) ->
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team').teamId
  signup = Registrants.findOne { tournamentId: tId, userId: userId }
  if signup
    Session.set 'signup-id', signup._id
    # move this to a server-side Method.Call
    Method.call 'addTeamToRegistrant', signup._id, teamId
  else
    # move this to a server-side Method.Call
    Registrants.insert {
      userId: userId,
      teams: [teamId],
      tournamentId: tId,
      addedBy: Meteor.userId()
    }, (err, id) ->
      unless err
        Session.set 'signup-id', id
        Template.userMessages.showMessage
          type: 'info'
          title: 'Success:'
          message: 'User has been successfully registered.'
      else
        Template.userMessages.showMessage
          type: 'error'
          title: 'Sign-up Failed:'
          message: 'An error occurred while registering user. Please refresh
            the browser and let us know if this continues.'




Template.setupRegistrants.created = ->
  setSearchableUserList()
  Session.set 'view-prefs', ['1']

Template.setupRegistrants.rendered = ->
  if Meteor.user().profile.photoFile
    $('.photo-placeholder').removeClass 'empty'
  forceChange = false
  setActiveRole forceChange
  setActiveTeam forceChange

Template.setupRegistrants.isAdmin = ->
  allcourt.isAdmin()

Template.setupRegistrants.linkHelper = ->
  allcourt.getTournamentLinkHelper()

Template.setupRegistrants.activeTournaments = ->
  getActiveTournaments()

Template.setupRegistrants.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupRegistrants.markSelectedTournament = ->
  if this._id is Session.get('active-tournament')._id
    return 'selected=selected'

Template.setupRegistrants.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected=selected'

Template.setupRegistrants.markSelectedTeam = ->
  if this.teamId is Session.get('active-team')?.teamId
    return 'selected=selected'

Template.setupRegistrants.firstPreference = ->
  if _.contains Session.get('view-prefs'), '1' then 'checked' else ''

Template.setupRegistrants.secondPreference = ->
  if _.contains Session.get('view-prefs'), '2' then 'checked' else ''

Template.setupRegistrants.thirdPreference = ->
  if _.contains Session.get('view-prefs'), '3' then 'checked' else ''

Template.setupRegistrants.forthPreference = ->
  if _.contains Session.get('view-prefs'), '4' then 'checked' else ''

Template.setupRegistrants.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.setupRegistrants.roles = ->
  tournament = Session.get 'active-tournament'
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.setupRegistrants.registrantsExist = ->
  show = true
  registrants = Template.setupRegistrants.registrants()
  show = registrants.length > 0
  show = show and not Session.get('search-results')?
  show = show and not Session.get('adding-new-user')?
  show

Template.setupRegistrants.registrants = ->
  registrants = []
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team')?.teamId
  unless tId and teamId then return []
  Session.get('view-prefs').forEach (pref) ->
    Registrants.find({ tournamentId: tId }).forEach (reg) ->
      # if _.contains reg.teams, teamId
      if reg.teams[pref-1] is teamId
        registrants.push [reg.userId, reg.isTeamLead]
  users = for reg in registrants
    user = Meteor.users.findOne({ _id: reg[0] })?.profile
    if reg[1] then user.teamLeadChecked = 'checked'
    user and user.id = reg[0]
    user
  _.sortBy users, (user) ->
    user?.fullName

Template.setupRegistrants.registrantCount = ->
  Template.setupRegistrants.registrants().length

Template.setupRegistrants.searchResults = ->
  Session.get 'search-results'

Template.setupRegistrants.addingNewUser = ->
  Session.get 'adding-new-user'

Template.setupRegistrants.activeTeamName = ->
  return Session.get('active-team').teamName

Template.setupRegistrants.events
  'click #pickPhoto': (evnt, template) ->
    photoHelper.processPhoto()

  'change #role': (evnt, template) ->
    forceChange = true
    setActiveRole forceChange
    setActiveTeam forceChange

  'change #team': (evnt, template) ->
    forceChange = true
    setActiveTeam forceChange

  'click #addTeam': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    rId = Session.get('active-role').roleId
    name = template.find('#teamName').value
    newTeam = roleId: rId, teamId: Meteor.uuid(), teamName: name
    Tournaments.update(tId, $push: 'teams': newTeam)
    $('#teamName').val('').focus()

  'click #addNewUser': (evnt, template) ->
    Session.set 'adding-new-user', true
    false

  'click #cancelAddUser': (evnt, template) ->
    Session.set 'adding-new-user', null
    false

  'click [data-action=delete]': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    uId = $(evnt.currentTarget).data 'user'
    reg = Registrants.findOne 'tournamentId': tId, 'userId': uId
    # TODO: This should be moved to a server-side Method.call
    Registrants.update reg?._id, $pull: teams: Session.get('active-team').teamId
    false

  'click [data-action=makeLead]': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    uId = $(evnt.currentTarget).data 'user'
    checked = $(evnt.currentTarget).prop 'checked'
    reg = Registrants.findOne 'tournamentId': tId, 'userId': uId
    if checked
      Registrants.update reg._id, $set: isTeamLead: true
    else
      Registrants.update reg._id, $unset: isTeamLead: ''

  'click [data-action=register]': (evnt, template) ->
    userId = $(evnt.currentTarget).data 'id'
    associateUserWithTournament userId
    emptySearchResults()
    false

  'keyup #search': (evnt, template) ->
    query = $(evnt.currentTarget).val()
    unless query
      emptySearchResults()
      return
    users = Session.get 'user-list'
    searcher = new Fuse users, keys: ['fullName']
    results = searcher.search query
    Session.set 'search-results', results

  'change #viewPreferences [type=checkbox]': (evnt, template) ->
    evnt.preventDefault()
    selected = $('#viewPreferences input:checkbox:checked').map ->
      $(this).val()
    Session.set 'view-prefs', selected.get()

  'click #addUser': (evnt, template) ->
    userOptions = getUserFormValues template
    if not $('#hasProfileAccess').prop('checked')
      userOptions.email = userOptions.firstName + '.' + userOptions.lastName +
        '@has-no-email.co.nz'
    Meteor.call 'createNewUser', userOptions, (err, id) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: 'Uh oh!',
          message: 'The user was not saved. Reason: ' + err.reason
      else
        associateUserWithTournament id
    Session.set 'adding-new-user', null

  'change #femaleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('male').addClass('female')

  'change #maleGender': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#photoPlaceholder').removeClass('female').addClass('male')

  'click a[data-user-slug]': (evnt, template) ->
    userSlug = $(evnt.currentTarget).data('user-slug')
    tournamentSlug = Session.get('active-tournament').slug
    Router.go 'userPreferences', {
      userSlug: userSlug,
      tournamentSlug: tournamentSlug
    }
    false

  'change #hasProfileAccess': (evnt, template) ->
    if $(evnt.currentTarget).prop('checked')
      $('#email').prop('disabled', false)
    else
      $('#email').prop('disabled', true).val('')

  'change input[name=gender]': (evnt, template) ->
    $('.photo-placeholder').toggleClass 'male female'






