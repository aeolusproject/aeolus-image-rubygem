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

module Aeolus
  module Image
    module Warehouse
      class Icicle < WarehouseModel
        @bucket_name = 'icicles'

        def initialize(attrs)
          attrs.each do |k,v|
            sym = :attr_accessor
            self.class.send(sym, k.to_sym) unless respond_to?(:"#{k}=")
            send(:"#{k}=", v)
          end
        end

        def packages
          unless @packages
            begin
              package_elems = get_icicle.xpath('icicle/packages/package')
              @packages = package_elems.map { |node| node.attributes['name'].text }
            rescue
              @packages = []
            end
          end
          @packages
        end

        def description
          unless @description
            begin
              @description = get_icicle.xpath('icicle/description').text
            rescue
              @description = []
            end
          end
          @description
        end

        def get_icicle
          unless @icicle_xml
              icicle = Icicle.bucket.objects.find(@uuid) if @uuid
            begin
              @icicle_xml = Nokogiri::XML icicle.first.body
            rescue
              @icicle_xml = Nokogiri::XML '<icicle></icicle>'
            end
          end
          @icicle_xml
        end


      end
    end
  end
end
