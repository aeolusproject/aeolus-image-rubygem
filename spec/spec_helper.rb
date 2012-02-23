#   Copyright 2011 Red Hat, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib/aeolus_image/model/"))

require 'rubygems'
require File.join(File.dirname(__FILE__), '../lib', 'aeolus_image')
require 'vcr_setup'

require 'rspec'
require 'warehouse/warehouse_client'
require 'warehouse/warehouse_model'
require 'warehouse/image'
require 'warehouse/image_build'
require 'warehouse/target_image'
require 'warehouse/provider_image'
require 'warehouse/template'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
  config.before(:all) do
#    Aeolus::Image::BaseCommand.class_eval do
#      def load_config
#        YAML::load(File.open(File.join(File.dirname(__FILE__), "/../examples/aeolus-cli")))
#      end
#    end
  end
end
