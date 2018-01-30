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

`bundle exec ruby test/mix_request_state_test.rb`

and

`bundle exec ruby test/mix_request_test.rb`

## Methodology

### Components

1. the web app to receive requests, which creates a db row

2. the scheduler (monitor_task) which monitors the network for deposits at the addresses we've provided

3. a scheduler task (transfer_task) which transfers the deposits to the house account

4. a scheduler task (distribution_task) which transfers from ther house account to the distribution addresses provided by the user. This task will only fire if there are five pending transfers (MixRequest::TRANSFER_THRESHOLD).

Having read more about mixer implementations it seems very difficult to fully obscure the transaction without the use of multiple mixers or a 'CoinJoin' schema which is mostly decentralized.

That said, a few steps could be taken here to help obfuscate the transfers. I believe if a disproportionately
large incoming deposit is accepted compared to the rest of the deposits in the batch it'll hurt anonymity. Keeping deposit sizes uniform seems important to me.

### Note

I wanted to minimize dependencies so I used sqlite, but in the real world I would
likely avoid using a database entirely and do everything in memory. At the very
least once transactions moved into the 'distributed' state the addresses could be nulled out.
