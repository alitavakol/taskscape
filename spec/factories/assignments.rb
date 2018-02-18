# == Schema Information
#
# Table name: assignments
#
#  id          :integer          not null, primary key
#  task_id     :integer          not null
#  assignee_id :integer          not null
#  creator_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :assignment do
    task nil
    assignee nil
    creator nil
  end
end
