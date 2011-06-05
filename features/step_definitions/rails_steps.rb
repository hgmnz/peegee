When /^I add the "([^"]*)" gem from this project as a dependency$/ do |gem_name|
  in_current_dir do
    append_to_file('Gemfile', %{\ngem "#{gem_name}", path => #{PROJECT_ROOT}})
  end
end

Given /^I create and configure the "(\w+)" rails app$/ do |name|
  Given %{I run `rails new #{name} --database=postgresql -J -T -G`}
  And %{I cd to "peegee_test"}

  database_config = <<-CONFIG
development: &default
  adapter: postgresql
  encoding: unicode
  database: peegee_development
  pool: 5
  min_messages: warning
test:
  << default
  database: peegee_test

  CONFIG
  in_current_dir do
    File.open('config/database.yml', 'w') { |file| file.write(database_config) }
  end
  And %{I add the "peegee" gem from this project as a dependency}
  And %{I run `bundle install`}
  And %{I run `bundle exec rake db:drop:all db:create:all`}
end
