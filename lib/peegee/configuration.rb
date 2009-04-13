require 'singleton'
module Peegee

  class Configuration
    include Singleton

    # The mappings between tables and indexes, used 
    # for executing Peegee's implementation of the Postgres CLUSTER command.
    # The hash maps tables to indexes. You may pass
    # either a 'string' or a :symbol.
    # For example: 
    # <tt>cluster_indexes = {:posts => :ix_posts_on_active_and_created_at,
    #                    'users' => 'ix_user_on_active_and_person_id'}</tt>
    @cluster_indexes = {}
    attr_accessor :cluster_indexes

    def self.run(&block)
      yield Configuration.instance
    end

  end

end
