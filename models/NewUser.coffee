@models = @models or {}

class models.NewUser
  constructor: (@firstName, @lastName, @email) ->
  password: ''
  fullName: @firstName + ' ' + @lastName
  slug: @firstName + @lastName
