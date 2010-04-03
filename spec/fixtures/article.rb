class Article < ActiveRecord::Base
  also_migrate :article_archives, :ignore => 'body', :indexes => 'id'
end