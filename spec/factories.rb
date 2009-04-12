require 'faker'
Factory.define :user do |u|
  u.name { Faker::Name.name }
  u.email { Faker::Internet.email }
  u.login { Faker::Internet.user_name }
  u.password { Faker::Lorem.words.join('') } 
  u.created_at { Time.now }
  u.updated_at { Time.now }
end
