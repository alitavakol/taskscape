# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  member_id  :integer          not null
#  creator_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :membership do
    project nil
    member nil
    creator nil
  end
end
