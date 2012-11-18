Volunteers = new Meteor.Collection 'volunteers'

Meteor.startup ->
  if Meteor.isClient
    filepicker.setKey 'AOu8DnUQ3Tm6caoisKdpnz'
    Volunteers.remove()

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
}