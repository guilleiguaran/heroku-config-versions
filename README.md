# heroku-config-versions

Configuration management for Heroku environment variables.


## Installation

Add the heroku gem plugin:

    $ heroku plugins:install git://github.com/guilleiguaran/heroku-config-versions.git
    heroku-config-versions installed

## Usage

Every time the `config:set` or `config:unset` are used the last version
of the values are saved in a backup variable.

    $ heroku config
    === gentle-everglades-6844 Config Vars
    DATABASE_URL: postgres://iptvevqivluxcw:WnleruDXZeBlNO5N7j7oogk-aA@ec2-54-197-238-242.compute-1.amazonaws.com:5432/d36tp49719m0p
    
    $ heroku config:set DATABASE_URL=oooooops
    Setting config vars and restarting gentle-everglades-6844... done, v35
    DATABASE_URL: oooooops
    
    $ heroku config
    === gentle-everglades-6844 Config Vars
    DATABASE_URL: oooooops

You can list all the saved versions.

    $ heroku config:versions
    Saved config versions for gentle-everglades-6844:
    20140118053023 (saved on 2014-01-18 05:30:23 -0500)

or see the values saved for a specify version.

    $ heroku config:version 20140118053023
    === gentle-everglades-6844 Config Vars for version 20140118053023
    DATABASE_URL: postgres://iptvevqivluxcw:WnleruDXZeBlNO5N7j7oogk-aA@ec2-54-197-238-242.compute-1.amazonaws.com:5432/d36tp49719m0p

and finally you can roll back the values to a specify version

    $ heroku config
    === gentle-everglades-6844 Config Vars
    DATABASE_URL: oooooops

    $ heroku config:rollback 20140118053023
    Rolling back gentle-everglades-6844 config vars to version 20140118053023... done
    
    $ heroku config
    === gentle-everglades-6844 Config Vars
    DATABASE_URL: postgres://iptvevqivluxcw:WnleruDXZeBlNO5N7j7oogk-aA@ec2-54-197-238-242.compute-1.amazonaws.com:5432/d36tp49719m0p


## How it works

Everytime the set/unset commands are executed a copy of the config vars is saved in the `HEROKU_CONFIG_VERSIONS` variable,
this variable save a hash that use the current date as the key and the current value of the config vars as value. 

The hash is serialized (JSONfied, compressed and Base64 encoded) and hidden from the list of config vars but can be see using the `config:get` command.

## License

MIT License

## Author

Guillermo Iguaran <guilleiguaran@gmail.com>
