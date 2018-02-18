# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  description :text(65535)
#  visibility  :integer          not null
#  status      :integer
#  urgency     :integer
#  importance  :integer
#  effort      :integer
#  due_date    :datetime
#  project_id  :integer
#  creator_id  :integer          not null
#  x           :integer
#  y           :integer
#  color       :string(255)
#  archived    :boolean          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Task, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
