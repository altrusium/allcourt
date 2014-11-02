getRegistrant = (userId) ->
  tId = Session.get('active-tournament')._id
  reg = Registrants.findOne 'tournamentId': tId, 'userId': userId

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
    activeTeam = _.find tournament.teams, (team) ->
      if team.teamId is tId then return team
    Session.set 'active-team', activeTeam

getUserFormValues = (template) ->
  values =
    firstName: template.find('#firstName').value
    lastName: template.find('#lastName').value
    email: template.find('#email').value
    photoFilename: template.find('#photoFilename').value
    gender: template.find('input:radio[name=gender]:checked').value




Template.setupRegistrants.created = ->
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

Template.setupRegistrants.activeTournamentSlug = ->
  Session.get('active-tournament').slug

Template.setupRegistrants.markSelectedRole = ->
  if this.roleId is Session.get('active-role')?.roleId
    return 'selected'

Template.setupRegistrants.markSelectedTeam = ->
  if this.teamId is Session.get('active-team')?.teamId
    return 'selected'

Template.setupRegistrants.roles = ->
  tournament = Session.get 'active-tournament'
  return tournament.roles.sort (a, b) ->
    if a.roleName < b.roleName then return -1
    if a.roleName > b.roleName then return 1
    return 0

Template.setupRegistrants.teams = ->
  roleId = Session.get('active-role')?.roleId
  tournament = Session.get 'active-tournament'
  teams = (team for team in tournament.teams when team.roleId is roleId)

Template.setupRegistrants.firstPreference = ->
  if _.contains Session.get('view-prefs'), '1' then 'checked' else ''

Template.setupRegistrants.secondPreference = ->
  if _.contains Session.get('view-prefs'), '2' then 'checked' else ''

Template.setupRegistrants.thirdPreference = ->
  if _.contains Session.get('view-prefs'), '3' then 'checked' else ''

Template.setupRegistrants.forthPreference = ->
  if _.contains Session.get('view-prefs'), '4' then 'checked' else ''

Template.setupRegistrants.registrantsExist = ->
  show = true
  registrants = Template.setupRegistrants.registrants()
  show = registrants.length > 0
  show

Template.setupRegistrants.registrants = ->
  registrants = []
  tId = Session.get('active-tournament')._id
  teamId = Session.get('active-team')?.teamId
  unless tId and teamId then return []
  Session.get('view-prefs').forEach (pref) ->
    Registrants.find({ tournamentId: tId }).forEach (reg) ->
      if reg.teams[pref-1] is teamId
        registrants.push [reg.userId, reg.isApproved, reg.isTeamLead, reg.isUserProxy]
  users = for reg in registrants
    user = Meteor.users.findOne({ _id: reg[0] })?.profile
    user.id = reg[0]
    user.approvedChecked = !!reg[1]
    user.teamLeadChecked = !!reg[2]
    user.userProxyChecked = !!reg[3]
    user
  _.sortBy users, (user) ->
    user?.fullName

Template.setupRegistrants.registrantCount = ->
  Template.setupRegistrants.registrants().length

Template.setupRegistrants.activeTeamName = ->
  return Session.get('active-team').teamName

Template.setupRegistrants.events
  'change #role': (evnt, template) ->
    forceChange = true
    setActiveRole forceChange
    callback = -> setActiveTeam forceChange
    setTimeout callback, 300

  'change #team': (evnt, template) ->
    forceChange = true
    setActiveTeam forceChange

  'click [data-action=delete]': (evnt, template) ->
    tId = Session.get('active-tournament')._id
    uId = $(evnt.currentTarget).data 'user'
    reg = Registrants.findOne 'tournamentId': tId, 'userId': uId
    teamId = Session.get('active-team').teamId
    Meteor.call 'removeTeamFromRegistrant', reg?._id, teamId
    false

  'click [data-action=makeLead]': (evnt, template) ->
    reg = getRegistrant $(evnt.currentTarget).data 'user'
    reg.isTeamLead = $(evnt.currentTarget).prop 'checked'
    Meteor.call 'updateRegistrant', reg


  'change #viewPreferences [type=checkbox]': (evnt, template) ->
    evnt.preventDefault()
    selected = $('#viewPreferences input:checkbox:checked').map ->
      $(this).val()
    Session.set 'view-prefs', selected.get()

  'click a[data-user-slug]': (evnt, template) ->
    userSlug = $(evnt.currentTarget).data('user-slug')
    tournamentSlug = Session.get('active-tournament').slug
    Router.go 'userPreferences', {
      userSlug: userSlug,
      tournamentSlug: tournamentSlug
    }
    false

