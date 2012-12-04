Volunteers = new Meteor.Collection 'volunteers'
Tournaments = new Meteor.Collection 'tournaments'

Meteor.startup ->
  if Meteor.isClient
    filepicker.setKey 'AOu8DnUQ3Tm6caoisKdpnz'

Meteor.methods {
  saveVolunteer: (options) ->
    return Volunteers.insert {
      firstname: options.firstname,
      lastname: options.lastname,
      address: options.address,
      suburb: options.suburb,
      postalcode: options.postalcode,
      email: options.email,
      homephone: options.homephone,
      workphone: options.workphone,
      mobilephone: options.mobilephone,
      birthdate: options.birthdate,
      notes: options.notes,
      asbshirtsize: options.asbshirtsize,
      heinekenshirtsize: options.heinekenshirtsize,
      photo: options.photo
    }
  saveTournament: (options, callback) ->
    return Tournaments.insert {
      tournamentName: options.tournamentName,
      days: options.days,
      roles: [],
      shifts: []
    }, callback
  addShift: (options, callback) ->
    tournament = Tournaments.findOne options.tournamentId
    savedRole = role for role in tournament.roles when role.roleName is options.roleName
    roleShifts = savedRole.roleShifts
    roleShifts.push 
      shiftName: options.shiftName
      startTime: options.startTime
      endTime: options.endTime
    roleShifts.sort (shift1, shift2) ->
      time1 = moment(shift1.startTime)
      time2 = moment(shift2.startTime)
      return if time1.diff(time2) < 0 then -1 else 1
    Tournaments.update {_id: options.tournamentId, 'roles.roleName': options.roleName},
      $set: 'roles.$.roleShifts': roleShifts
}