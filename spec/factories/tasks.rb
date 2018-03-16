# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  title        :string(255)      not null
#  description  :text(65535)
#  visibility   :integer          not null
#  status       :integer
#  urgency      :integer
#  importance   :integer
#  effort       :integer
#  due_date     :datetime
#  supertask_id :integer
#  creator_id   :integer
#  x            :integer
#  y            :integer
#  color        :string(255)
#  archived     :boolean          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :task do
    title "MyString"
    description "MyText"
    visibility 1
    status 1
    urgency 1
    importance 1
    effort 1
    due_date "2018-02-18 09:19:50"
    project nil
    creator nil
    x 1
    y 1
    color "MyString"
    archived false
  end
end
