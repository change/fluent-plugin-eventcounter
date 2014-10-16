require 'spec_helper'

describe Fluent::EventCounterOutput do
  before { Fluent::Test.setup }
  

  describe '#format' do
    context 'no capture extra is set' do
      let (:conf) {
        %[
          count_key event
        ]
      }
      let (:eventcounter) { Fluent::Test::BufferedOutputTestDriver.new(Fluent::EventCounterOutput.new).configure(conf) }
      context 'the input contains the count key' do
        it 'produces the expected output' do
          eventcounter.tag = 'something'
          eventcounter.emit( { 'event' => 'the_event'}, Time.now )
          eventcounter.expect_format ['something', 'the_event'].to_json + "\n"
          eventcounter.run
        end
      end

      context 'the input does not contain the count key' do
        it 'does not add it to the buffer' do
          eventcounter.tag = 'something'
          eventcounter.emit( { 'not_an_event' => 'the_event'}, Time.now )
          eventcounter.expect_format ''
          eventcounter.run
        end
      end
    end
    context 'capture_extra_if is set' do
      let (:conf) {
        %[
          count_key event
          capture_extra_if url
        ]
      }
      
      let (:eventcounter) { Fluent::Test::BufferedOutputTestDriver.new(Fluent::EventCounterOutput.new).configure(conf) }

      context 'the provided data contains the capture extra' do
        it 'captures the count_key:capture_extra' do
          eventcounter.tag = 'something'
          eventcounter.emit( { 'event' => 'the_event', 'url' => 'http://www.example.com?someparam=somethingElse'}, Time.now )
          eventcounter.expect_format ['something', 'the_event:http://www.example.com?someparam=somethingElse'].to_json + "\n"
          eventcounter.run
        end
        context 'with capture_extra_replace' do
          let (:conf) { 
            %[
              count_key event
              capture_extra_if url
              capture_extra_replace \\?.*$
            ]
          }
          let (:eventcounter) { Fluent::Test::BufferedOutputTestDriver.new(Fluent::EventCounterOutput.new).configure(conf) }

          it 'transforms the capture_extra with the provided regex' do
            eventcounter.tag = 'something'
            eventcounter.emit( { 'event' => 'the_event', 'url' => 'http://www.example.com?someparam=somethingElse'}, Time.now )
            eventcounter.expect_format ['something', 'the_event:http://www.example.com'].to_json + "\n"
            eventcounter.run
          end
        end
      end
      context 'the provided data DOES NOT contain the capture extra' do
        it 'captures only the count_key' do
          eventcounter.tag = 'something'
          eventcounter.emit( { 'event' => 'the_event', 'not_a_url' => 'http://www.example.com'}, Time.now )
          eventcounter.expect_format ['something', 'the_event'].to_json + "\n"
          eventcounter.run
        end
      end
    end
  end
end