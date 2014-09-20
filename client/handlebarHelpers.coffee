UI.registerHelper 'debug', (optionalValue) ->
  console.log 'Current context'
  console.log '----------------------'
  console.log this
  if optionalValue
    console.log 'Value'
    console.log '----------------------'
    console.log optionalValue