# == Schema Information
#
# Table name: assets
#
#  id              :integer          not null, primary key
#  file            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  referencer_id   :integer
#  referencer_type :string(255)
#  starred         :boolean          default(FALSE)
#  uploading       :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :asset do
    file "MyString"
    referencer_id nil
    referencer_type nil
    starred false

    trait :starred do
      starred true
    end
  end
end
