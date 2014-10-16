fluent-plugin-eventcounter
==========================

This plugin is designed to count occurrences of unique values in a specified key and pass them through as counts either as a re-emit or by directly incrementing a specified redis hash. As it's a buffered plugin it will write or re-emit at a (tunable) sane pace.

##Installation

OSX/fluentd

    /opt/td-agent/embedded/bin/gem install fluent-plugin-eventcounter

or

    fluent-gem install fluent-plugin-eventcounter


##Configuration

###Parameters

- **count_key** (**required**)
    - The key within the record to count unique instances of *eg. event*

- **input_tag_exclude** (optional)
    - A pattern to exclude from the incoming tag *default: ''*

- **emit_only** (optional) - *boolean*
    - Skip redis and re-emit using emit_to *default: false*
    
- **emit_to** (optional) - *string*
    - Tag to re-emit with *default: debug.events*
    
- **redis_host** (optional) - *string*
    - Host address of the redis server *default: localhost*
    
- **redis_port** (optional)
    - Port of the redis server *default: 6379*
    
- **redis_password** (optional)
    - Password for the redis server *default: nil*
    
- **redis_db_number** (optional)
    - Redis DB *default: 0*

- **redis_output_key** (optional)
    - The key to prefix against the tag *default: ''*

- **capture_extra_if** (optional)
    - An additional field to attach to the captured key *default: nil*
    
- **capture_extra_replace** (optional)
    - A regular expression to replace a portion of the extra capture *default: ''*

- **flush_interval** (optional)
    - Provided from **Fluent::BufferedOutput** time in seconds between flushes *default: 60*


  
