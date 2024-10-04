Given("I am on the home page") do
  visit root_path
end

When("I click on {string}") do |button|
  click_button button
end

Then("I should be logged in as {string}") do |name|
  expect(page).to have_content(name)
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end