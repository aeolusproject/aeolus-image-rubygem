require 'spec_helper'

module Aeolus
  module Image
    module Factory
      describe ProviderImage do
        it "should return nil when a builder is found but operation is build" do
          @builder = mock(Builder, :operation => "build", :status => "PUSHING")
          Builder.stub!(:find).and_return(@builder)
          ProviderImage.status("1234").should == nil
        end

        it "should return a builder when a builder is found and operation is push" do
          @builder = mock(Builder, :operation => "push", :status => "PUSHING")
          Builder.stub!(:find).and_return(@builder)
          ProviderImage.status("1234").should == "PUSHING"
        end
      end
    end
  end
end