# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  first_name :string(255)
#  last_name  :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  avatar     :string(255)
#

FactoryGirl.define do
  factory :profile do
    first_name 'Sefsfs'
    last_name 'sefdofjpsoe'
    association :asset
  end
end
