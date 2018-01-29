# Jobcoin Mixer

## Getting Started

`git clone` the project

ensure you have `cat .ruby-version` installed, 2.3.4 at the moment

Install bundler to manage application gem dependencies:

`gem install bundler`

Install foreman as a development convenience to launch the worker and web app process in one:

`gem install foreman`

run bundler to install gem dependencies:

`bundle install`

Initialize the DB, SQLite for this demo:

`bundle exec rake db:create`

`bundle exec rake db:schema:load`

The app has two processes, a scheduler and the web app, you can launch both with:

`foreman start`

The server will run locally at:

`http://localhost:5000/`

Individually you can run the rails server:

`rails s -p 5000`

And the scheduler:

`ruby scheduler.rb`

To run the tests:

`bundle exec rake db:create RACK_ENV=test`

`bundle exec rake db:schema:load RACK_ENV=test`

and run the files individually:
