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
- dayShifts: DayShift[]

Role
- roleName
- roleShifts: RoleShift[]

RoleShift
- shiftName
- startTime
- endTime

DayShift
- roleName
- activeShifts: boolean[]

Volunteers Collection
- volunteers: Volunteer[]

Volunteer
- vounteerName
- ...

{ // Tournament 
	"tournamentName" : "ASB Classic 2013", 
  "_id" : "00ab3ea9-91b1-4d57-ba48-fa6bc6144c1f",
	"firstDay" : "2012-12-02T11:00:00.000Z", 
	"lastDay" : "2012-12-03T11:00:00.000Z", 
  "roles" : 
  [
  	{
  		"roleName": "Drivers",
  		"roleShifts":
  		[
  			{
		  		"shiftName": "AM1",
		  		"startTime": "5:00 AM",
		  		"endTime": "9:00 PM"
  			},
  			{
		  		"shiftName": "AM2",
		  		"startTime": "9:00 AM",
		  		"endTime": "1:00 PM"
  			},
  			{
		  		"shiftName": "PM1",
		  		"startTime": "1:00 PM",
		  		"endTime": "6:00 PM"
  			},
  			{
		  		"shiftName": "PM2",
		  		"startTime": "6:00 PM",
		  		"endTime": "12:00 AM"
  			}
  		]
  	},
  	{
  		"roleName": "Marshalls",
  		"roleShifts":
  		[
  			{
		  		"shiftName": "AM1",
		  		"startTime": "9:00 AM",
		  		"endTime": "1:00 PM"
  			},
  			{
		  		"shiftName": "PM1",
		  		"startTime": "1:00 PM",
		  		"endTime": "6:00 PM"
  			},
  			{
		  		"shiftName": "PM2",
		  		"startTime": "6:00 PM",
		  		"endTime": "12:00 AM"
  			}
  		]
  	}
  ], 
	"days" : 
	[ 	
	  { 	
	  	"date" : "2012-12-02T11:00:00.000Z", 	
	  	"dayShifts" : 
	  	[
	  		{
	  			"roleName": "Drivers",
	  			"activeShifts": 
	  			[
	  				true,
	  				true,
	  				false,
	  				false
	  			]
	  		},
	  		{
	  			"roleName": "Marshalls",
	  			"activeShifts": 
	  			[
	  				true,
	  				true,
	  				false
	  			]
	  		}
	  	] 
	  }, 	
	  { 	
	  	"date" : "2012-12-03T11:00:00.000Z", 	
	  	"dayShifts" : 
	  	[
	  		{
	  			"roleName": "Drivers",
	  			"activeShifts": 
	  			[
	  				true,
	  				true,
	  				false,
	  				false
	  			]
	  		},
	  		{
	  			"roleName": "Marshalls",
	  			"activeShifts": 
	  			[
	  				true,
	  				true,
	  				false
	  			]
	  		}
	  	] 
	  } 
  ]
}







