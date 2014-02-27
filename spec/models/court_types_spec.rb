require "spec_helper"

describe Court do
  before(:each) do
    @county = FactoryGirl.create(:court_type, :name => "County Court")
  end

  describe "court types" do
    it "should have at least one court type" do
      @court1 = Court.new(:name => "London Court")
      @court1.should_not be_valid
      @court1.errors.messages[:court_types].should == ["can't be blank. Please select at least one court type."]
    end
  end
end