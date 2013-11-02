Template.volunteerDetailsPartial.details = ->
  id = Meteor.userId()
  volunteer = Volunteers.findOne id
  volunteer


