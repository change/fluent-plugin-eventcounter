fluent-plugin-eventcounter
==========================

This plugin is designed to count occurrences of unique values in a specified key and pass them through as counts either as a re-emit or by directly incrementing a specified redis hash.

Installation
------------

OSX/fluentd

    /opt/td-agent/embedded/bin/gem install fluent-plugin-eventcounter

or

    fluent-gem install fluent-plugin-eventcounter


Configuration
-------------

  
    