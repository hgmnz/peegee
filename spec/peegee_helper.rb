require 'active_record'
prefix = defined?(JRUBY_VERSION) ? 'jdbc' : ''
require "active_record/connection_adapters/#{prefix}postgresql_adapter"
require 'yaml'

class PeegeeHelper

  attr_accessor :host, :username, :password

  def initialize
    @path = File.expand_path(File.dirname(__FILE__))
    @host = 'localhost'
    @username = 'peegee'
    @password = 'peegee'
 
    # if you want to overwrite defaults for testing,
    # do it on spec/fixtures/database.yml
    if File.exist?('spec/fixtures/database.yml')
      config = YAML.load(File.open('spec/fixtures/database.yml'))
      @host = config['host']
      @username = config['username']
      @password = config['password']
    end
  end
  
  def setup_pgsql
    #Adapter => http://raa.ruby-lang.org/project/postgres-pr/
    ActiveRecord::Base.establish_connection(
      :adapter => 'postgresql',
      :database => 'peegee_test',
      :username => @username,
      :password => @password,
      :host => @host
    )
    ActiveRecord::Base.logger = Logger.new(active_record_log_file)
  end

  def create_default_tables
    structure = File.open('spec/fixtures/structure.sql') { |f| f.read.chomp }
    structure.split(';').each do |sql|
      ActiveRecord::Base.connection.execute sql unless sql.start_with? '--'
    end
  end

  def configure_peegee
    Peegee::Configuration.run do |config|
      config.cluster_indexes = {
          :users => :users_pkey,
          :posts => :ix_posts_on_status_id
        }
    end
  end
  
  def reset
    setup_pgsql
    create_default_tables
  end

  AR_LOGFILE = 'tmp/active_record.log'
  private
    def active_record_log_file
      FileUtils.mkdir_p 'tmp'
      File.new(AR_LOGFILE, 'a') unless File.exists?(AR_LOGFILE)
    end

end
