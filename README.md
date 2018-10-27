# Show me the Weather!

Sample App to display the weather using Yahoo weather API
- Just a initial repo right now, nothing to see yet


## Assumptions
- Only using Yahoo to get weather info, so only handling their style of data.
- Not sure if it's useful to save the weather info, so I just saved it as json (rather than normalised tables).  

## Regrets
- I am used to rspec but went with minitest. Took a while to get used it :)

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