module AlsoMigrate
  module Base
    
    def self.included(base)
      unless base.respond_to?(:also_migrate)
        base.extend ClassMethods
      end
    end
    
    module ClassMethods
      
      def also_migrate(*args)
        @also_migrate_config ||= []
        @also_migrate_config << {
          :options => args.extract_options!,
          :tables => args.collect(&:to_s)
        }
        self.class_eval do
          class <<self
            attr_reader :also_migrate_config
          end
        end
      end
    end
  end
end