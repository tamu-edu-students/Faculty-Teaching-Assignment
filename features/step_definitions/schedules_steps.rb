# frozen_string_literal: true

Given('the following schedules exist for the user {string}:') do |name, schedules_table|
  # user = User.find_by(first_name: name)
  
  schedules_table.hashes.each do |schedule|
    created_sched = @user.schedules.create!(schedule)
    puts "Created schedule: #{created_sched.schedule_name}"
  end
end
When('I visit the schedules index page') do
  visit schedules_path
end

When('I click on the card for {string}') do |schedule_name|
  # Find the specific card that contains the schedule name in the h4 tag and click the stretched link
  card = find('div.sched-card', text: schedule_name, match: :first)
  card.find('a.stretched-link').click
end

Given('I am on the new schedule page') do
  visit new_schedule_path
end

Given('I am on the schedules index page') do
  visit schedules_path
end

Given('I have created a schedule called {string}') do |schedule_name|
  @user.schedules.create!(schedule_name:, semester_name: 'Fall 2024')
end

When('I click the {string} button for {string}') do |button_name, schedule_name|
  # Find the card with the schedule name and click the delete button
  within('div.card', text: schedule_name) do
    click_button button_name
  end
end

When('I search for {string}') do |search_term|
  fill_in 'search_by_name', with: search_term
  click_button 'Search'
end

When('I upload a valid instructor file') do
  valid_instructor_csv = File.read(Rails.root.join('spec', 'fixtures', 'instructors', 'instructors_valid.csv'))
  @instructor_file = Tempfile.new(['instructors_valid', '.csv'])
  @instructor_file.write(valid_instructor_csv)
  @instructor_file.rewind
  attach_file('Select Instructor Data (CSV)', @instructor_file.path)
end

When('I upload a valid room file') do
  valid_room_csv = File.read(Rails.root.join('spec', 'fixtures', 'rooms', 'rooms_valid.csv'))
  @room_file = Tempfile.new(['rooms_valid', '.csv'])
  @room_file.write(valid_room_csv)
  @room_file.rewind
  attach_file('Select Room Data (CSV)', @room_file.path)
end

Then('I should see the {string} button is disabled') do |button_text|
  expect(page).to have_button(button_text, disabled: true)
end
