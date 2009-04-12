class User < ActiveRecord::Base
  has_many :posts#, :foreign_key => 'created_by_id'
end

class Post < ActiveRecord::Base
  belongs_to :created_by, :class_name => User, :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => User, :foreign_key => 'updated_by_id'
end
