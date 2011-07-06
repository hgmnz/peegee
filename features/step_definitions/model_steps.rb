When /^I create a (.+)$/ do |class_name|
  @object = class_name.constantize.new
  @result = @object.save
end

Then /^it should have the following error on (.*):$/ do |attribute, error|
  @result.should be_false
  @object.errors[attribute].should == error
end
