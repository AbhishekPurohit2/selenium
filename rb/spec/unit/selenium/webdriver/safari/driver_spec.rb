# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require File.expand_path('../spec_helper', __dir__)

module Selenium
  module WebDriver
    module Safari
      describe Driver do
        let(:service) do
          instance_double(Service, launch: service_manager, executable_path: nil, 'executable_path=': nil,
                                   class: Safari::Service)
        end
        let(:service_manager) { instance_double(ServiceManager, uri: 'http://example.com') }
        let(:valid_response) do
          {status: 200,
           body: {value: {sessionId: 0, capabilities: {browserName: 'safari'}}}.to_json,
           headers: {content_type: 'application/json'}}
        end

        def expect_request(body: nil, endpoint: nil)
          body = (body || {capabilities: {alwaysMatch: {browserName: 'safari'}}}).to_json
          endpoint ||= "#{service_manager.uri}/session"
          stub_request(:post, endpoint).with(body: body).to_return(valid_response)
        end

        before do
          allow(Service).to receive_messages(new: service)
        end

        it 'uses DriverFinder when provided Service without path' do
          expect_request
          allow(DriverFinder).to receive(:results).and_return({})
          options = Options.new

          described_class.new(service: service, options: options)
          expect(DriverFinder).to have_received(:results).with(options, service.class)
        end

        it 'does not use DriverFinder when provided Service with path' do
          expect_request
          allow(service).to receive(:executable_path).and_return('path')
          allow(DriverFinder).to receive(:results).and_return({})

          described_class.new(service: service)
          expect(DriverFinder).not_to have_received(:results)
        end

        it 'does not require any parameters' do
          allow(DriverFinder).to receive(:results).and_return({})
          allow(Platform).to receive(:assert_file)
          allow(Platform).to receive(:assert_executable)
          expect_request

          expect { described_class.new }.not_to raise_exception
        end

        it 'accepts provided Options as sole parameter' do
          allow(DriverFinder).to receive(:results).and_return({})
          allow(Platform).to receive(:assert_file)
          allow(Platform).to receive(:assert_executable)
          opts = {automatic_inspection: true}
          expect_request(body: {capabilities: {alwaysMatch: {browserName: 'safari',
                                                             'safari:automaticInspection': true}}})

          expect { described_class.new(options: Options.new(**opts)) }.not_to raise_exception
        end

        it 'does not accept Options of the wrong class' do
          expect {
            described_class.new(options: Options.chrome)
          }.to raise_exception(ArgumentError, ':options must be an instance of Selenium::WebDriver::Safari::Options')
        end
      end
    end # Safari
  end # WebDriver
end # Selenium
