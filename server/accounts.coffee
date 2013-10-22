Accounts.onCreateUser (options, user) ->
	user.profile = user.profile || options.profile || {}
	facebook = user.services && user.services.facebook
	google = user.services && user.services.google
	if facebook
		user.profile.email = facebook.email
		user.profile.firstName = facebook.first_name
		user.profile.lastName = facebook.last_name
		user.profile.gender = facebook.gender
	if google
		user.profile.email = google.email
		user.profile.firstName = google.given_name
		user.profile.lastName = google.family_name
		user.profile.gender = google.gender
	user.profile.fullName = user.profile.firstName + ' ' + user.profile.lastName
	user.profile.slug = user.profile.firstName + user.profile.lastName
	user.profile.gender = user.profile.gender || 'female'
	user.profile.role = user.profile.role || ''
	user
