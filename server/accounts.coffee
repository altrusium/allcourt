Accounts.onCreateUser (options, user) ->
	user.profile = user.profile || options.profile || {}
	facebook = user.services && user.services.facebook
	google = user.services && user.services.google
	if facebook
		user.profile.firstName = facebook.first_name
		user.profile.lastName = facebook.last_name
		user.profile.email = facebook.email
	if google
		user.profile.firstName = google.given_name
		user.profile.lastName = google.family_name
		user.profile.email = google.email
	user.profile.fullName = user.profile.firstName + ' ' + user.profile.lastName
	user.profile.agreedToTerms = false
	user.profile.type = ''
	user
