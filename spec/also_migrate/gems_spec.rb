require 'spec_helper'

describe AlsoMigrate::Gems do
  
  before(:each) do
    @old_config = AlsoMigrate::Gems.config
    
    AlsoMigrate::Gems.config.gemspec = "#{$root}/spec/fixtures/gemspec.yml"
    AlsoMigrate::Gems.config.gemsets = [
      "#{$root}/spec/fixtures/gemsets.yml"
    ]
    AlsoMigrate::Gems.config.warn = true
    
    AlsoMigrate::Gems.gemspec true
    AlsoMigrate::Gems.gemset = nil
  end
  
  after(:each) do
    AlsoMigrate::Gems.config = @old_config
  end
  
  describe :activate do
    it "should activate gems" do
      AlsoMigrate::Gems.stub!(:gem)
      AlsoMigrate::Gems.should_receive(:gem).with('rspec', '=1.3.1')
      AlsoMigrate::Gems.should_receive(:gem).with('rake', '=0.8.7')
      AlsoMigrate::Gems.activate :rspec, 'rake'
    end
  end
  
  describe :gemset= do
    before(:each) do
      AlsoMigrate::Gems.config.gemsets = [
        {
          :name => {
            :rake => '>0.8.6',
            :default => {
              :externals => '=1.0.2'
            }
          }
        },
        "#{$root}/spec/fixtures/gemsets.yml"
      ]
    end
    
    describe :default do
      before(:each) do
        AlsoMigrate::Gems.gemset = :default
      end
      
      it "should set @gemset" do
        AlsoMigrate::Gems.gemset.should == :default
      end
    
      it "should set @gemsets" do
        AlsoMigrate::Gems.gemsets.should == {
          :name => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :mysql => "=2.8.1",
              :rspec => "=1.3.1"
            },
            :rspec2 => {
              :mysql2 => "=0.2.6",
              :rspec => "=2.3.0"
            }
          }
        }
      end
    
      it "should set Gems.versions" do
        AlsoMigrate::Gems.versions.should == {
          :externals => "=1.0.2",
          :mysql => "=2.8.1",
          :rake => ">0.8.6",
          :rspec => "=1.3.1"
        }
      end
      
      it "should return proper values for Gems.dependencies" do
        AlsoMigrate::Gems.dependencies.should == [ :rake, :mysql ]
        AlsoMigrate::Gems.development_dependencies.should == [ :mysql, :rspec ]
      end
    end
    
    describe :rspec2 do
      before(:each) do
        AlsoMigrate::Gems.gemset = "rspec2"
      end
      
      it "should set @gemset" do
        AlsoMigrate::Gems.gemset.should == :rspec2
      end
    
      it "should set @gemsets" do
        AlsoMigrate::Gems.gemsets.should == {
          :name => {
            :rake => ">0.8.6",
            :default => {
              :externals => '=1.0.2',
              :mysql => "=2.8.1",
              :rspec => "=1.3.1"
            },
            :rspec2 => {
              :mysql2=>"=0.2.6",
              :rspec => "=2.3.0"
            }
          }
        }
      end
    
      it "should set Gems.versions" do
        AlsoMigrate::Gems.versions.should == {
          :mysql2 => "=0.2.6",
          :rake => ">0.8.6",
          :rspec => "=2.3.0"
        }
      end
      
      it "should return proper values for Gems.dependencies" do
        AlsoMigrate::Gems.dependencies.should == [ :rake, :mysql2 ]
        AlsoMigrate::Gems.development_dependencies.should == [ :mysql2, :rspec ]
      end
    end
    
    describe :nil do
      before(:each) do
        AlsoMigrate::Gems.gemset = nil
      end
      
      it "should set everything to nil" do
        AlsoMigrate::Gems.gemset.should == nil
        AlsoMigrate::Gems.gemsets.should == nil
        AlsoMigrate::Gems.versions.should == nil
      end
    end
  end
  
  describe :gemset_from_loaded_specs do
    before(:each) do
      Gem.stub!(:loaded_specs)
    end
    
    it "should return the correct gemset for name gem" do
      Gem.should_receive(:loaded_specs).and_return({ "name" => nil })
      AlsoMigrate::Gems.send(:gemset_from_loaded_specs).should == :default
    end
    
    it "should return the correct gemset for name-rspec gem" do
      Gem.should_receive(:loaded_specs).and_return({ "name-rspec2" => nil })
      AlsoMigrate::Gems.send(:gemset_from_loaded_specs).should == :rspec2
    end
  end
  
  describe :reload_gemspec do
    it "should populate @gemspec" do
      AlsoMigrate::Gems.gemspec.hash.should == {
        "name" => "name",
        "version" => "0.1.0",
        "authors" => ["Author"],
        "email" => "email@email.com",
        "homepage" => "http://github.com/author/name",
        "summary" => "Summary",
        "description" => "Description",
        "dependencies" => [
          "rake",
          { "default" => [ "mysql" ] },
          { "rspec2" => [ "mysql2" ] }
        ],
        "development_dependencies" => [
          { "default" => [ "mysql", "rspec" ] },
          { "rspec2" => [ "mysql2", "rspec" ] }
        ]
       }
    end
  
    it "should create methods from keys of @gemspec" do
      AlsoMigrate::Gems.gemspec.name.should == "name"
      AlsoMigrate::Gems.gemspec.version.should == "0.1.0"
      AlsoMigrate::Gems.gemspec.authors.should == ["Author"]
      AlsoMigrate::Gems.gemspec.email.should == "email@email.com"
      AlsoMigrate::Gems.gemspec.homepage.should == "http://github.com/author/name"
      AlsoMigrate::Gems.gemspec.summary.should == "Summary"
      AlsoMigrate::Gems.gemspec.description.should == "Description"
      AlsoMigrate::Gems.gemspec.dependencies.should == [
        "rake",
        { "default" => ["mysql"] },
        { "rspec2" => [ "mysql2" ] }
      ]
      AlsoMigrate::Gems.gemspec.development_dependencies.should == [
        { "default" => [ "mysql", "rspec" ] },
        { "rspec2" => [ "mysql2", "rspec" ] }
      ]
    end
  
    it "should produce a valid gemspec" do
      AlsoMigrate::Gems.gemset = :default
      gemspec = File.expand_path("../../../also_migrate.gemspec", __FILE__)
      gemspec = eval(File.read(gemspec), binding, gemspec)
      gemspec.validate.should == true
    end
  end
end
