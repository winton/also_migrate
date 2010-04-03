module AlsoMigrate
  module Migrator
    
    def self.included(base)
      unless base.respond_to?(:migrate_with_also_migrate)
        base.send :include, InstanceMethods
        base.class_eval do
          alias_method :migrate_without_also_migrate, :migrate
          alias_method :migrate, :migrate_with_also_migrate
        end
      end
    end
    
    module InstanceMethods
      
      def migrate_with_also_migrate
        Object.subclasses_of(ActiveRecord::Base).each do |klass|
          if klass.respond_to?(:also_migrate_config)
            AlsoMigrate.create_tables(klass)
          end
        end
        migrate_without_also_migrate
      end
      
      module AlsoMigrate
        class <<self
        
          def connection
            ActiveRecord::Base.connection
          end
        
          def create_tables(klass)
            config = klass.also_migrate_config
            $log.info config.inspect
            old_table = klass.table_name
            config.each do |config|
              options = config[:options]
              config[:tables].each do |new_table|
                if !connection.table_exists?(new_table) && connection.table_exists?(old_table)
                  columns = connection.columns(old_table).collect(&:name)
                  columns -= (options[:ignore] || []).collect(&:to_s)
                  columns.collect! { |col| connection.quote_column_name(col) }
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
                  indexes = options[:indexes]
                  $log.info indexes.inspect
                  indexes ||= indexed_columns(old_table)
                  $log.info old_table.inspect
                  $log.info indexes.inspect
                  indexes.each do |column|
                    connection.add_index(new_table, column)
                  end
                end
              end
            end
          end

          def indexed_columns(table_name)
            # MySQL
            if connection.class.to_s.include?('Mysql')
              index_query = "SHOW INDEX FROM #{table_name}"
              connection.select_all(index_query).collect do |r|
                r["Column_name"]
              end
            # PostgreSQL
            # http://stackoverflow.com/questions/2204058/show-which-columns-an-index-is-on-in-postgresql/2213199
            elsif connection.class.to_s.include?('PostgreSQL')
              index_query = <<-SQL
                select
                  t.relname as table_name,
                  i.relname as index_name,
                  a.attname as column_name
                from
                  pg_class t,
                  pg_class i,
                  pg_index ix,
                  pg_attribute a
                where
                  t.oid = ix.indrelid
                  and i.oid = ix.indexrelid
                  and a.attrelid = t.oid
                  and a.attnum = ANY(ix.indkey)
                  and t.relkind = 'r'
                  and t.relname = '#{table_name}'
                order by
                  t.relname,
                  i.relname
              SQL
              connection.select_all(index_query).collect do |r|
                r["column_name"]
              end
            else
              raise 'AlsoMigrate does not support this database adapter'
            end
          end
        end
      end
    end
  end
end