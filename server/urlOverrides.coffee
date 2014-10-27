Accounts.urls.resetPassword = (token) ->
  Meteor.absoluteUrl 'resetPassword/' + token

Accounts.urls.verifyEmail = (token) ->
  Meteor.absoluteUrl 'verifyEmail/' + token

Accounts.urls.enrollAccount = (token) ->
  Meteor.absoluteUrl 'enrollAccount/' + token