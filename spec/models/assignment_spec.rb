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

require 'rails_helper'

RSpec.describe Assignment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
