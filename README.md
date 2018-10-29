# Show me the Weather!

Sample App to display the weather using Yahoo weather API

## Requirements
- Rails application to show Yahoo weather information for 2 locations: Sydney and Melbourne.
- The user should be able to select the location of their choice (Sydney or Melbourne).
- After selecting the location, the user should be shown the forecast for the next few days.
- Application should use models that will best represent the data being shown.
- Each time the weather is checked, the results should be saved to the database. The user doesn’t need to be shown the results of previous weather checks, but they should be stored for future features which may be added to the application. 

## Assumptions
- Only using Yahoo to get weather info, so only handling their style of data.
- Not sure if it's useful to save the weather details, so I just saved it as json (rather than normalised tables).  

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install
```

Next, migrate the database and load the seed data:

```
$ rails db:migrate
$ rails db:seed
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```