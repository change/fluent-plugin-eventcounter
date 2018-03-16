require 'spec_helper'

describe Fluent::Plugin::EventCounterOutput do
  include Fluent::Test::Helpers

  before { Fluent::Test.setup }


  describe '#format' do
    context 'no capture extra is set' do
      let (:conf) {
        %[
          count_key event
        ]
      }
      let (:eventcounter) { Fluent::Test::Driver::Output.new(Fluent::Plugin::EventCounterOutput).configure(conf) }
      context 'the input contains the count key' do
        it 'produces the expected output' do
          eventcounter.run(default_tag: 'something') do
            eventcounter.feed(event_time, { 'event' => 'the_event'})
          end
          expect(eventcounter.formatted).to eq([['something', 'the_event'].to_json + "\n"])
        end
      end

      context 'the input does not contain the count key' do
        it 'does not add it to the buffer' do
          eventcounter.run(default_tag: 'something') do
            eventcounter.feed(event_time, { 'not_an_event' => 'the_event'} )
          end
          expect(eventcounter.formatted).to eq([''])
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

      let (:eventcounter) { Fluent::Test::Driver::Output.new(Fluent::Plugin::EventCounterOutput).configure(conf) }

      context 'the provided data contains the capture extra' do
        it 'captures the count_key:capture_extra' do
          eventcounter.run(default_tag: 'something') do
            eventcounter.feed(event_time, { 'event' => 'the_event', 'url' => 'http://www.example.com?someparam=somethingElse'})
          end
          expect(eventcounter.formatted).to eq([['something', 'the_event:http://www.example.com?someparam=somethingElse'].to_json + "\n"])
        end
        context 'with capture_extra_replace' do
          let (:conf) {
            %[
              count_key event
              capture_extra_if url
              capture_extra_replace \\?.*$
            ]
          }
          let (:eventcounter) { Fluent::Test::Driver::Output.new(Fluent::Plugin::EventCounterOutput).configure(conf) }

          it 'transforms the capture_extra with the provided regex' do
            eventcounter.run(default_tag: 'something') do
              eventcounter.feed(event_time, { 'event' => 'the_event', 'url' => 'http://www.example.com?someparam=somethingElse'})
            end
            expect(eventcounter.formatted).to eq([['something', 'the_event:http://www.example.com'].to_json + "\n"])
          end
        end
      end
      context 'the provided data DOES NOT contain the capture extra' do
        it 'captures only the count_key' do
          eventcounter.run(default_tag: 'something') do
            eventcounter.feed(event_time, { 'event' => 'the_event', 'not_a_url' => 'http://www.example.com'})
          end
          expect(eventcounter.formatted).to eq([['something', 'the_event'].to_json + "\n"])
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
    let (:eventcounter) { Fluent::Test::Driver::Output.new(Fluent::Plugin::EventCounterOutput).configure(conf) }

    it "formats the counts against the provided tag" do
      eventcounter.run(default_tag: 'test') do
        input.split("\n").each do |line|
          data = JSON.parse line
          eventcounter.feed event_time, data
        end
      end
      output = eventcounter.events.map {|e| e.last}.first

      expect(output['test']['processed']).to eq 4
      expect(output['test']['click:http://example.com']).to eq 2
    end
  end
end
