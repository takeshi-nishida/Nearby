class Topic < ActiveRecord::Base
  belongs_to :user
  has_many :wants, :as => :wantable
  
  def description_with_owner
    "#{description} by #{user.name if user}"
  end
end
