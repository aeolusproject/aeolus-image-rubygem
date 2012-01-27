require 'spec_helper'

module Aeolus
  module Image
    module Factory
      describe TargetImage do
        it "should return nil when a builder is found but operation is push" do
          @builder = mock(Builder, :operation => "push")
          Builder.stub!(:find).and_return(@builder)
          TargetImage.status("1234").should == nil
        end

        it "should return a builder when a builder is found and operation is build" do
          @builder = mock(Builder, :operation => "build", :status => "BUILDING")
          Builder.stub!(:find).and_return(@builder)
          TargetImage.status("1234").should == "BUILDING"
        end
      end
    end
  end
end