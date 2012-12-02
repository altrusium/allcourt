Notes
----------

## File/photo uploads

For uploading photos to the server, rather than to Amazon S3 via Filepicker.io, consider: https://gist.github.com/3922137

Currently using this approach: http://stackoverflow.com/questions/11790191/meteor-file-uploads

TODO: Move the base URL for the photos out of the shifty.html file


## Page navigation

Using Meteor Router from: https://github.com/tmeasday/meteor-router
Which uses Page.js: http://visionmedia.github.com/page.js/


## Date picker

Using Datepicker for Bootstrap from: https://github.com/eternicode/bootstrap-datepicker
Really like how I'm initialising the datepicker in the Template.templateName.rendered event


## Time picker

Using Timepicker for Bootstrap from:http://jdewit.github.com/bootstrap-timepicker/


## Data model

Tournaments Collection
- tournaments: tournament[]

Tournament
- tournamentName
- firstDay
- lastDay
- days: Day[]
- roles: Role[]

Day
- date
- Shifts[]

Role
- roleName

Shift
- roleId
- shiftName
- startTime
- endTime

Volunteers Collection
- volunteers: Volunteer[]

Volunteer
- vounteerName
- ...







