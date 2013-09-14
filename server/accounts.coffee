Accounts.onCreateUser (options, user) ->
	user.profile = {}
	if user.services && user.services.facebook
		user.profile.firstName = user.services.facebook.first_name
		user.profile.lastName = user.services.facebook.last_name
		user.profile.email = user.services.facebook.email
	if user.services && user.services.google
		user.profile.firstName = user.services.google.given_name
		user.profile.lastName = user.services.google.family_name
		user.profile.email = user.services.google.email
	user.profile.agreedToTerms = false
	user.profile.type = ''
	user
