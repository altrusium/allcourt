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

OLD:

Tournament
- tournamentName
- firstDay
- lastDay
- days: Day[]
- roles: Role[]
Day
- date: Date
- dayShifts: DayShifts[]
Role
- roleName: String
- roleShifts: RoleShift[]
RoleShift
- shiftName
- startTime
- endTime
DayShifts
- roleName:
- activeShifts: boolean[]

NEW:

Tournament
- tournamentName: String
- days: Array
  - date: Date
- roles: Array
  - roleId: UUID
  - roleName: String
- shifts: Array
  - shiftDefId: UUID
  - day: Date
  - active: Boolean
- shiftDefs: Array
  - shiftDefId: UUID
  - roleId: UUID
  - shiftName: String
  - startDate: Date
  - endDate: Date




Volunteers Collection
- volunteers: Volunteer[]

Volunteer
- firstname
- lastname
- address
- suburb
- postalcode
- email
- homephone
- workphone
- mobilephone
- birthdate
- notes
- asbshirtsize
- heinekenshirtsize
- photo

OLD:

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
  					// Note: When a roleShift is deleted, the associated index in the
  					// activeShift, and the volunteerShift must also be deleted.
  					// When a roleShift is added, rather than being 'pushed', it must
  					// be added to a roleShifts array so it can be sorted before being
  					// added wholesale to the roleShifts property. This will keep every-
  					// thing internally aligned.
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
	  								// When an activeShift is deactivated, the associated
	  								// volunteerShift must be removed to maintain consistency
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

NEW:

{ // Tournament 
	"tournamentName" : "ASB Classic 2013", 
  "_id" : "00ab3ea9-91b1-4d57-ba48-fa6bc6144c1f",
	"firstDay" : "2012-12-02T11:00:00.000Z", 
	"lastDay" : "2012-12-03T11:00:00.000Z", 
  "roles" : 
 	{
  	"Drivers":
  	{
  		"roleShifts":
  					// Note: When a roleShift is deleted, the associated index in the
  					// activeShift, and the volunteerShift must also be deleted.
  					// When a roleShift is added, rather than being 'pushed', it must
  					// be added to a roleShifts array so it can be sorted before being
  					// added wholesale to the roleShifts property. This will keep every-
  					// thing internally aligned.
 			{
	  		"AM1":
	  		{
		  		"startTime": "5:00 AM",
		  		"endTime": "9:00 PM"
  			},
	  		"AM2":
	  		{
		  		"startTime": "9:00 AM",
		  		"endTime": "1:00 PM"
  			},
	  		"PM1":
	  		{
		  		"startTime": "1:00 PM",
		  		"endTime": "6:00 PM"
  			},
	  		"PM2":
	  		{
		  		"startTime": "6:00 PM",
		  		"endTime": "12:00 AM"
  			}
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
	  								// When an activeShift is deactivated, the associated
	  								// volunteerShift must be removed to maintain consistency
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




