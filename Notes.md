# Notes

## File/photo uploads

For uploading photos to the server, rather than to Amazon S3 via Filepicker.io, consider: https://gist.github.com/3922137

Currently using this approach: http://stackoverflow.com/questions/11790191/meteor-file-uploads


## Session objects

* active-tournament
* active-role
* active-team
* active-user
* user-message
 - type: 'alert && alert-error || alert-info || alert-success'
 - title: String
 - message: String


## Connecting to the production DB

http://stackoverflow.com/questions/11801278/accessing-meteor-production-database

$ meteor mongo 
(use the end of the resulting url in the next statement)
> use allcourt_co_nz


## Date picker

Using Datepicker for Bootstrap from: https://github.com/eternicode/bootstrap-datepicker


## Time picker

Using Timepicker for Bootstrap from:http://jdewit.github.com/bootstrap-timepicker/


## Data model

4 Dec 2012: Learned MongoDB doesn't really like arrays of objects that don't have a unique property. The alternative is to use the positional operator, which can only go one level deep [http://docs.mongodb.org/manual/reference/operators/#update-operators-array]. Unfortunately, Meteor's minimongo doesn't support it yet [https://github.com/meteor/meteor/issues/153]. 

### Tournaments 
- tournamentName: String
- logo: String          ------- todo
- slug: String
- days: Array
  - Date
- roles: Array
  - roleId: UUID
  - roleName: String
- teams: Array
  - roleId: UUID
  - teamId: UUID
  - teamName: String
- shiftDefs: Array
  - shiftDefId: UUID
  - teamId: UUID
  - startTime: Date
  - endTime: Date
  - shiftName: String
- shifts: Array
  - shiftId: UUID
  - shiftDefId: UUID
  - teamId: UUID
  - day: Date
  - startTime: Date
  - endTime: Date
  - count: Number

### Volunteers 
- birthdate
- shirtSize
- notes
- address
- city
- suburb
- postalcode
- country              ------ todo
- homephone
- mobilephone

### Registrants
- userId
- tournamentId
- teams: Array (order significant)
  - UUID (teamId)
- addedBy
- approvedBy
- agreedToTerms       ------- todo?
- isTeamLead
- shifts: Array
  - UUID (shiftId)

### Schedule
- tournamentId
- shiftId
- userId


# TODO

* BUG: When an admin is updating a user's profile who is not yet a volunteer, checking the box doesn't add the volunteer document
* Add tournament logos to tournament document
  - Show logo in top-right when it is active
  - Show small logo in tournament list
* Add a Function field to user (for accreditation badge)
* Add an ApprovedBy field to user (for accreditation)
  - Complete for volunteers who are added by an Admin
  - Add some UI for Admins to approve any user
  - Add a list to show all users for a tournament who are not approved
* When deleting a user, delete all associations in Registrants and Schedule
* Finish volunteer schedule
  - Only show link to volunteers, not other roles
* On Admin's volunteer schedule page, link names to the volunteer's schedule
* Add ability for users to change their password
* Show on user details if their email is verified or not
* Add visible que so Admins will know they are logged in as an Admin
* 