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

4 Dec 2012: Learned MongoDB doesn't really like arrays of objects that don't have a unique property. The alternative is to use the positional operator, which can only go one level deep [http://docs.mongodb.org/manual/reference/operators/#update-operators-array]. Also, Meteor's minimongo doesn't support it yet [https://github.com/meteor/meteor/issues/153]. 

Tournaments Collection
- tournaments: Tournament

Tournament
- tournamentName: String
- days: Array
  - Date
- roles: Array
  - roleId: UUID
  - roleName: String
- shiftDefs: Array
  - shiftDefId: UUID
  - roleId: UUID
  - shiftName: String
  - startDate: Date
  - endDate: Date
- shifts: Array
  - active: Boolean
  - startDate: Date
  - endDate: Date
  - day: Date
  - roleId: UUID
  - shiftId: UUID
  - shiftDefId: UUID




Volunteers Collection
- volunteers: Volunteer[]

Volunteer
- firstname
- lastname
- gender
- birthdate
- shirtSize
- photo
- notes

- address
- city
- suburb
- postalcode
- country
- primaryEmail
- secondaryEmail
- homephone
- workphone
- mobilephone

- confirmedTournaments: Array
  - UUID

- preferredRoles: Array
  - role UUID



