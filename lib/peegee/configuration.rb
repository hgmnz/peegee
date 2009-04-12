require 'singleton'
module Peegee

  class Configuration
    include Singleton

    # the mappings between tables and indexes, used 
    # for executing the postgres CLUSTER command.
    # The hash maps tables to indexes. You may pass
    # either a 'string' or a :symbol.
    # For example: 
    # cluster_indexes = {:posts => :ix_posts_on_active_and_created_at,
    #                    'users' => 'ix_user_on_active_and_person_id'}
    @cluster_indexes = {}
    attr_accessor :cluster_indexes

    def self.run(&block)
      yield Configuration.instance
    end

  end

end
