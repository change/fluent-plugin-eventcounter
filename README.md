fluent-plugin-eventcounter
==========================

This plugin is designed to count occurrences of unique values in a specified key and pass them through as counts either as a re-emit or by directly incrementing a specified redis hash. As it's a buffered plugin it will write or re-emit at a (tunable) sane pace.

##Example

Given a set of input like

```
important.thing.12086 { 'time': 1413544800, 'event': 'seen', 'user_id': 12345 }
important.thing.1337 { 'time': 1413544890, 'event': 'seen', 'user_id': 1337 }
important.thing.12086 { 'time': 1413544830, 'event': 'liked', 'user_id': 33864 }
important.thing.12086 { 'time': 1413544860, 'event': 'clicked', 'user_id': 12345, url: 'http://example.com/promote?someParam=something' }
important.thing.12086 { 'time': 1413544890, 'event': 'seen', 'user_id': 40555 }
important.thing.12086 { 'time': 1413544860, 'event': 'clicked', 'user_id': 12345, url: 'http://example.com/promote?someParam=somethingElse' }
```

With a conf like

```
<match important.thing.*>
    type eventcounter
    count_key event
    input_tag_exclude important.thing.

    capture_extra_if url
    capture_extra_replace \?.*$

    emit_only true
    emit_tag event.counts
</match>
```

You would get

```
event.counts { 12086: { 'seen': 2, 'liked': 1, 'clicked:http://example.com/12086': 1 } }
event.counts { 1337: { 'seen': 1 } }
```

If the plugin is not set to emit only, and redis is properly configured each of those counts increment a key in a hash specified by `redis_output_key`:`tag` `count_key`

##Installation

OSX

    /opt/td-agent/embedded/bin/gem install fluent-plugin-eventcounter

or

    fluent-gem install fluent-plugin-eventcounter


##Configuration

###Parameters

- **count_key** (**required**)
    - The key within the record to count unique instances of 
        - *eg. event*

- **input_tag_exclude** (optional)
    - A pattern to exclude from the incoming tag 
        - *default: ''*

- **emit_only** (optional) - *boolean*
    - Skip redis and re-emit using emit_to 
        - *default: false*
    
- **emit_to** (optional) - *string*
    - Tag to re-emit with 
        - *default: debug.events*
    
- **redis_host** (optional) - *string*
    - Host address of the redis server 
        - *default: localhost*
    
- **redis_port** (optional)
    - Port of the redis server 
        - *default: 6379*
    
- **redis_password** (optional)
    - Password for the redis server 
        - *default: nil*
    
- **redis_db_number** (optional)
    - Redis DB 
        - *default: 0*

- **redis_output_key** (optional)
    - The key to prefix against the tag 
        - *default: ''*

- **capture_extra_if** (optional)
    - An additional field to attach to the captured key 
        - *default: nil*
    
- **capture_extra_replace** (optional)
    - A regular expression to replace a portion of the extra capture 
        - *default: ''*

- **flush_interval** (optional)
    - Provided from **Fluent::BufferedOutput** time in seconds between flushes 
        - *default: 60*


  
