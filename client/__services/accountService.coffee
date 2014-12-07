@services = @services or {}

makeSlug = (first, last) ->
  first.replace(' ','') + last.replace(' ','')

services.accountService =

  createNewUser: (newUser) ->
    options =
      email: newUser.email
      username: newUser.email
      password: newUser.password
      profile:
        email: newUser.email
        firstName: newUser.firstName
        lastName: newUser.lastName
        fullName: newUser.fullName
        slug: makeSlug newUser.firstName, newUser.lastName

    Accounts.createUser options, (err) ->
      if err
        Template.userMessages.showMessage
          type: 'error',
          title: err.reason || 'Registration unsuccessful.',
          message: err.details || 'Unable to save your registration. Please try
            again and let us know if you continue to experience issues.'
      else
        Meteor.call 'sendVerificationEmail', Meteor.userId()
        Template.userMessages.showMessage
          type: 'info',
          title: 'Success!',
          message: 'Please check your email so you can verify your email address.'
        Meteor.call 'addRegistration', newUser

  returnsOpposite: (start) ->
    return !!!start
