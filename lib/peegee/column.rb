module Peegee
  class Column

    attr_accessor :name, :type, :table_name, :number, :not_null, :has_default, :default
    def initialize(opts)
      @name = opts[:name]
      @type = opts[:type]
      @table_name = opts[:table_name]
      @number = opts[:number]
      @not_null = opts[:not_null]
      @has_default = opts[:has_default]
      @default = opts[:default]
    end

  end
end
