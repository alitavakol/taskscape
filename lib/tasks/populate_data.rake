PROJECT_COUNT = 3
USER_COUNT = 10
MAX_MEMBER_COUNT = 6
MAX_ROLE_COUNT = 6
MAX_TASK_COUNT = 4
MAX_PROJECT_DEPTH = 3

namespace :db do
  desc "fill database with sample projects, members, tasks, users, assignments"
  task populate: :environment do
    Assignment.destroy_all
    Membership.destroy_all
    # User.destroy_all
    Project.destroy_all

    avatars = [
      File.open(Rails.root.join('lib/tasks/population_data', '1.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '2.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '3.png')), 
      File.open(Rails.root.join('lib/tasks/population_data', '4.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '5.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '6.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '7.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '8.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '9.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '10.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '11.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '12.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '13.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', 'hitler.png')), 
      File.open(Rails.root.join('lib/tasks/population_data', 'ahmadinejad.png')), 
      File.open(Rails.root.join('lib/tasks/population_data', 'obama.png')), 
      File.open(Rails.root.join('lib/tasks/population_data', 'ostrich-head.jpg')), 
      File.open(Rails.root.join('lib/tasks/population_data', '580606.png')), 
      File.open(Rails.root.join('lib/tasks/population_data', 'big-smile-icon.png')), 
      nil
    ]

    developer = User.find_by(email: 'j.smith@gmail.com')
    unless developer
      developer = User.create!(name: "Jack", email: "j.smith@gmail.com", password: '5iveL!fe', role: 2, avatar: avatars.sample)
    end

    if User.count < USER_COUNT
      (USER_COUNT-1).times do
        User.create!(name: Faker::Name.name, email: Faker::Internet.email, password: '5iveL!fe', role: rand(0..2), avatar: avatars.sample)
      end
    end

    PROJECT_COUNT.times do
      p = Project.create(
        title: Faker::App.name,
        description: Faker::Lorem.sentence,
        creator: User.order("rand()").first,
        visibility: rand > 0.5 ? 0 : 1,
      )
    end

    Project.all.each do |p|
      create_tasks_for p, 0, developer
    end
  end
end

def create_tasks_for(project, depth, developer)
  return if depth >= MAX_PROJECT_DEPTH

  rand(1..MAX_MEMBER_COUNT).times do
    user_id = add_or_invite_user.id
    project.memberships.create(member_id: user_id, creator_id: developer.id) unless project.member_ids.include?(user_id)
  end

  rand(0..MAX_TASK_COUNT).times do
    p = Task.create(
      title: Faker::App.name,
      description: Faker::Lorem.sentence,
      x: rand(300),
      y: rand(300),
      color: ("#%06x" % (rand * 0xffffff)),
      importance: rand(4), status: rand(4),
      effort: rand(4),
      creator_id: project.members.order("rand()").first.id,
      supertask_id: project.id,
    )

    rand(1..MAX_ROLE_COUNT).times do
      user_id = project.members.order("rand()").first.id
      p.becomes(Task).assignments.create(assignee_id: user_id, creator_id: developer.id) unless p.becomes(Task).assignee_ids.include?(user_id)
    end

    create_tasks_for p, depth+1, developer
  end
end

def add_or_invite_user
  User.order("rand()").first
  # User.create!(name: Faker::Name.name, email: Faker::Internet.email, password: '5iveL!fe', role: rand(0..2))
end
