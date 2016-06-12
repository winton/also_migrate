module AlsoMigrate
  module Migrator
    
    def self.included(base)
      unless base.included_modules.include?(InstanceMethods)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :migrate_without_also_migrate, :migrate
          alias_method :migrate, :migrate_with_also_migrate
        end
      end
    end
    
    module InstanceMethods
      
      def migrate_with_also_migrate
        (::AlsoMigrate.configuration || []).each do |config|
          AlsoMigrate.create_tables(config)
        end
      rescue Exception => e
        puts "AlsoMigrate error: #{e.message}"
        puts e.backtrace.join("\n")
      ensure
        migrate_without_also_migrate
      end
      
      module AlsoMigrate
        class <<self
        
          def connection
            ActiveRecord::Base.connection
          end
        
          def create_tables(config)
            [ config[:destination] ].flatten.compact.each do |new_table|
              if !connection.table_exists?(new_table) && connection.table_exists?(config[:source])
                columns = connection.columns(config[:source]).collect(&:name)
                columns -= [ config[:subtract] ].flatten.compact.collect(&:to_s)
                columns.collect! { |col| connection.quote_column_name(col) }
                if config[:indexes]
                  engine =
                    if connection.class.to_s.include?('Mysql')
                      'ENGINE=' + connection.select_one(<<-SQL)['Engine']
                        SHOW TABLE STATUS
                        WHERE Name = '#{config[:source]}'
                      SQL
                    end
                  connection.execute(<<-SQL)
                    CREATE TABLE #{new_table} #{engine}
                    AS SELECT #{columns.join(',')}
                    FROM #{config[:source]}
                    WHERE false;
                  SQL
                  [ config[:indexes] ].flatten.compact.each do |column|
                    connection.add_index(new_table, column)
                  end
                else
                  if connection.class.to_s.include?('SQLite')
                    col_string = connection.columns(config[:source]).collect {|c|
                      "#{c.name} #{c.sql_type}"
                    }.join(', ')
                    connection.execute(<<-SQL)
                      CREATE TABLE #{new_table}
                      (#{col_string})
                    SQL
                  elsif connection.class.to_s.include?('PostgreSQL')
                    # Postgres patch
                    # 1. Valid table creation
                    #   "CREATE TABLE XXX LIKE YYY" is invalid
                    #   "CREATE TABLE XXX ( LIKE YYY )" is a correct one
                    # 2. Add primary key to new table
                    connection.execute(<<-SQL)
                      CREATE TABLE #{new_table}
                      (LIKE #{config[:source]} INCLUDING INDEXES);
                    SQL
                  else
                    connection.execute(<<-SQL)
                      CREATE TABLE #{new_table}
                      LIKE #{config[:source]};
                    SQL
                  end
                end
              end
              if connection.table_exists?(new_table)
                if config[:add] || config[:subtract]
                  columns = connection.columns(new_table).collect(&:name)
                end
                if config[:add]
                  config[:add].each do |column|
                    unless columns.include?(column[0])
                      connection.add_column(*([ new_table ] + column))
                    end
                  end
                end
                if config[:subtract]
                  [ config[:subtract] ].flatten.compact.each do |column|
                    if columns.include?(column)
                      connection.remove_column(new_table, column)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
