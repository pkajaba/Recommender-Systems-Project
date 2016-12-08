# Jokes Recommendations
This is simple recommend system which recommends jokes.
Jokes were obtained from [funny.sk][1].
Application is currently deployed [here][2].

##### Table of Contents
* [System dependencies](System Dependencies) 
* [Database creation](Database creation)
* [Database initialization](Database initialization)
* [Deployment instructions](Deployment instructions)

#### Docker setup
First replace config/database.yml with database-docker.yml. For running in docker containers you have to first run `docker-compose up`. After this you have to also setup database in container this way (in another terminal):
`docker-compose run web rake db:migrate`. You can run any ruby related commands this way.

#### System Dependencies
You need these packages:
`ruby
postgresql
postgresql-devel
postgresql-server
`
#### Database creation
Once you have installed postgresql you have to init db first.
It can be done with this command `/usr/bin/postgresql-setup --initdb`.
After this you have to start postgresql server. On systems with systemd it can be done with
`systemctl enable postgresql && systemctl start postgresql`.
Project is configured to use default database `postgres`.
#### Database initialization
After enabling database you have create schema it can be done with `rails db:schema:load`.
You can also seed database with some jokes `rake db:seed `.
#### Deployment instructions
Application is deployed on [Heroku][2]. For local setup use `rails server`.

[1]: www.funny.sk
[2]: http://agile-meadow-53738.herokuapp.com
