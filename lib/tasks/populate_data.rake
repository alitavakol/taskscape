PROJECT_COUNT = 15
USER_COUNT = 50
MAX_MEMBER_COUNT = 15
MAX_ASSIGNMENT_COUNT = 6
MAX_TASK_COUNT = 15
MAX_PROJECT_DEPTH = 2

namespace :db do
  desc "fill database with sample projects, members, tasks, users, assignments"
  task populate: :environment do
    Assignment.destroy_all
    Membership.destroy_all
    # User.destroy_all
    Project.destroy_all

    avatars = Array.new
    ['1.jpg', '2.jpg', '3.png', '4.jpg', '5.jpg', '6.jpg', '7.jpg', '8.jpg', '9.jpg', '10.jpg', '11.jpg', '12.jpg', '13.jpg', '14.jpg', '15.jpg', '16.jpg', '17.jpg', '18.jpg', '20.png', '23.png', '24.png', '19.jpg', '21.png', '22.png', '20.jpg', '21.jpg', '22.jpg', '23.jpg'].each do |f|
      avatars.push(File.open(Rails.root.join('lib/tasks/population_data', f)))
    end
    avatars.push(nil)

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
      p = Project.create!(
        title: Faker::App.name,
        description: Faker::Lorem.sentence,
        creator: User.order("rand()").first,
        visibility: rand > 0.2 ? 1 : 0,
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

    rand(1..MAX_ASSIGNMENT_COUNT).times do
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
