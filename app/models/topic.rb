class Topic < ActiveRecord::Base
  has_many :wants, :as => :wantable
end
