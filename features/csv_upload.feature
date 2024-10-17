# features/csv_upload.feature
Feature: CSV Upload
  As a user
  I want to upload a CSV file
  So that I can process data from the file

  Background:
    Given I am logged in as a user

  Scenario: Successfully upload a valid CSV file
    Given I am on my profile page
    When I attach a valid CSV file to the upload form
    And I click the "Submit" button
    Then I should see "CSV file uploaded successfully."

  Scenario: Upload an invalid CSV file
    Given I am on my profile page
    When I attach an invalid CSV file to the upload form
    And I click the "Submit" button
    Then I should see "Cannot parse CSV file"

  Scenario: Upload without selecting a file
    Given I am on my profile page
    When I do not attach any file to the upload form
    And I click the "Submit" button
    Then I should see "Please upload a CSV file."