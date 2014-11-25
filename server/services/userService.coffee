Meteor.methods

  createNewUser: (user) ->
    newUser =
      email: user.email
      profile:
        email: user.email.toLowerCase()
        firstName: user.firstName
        lastName: user.lastName
        fullName: user.firstName + ' ' + user.lastName
        photoFilename: user.photoFilename
        gender: user.gender || 'female'
        slug: user.firstName + user.lastName
        addedBy: user.addedBy || 'self'
        isNew: user.isNew
    newUserId = Accounts.createUser newUser
    modelHelpers.upsertUserRegistration {
      _id: newUserId
      email: newUser.email
      slug: newUser.profile.slug
      gender: newUser.profile.gender
      fullName: newUser.profile.fullName
      photoFilename: newUser.profile.photoFilename
    }
    if user.admin
      Roles.addUsersToRoles newUserId, ['admin']
    if user.proxy
      Roles.addUsersToRoles newUserId, ['proxy']
    newUserId

  updateUser: (user) ->
    firstName = user.firstName
    lastName = user.lastName
    gender = user.gender || 'female'
    fullName = firstName + ' ' + lastName
    slug = firstName.replace(/\s/g,'') + lastName.replace(/\s/g,'')
    Meteor.users.update user._id, $set: profile: {
      email: user.email.toLowerCase()
      firstName: firstName
      lastName: lastName
      fullName: fullName
      photoFilename: user.photoFilename
      gender: gender
      addedBy: user.addedBy
      slug: slug
      isNew: user.isNew
    }
    modelHelpers.upsertUserRegistration {
      _id: user._id
      slug: slug
      email: user.email
      gender: gender
      fullName: fullName
      photoFilename: user.photoFilename
    }
    if user.admin
      Roles.addUsersToRoles user._id, ['admin']
    else
      Roles.removeUsersFromRoles user._id, ['admin']

    if user.proxy
      Roles.addUsersToRoles user._id, ['proxy']
    else
      Roles.removeUsersFromRoles user._id, ['proxy']
    false

  deleteUser: (userId) ->
    Meteor.users.remove userId
    Volunteers.remove userId
    Registrants.remove userId: userId
    Registrations.remove userId

