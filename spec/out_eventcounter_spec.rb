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

  describe 'output' do
    let (:conf) {
      %[
        count_key event
        capture_extra_if url
        capture_extra_replace \\?.*$
        emit_only true
      ]
    }
    let (:input) {
      %[{"email": "john.doe@example.com", "timestamp": "1337197600", "smtp-id": "<4FB4041F.6080505@example.com>", "event": "processed", "local_record_id": "11"}
        {"email": "john.doe@example.com", "timestamp": "1337966815", "category": "newuser", "event": "click", "url": "http://example.com?foo=bar&baz=quux", "local_record_id": "72"}
        {"email": "john.doe@example.com", "timestamp": "1337969592", "smtp-id": "<20120525181309.C1A9B40405B3@Example-Mac.local>", "event": "processed", "local_record_id": "72"}
        {"email": "john.doe@example.com", "timestamp": "1337197600", "smtp-id": "<4FB4041F.6080505@example.com>", "event": "processed", "local_record_id": "72"}
        {"email": "john.doe@example.com", "timestamp": "1337966815", "category": "newuser", "event": "click", "url": "http://example.com?blop=spop", "local_record_id": "72"}
        {"email": "john.doe@example.com", "timestamp": "1337969592", "smtp-id": "<20120525181309.C1A9B40405B3@Example-Mac.local>", "event": "processed", "local_record_id": "72"}]
    }
    let (:eventcounter) { Fluent::Test::BufferedOutputTestDriver.new(Fluent::EventCounterOutput.new).configure(conf) }

    it "formats the counts against the provided tag" do
      eventcounter.tag = 'test'
      input.split("\n").each do |line|
        data = JSON.parse line
        eventcounter.emit data, Time.now 
      end
      output = eventcounter.run['test']

      expect(output['processed']).to eq 4
      expect(output['click:http://example.com']).to eq 2
    end
  end
end