class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, :presence => { :message => "Please enter your email address" }
  validates :password, :presence => { :message => "Please enter password" }
  validates :password, :confirmation => true, unless: Proc.new { |a| a.password_confirmation.blank? }
end
