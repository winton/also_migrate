require "spec_helper"

describe AlsoMigrate do
  
  [ "table doesn't exist yet", "table already exists" ].each do |description|
    describe description do
      describe 'with all options' do
        
        before(:each) do
          reset_fixture
        
          if description == "table doesn't exist yet"
            Article.also_migrate(
              :article_archives,
              :add => [
                [ 'deleted_at', :datetime ]
              ],
              :subtract => 'restored_at',
              :ignore => 'body',
              :indexes => 'id'
            )
          end
        
          $db.migrate(1)
          $db.migrate(0)
          $db.migrate(1)
        
          if description == "table already exists"
            Article.also_migrate(
              :article_archives,
              :add => [
                [ 'deleted_at', :datetime ]
              ],
              :subtract => %w(restored_at),
              :ignore => %w(body),
              :indexes => %w(id)
            )
            $db.migrate(1)
          end
        end
        
        it "should create the add column" do
          (columns('article_archives') - columns('articles')).should == [ 'deleted_at' ]
        end
      
        it "should not create the subtract column" do
          (columns('articles') - columns('article_archives')).should == [ 'restored_at' ]
        end
    
        it 'should migrate both tables up' do
          migrate_with_state(2)
          (@new_article_columns - @old_article_columns).should == [ 'permalink' ]
          (@new_archive_columns - @old_archive_columns).should == [ 'permalink' ]
        end
      
        it 'should migrate both tables down' do
          $db.migrate(2)
          migrate_with_state(1)
          (@old_article_columns - @new_article_columns).should == [ 'permalink' ]
          (@old_archive_columns - @new_archive_columns).should == [ 'permalink' ]
        end
    
        it "should ignore the body column" do
          (columns('article_archives') - columns('articles')).should == [ 'deleted_at' ]
          connection.remove_column(:articles, :body)
          (columns('article_archives') - columns('articles')).should == [ 'body', 'deleted_at' ]
        end
      
        it "should only add an index for id" do
          indexed_columns('articles').should == [ 'id', 'read' ]
          indexed_columns('article_archives').should == [ 'id' ]
        end
      end
      
      describe 'with no index option' do
      
        before(:each) do
          reset_fixture
          
          if description == "table doesn't exist yet"
            Article.also_migrate :article_archives
          end
      
          $db.migrate(0)
          $db.migrate(1)
      
          if description == "table already exists"
            Article.also_migrate :article_archives
            $db.migrate(1)
          end
        end
      
        it "should add all indexes" do
          indexed_columns('articles').should == [ 'id', 'read' ]
          indexed_columns('article_archives').should == [ 'id', 'read' ]
        end
      end
      
      describe "with other table" do
      
        before(:each) do
          reset_fixture
          
          if description == "table doesn't exist yet"
            Article.also_migrate :article_archives
            Comment.also_migrate :comment_archives
          end
      
          $db.migrate(0)
          $db.migrate(1)
          $db.migrate(2)
          $db.migrate(3)
      
          if description == "table already exists"
            Article.also_migrate :article_archives
            Comment.also_migrate :comment_archives
            $db.migrate(3)
          end
        end
      
        it "should not affect other table" do
          columns('articles').should == columns('article_archives')
          columns('comments').should == columns('comment_archives')
          columns('articles').should == ["id", "title", "body", "read", "restored_at", "permalink"]
          columns('comments').should == ["id", "header", "description"]
        end
      end
      
      if description == "table already exists"
        describe 'with add and subtract option' do
        
          before(:each) do
            reset_fixture
          
            Article.also_migrate :article_archives
      
            $db.migrate(0)
            $db.migrate(1)
          
            Article.also_migrate_config = nil
            Article.also_migrate(
              :article_archives,
              :add => [
                [ 'deleted_at', :datetime ]
              ],
              :subtract => 'restored_at'
            )
          end
        
          it "should add and remove fields" do
            columns('article_archives').should == %w(id title body read restored_at)
            $db.migrate(1)
            columns('article_archives').should == %w(id title body read deleted_at)
          end
        end
      end
    end
  end
end