require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    
end

class Post < ActiveRecord::Base
    has_many :likes;
    has_many :like_users, :through => :likes, source: :user;
    belongs_to :user;
end

class Like <ActiveRecord::Base
    belongs_to :user;
    belongs_to :post;
end