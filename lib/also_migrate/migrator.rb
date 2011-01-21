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
        if ::AlsoMigrate.classes
          ::AlsoMigrate.classes.uniq.each do |klass|
            if klass.respond_to?(:also_migrate_config)
              AlsoMigrate.create_tables(klass)
            end
          end
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
        
          def create_tables(klass)
            config = klass.also_migrate_config
            return unless config
            old_table = klass.table_name
            config.each do |config|
              options = config[:options]
              config[:tables].each do |new_table|
                if !connection.table_exists?(new_table) && connection.table_exists?(old_table)
                  columns = connection.columns(old_table).collect(&:name)
                  columns -= options[:subtract].collect(&:to_s)
                  columns.collect! { |col| connection.quote_column_name(col) }
                  indexes = options[:indexes]
                  if indexes
                    engine =
                      if connection.class.to_s.include?('Mysql')
                        'ENGINE=' + connection.select_one(<<-SQL)['Engine']
                          SHOW TABLE STATUS
                          WHERE Name = '#{old_table}'
                        SQL
                      end
                    connection.execute(<<-SQL)
                      CREATE TABLE #{new_table} #{engine}
                      AS SELECT #{columns.join(',')}
                      FROM #{old_table}
                      WHERE false;
                    SQL
                    indexes.each do |column|
                      connection.add_index(new_table, column)
                    end
                  else
                    connection.execute(<<-SQL)
                      CREATE TABLE #{new_table}
                      LIKE #{old_table};
                    SQL
                  end
                end
                if connection.table_exists?(new_table)
                  if options[:add] || options[:subtract]
                    columns = connection.columns(new_table).collect(&:name)
                  end
                  if options[:add]
                    options[:add].each do |column|
                      unless columns.include?(column[0])
                        connection.add_column(*([ new_table ] + column))
                      end
                    end
                  end
                  if options[:subtract]
                    options[:subtract].each do |column|
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
end