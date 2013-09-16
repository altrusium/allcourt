Template.setupNewUser.events

	'click #saveRole': (evnt, template) ->
		userType = template.find('#userType').value
		if userType is 'blank'
			Template.userMessages.showMessage
				type: 'error',
				title: 'Must choose a role.',
				message: 'Please select a role to continue.'
		else
			Meteor.users.update { _id: Meteor.userId() }, { $set: { 'profile.type': userType } }, (err) ->
				if err
					Template.userMessages.showMessage
						type: 'error',
						title: 'Profile not updated.',
						message: 'Unexpected error. Please try again and let us know if you keep seeing this.'
				else
					Meteor.call 'sendEmail',
						from: 'All-Court Registrations <postmaster@allcourt.co.nz>',
						to: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'],
						replyTo: [Meteor.user().profile.email, 'Tennis Auckland <volunteers@tennisauckland.co.nz>'], 
						bcc: 'locksmithdon@gmail.com',
						subject: 'New user registration on allcourt.co.nz',
						text: "#{Meteor.user().profile.firstName}, thank you for your #{Meteor.user().profile.type} registration at All-Court.\n\nIf you have any questions, just reply to this message and someone from Tennis Auckland will get back to you as soon as they can.\n\nAll-Court is still under development, but in the near future (before the tournaments begin) you'll be able to use it to help with your involvement in the tournaments.\n\nWarm regards,\nTennis Auckland"

	'change #userType': (evnt, template) ->
		if template.find('#userType').value isnt 'blank'
			Template.userMessages.clear()