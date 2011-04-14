module AlsoMigrate
  class Migrator
    def self.connection
      ActiveRecord::Base.connection
    end
    
    def self.migrate(config = AlsoMigrate.configuration)
      begin
        (config || []).each do |c|
          create_tables(c)
        end
      rescue Exception => e
        puts "AlsoMigrate error: #{e.message}"
        puts e.backtrace.join("\n")
      ensure
      end
    end
    
    def self.create_tables(config)
      [ config[:destination] ].flatten.compact.each do |new_table|
        if !connection.table_exists?(new_table) && connection.table_exists?(config[:source])
          columns = connection.columns(config[:source]).collect(&:name)
          columns -= [ config[:subtract] ].flatten.compact.collect(&:to_s)
          columns.collect! { |col| connection.quote_column_name(col) }
          if config[:indexes]
            if connection.class.to_s.include?('Mysql')
              engine = 'ENGINE=' + connection.select_one(<<-SQL)['Engine']
              SHOW TABLE STATUS
              WHERE Name = '#{config[:source]}'
              SQL
              connection.execute(<<-SQL)
              CREATE TABLE #{new_table} #{engine}
              AS SELECT #{columns.join(',')}
              FROM #{config[:source]}
              WHERE false;
              SQL
            end
            [ config[:indexes] ].flatten.compact.each do |column|
              connection.add_index(new_table, column)
            end
          else
            if connection.class.to_s.include?('SQLite')
              col_string = connection.columns(old_table).collect {|c|
                "#{c.name} #{c.sql_type}"
              }.join(', ')
              connection.execute(<<-SQL)
              CREATE TABLE #{new_table}
              (#{col_string})
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
