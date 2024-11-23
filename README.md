# README

## Team Name: AggieAssign

## Summary
The main customer need is to have an application that creates an **efficient classroom schedule** which for each course section, assigns a time, a room, and an instructor, while satisfying a range of constraints. These constraints include room capacity, instructor availability, teaching style requirements, and course conflicts. The system also needs to consider instructor preferences, such as desired teaching times and course preferences, in order to maximize their satisfaction. The application provides a solution by providing an easy to understand interface which allows the user to upload data, preferences and constraints as csv files. It then automatically generates a schedule that meets both hard constraints and soft preferences, while minimizing wasted classroom space and balancing instructor workloads. The application will have additional features such as the ability to manually override schedules and see detailed schedule views, as well as export the generated schedules for easy sharing.

The key stakeholder for this application is the Associate Department Head, who is responsible for creating the teaching schedule before every semester. The secondary stakeholders are the Instructors and Students, who benefit indirectly from having flexible course schedules. The application integrates all scheduling requirements into one platform, allowing for streamlined data input, constraint satisfaction, and schedule optimization, while being scalable for future adjustments.

## Table of Contents
- [Important Links](#important-links)
- [Build Instructions](#build-instructions)
- [Getting Started with Setup and Deployment](#getting-started-with-setup-and-deployment)
   - [Setting up the app locally](#setting-up-the-app-locally)
   - [Prepare the application for Heroku](#prepare-application-for-heroku)
- [Using the Application](#using-the-application)
- [Run Tests locally](#run-tests-locally)
- [Contact Information](#contact)

## Important Links
- **App**: [Live Application](https://faculty-teaching-assignment-31f5f9c405bc.herokuapp.com)
- **Code Climate Report**: [Code Quality Report](https://codeclimate.com/github/tamu-edu-students/Faculty-Teaching-Assignment)
- **Team Working Agreement**: [Working Agreement](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/documentation/documentation/Fall2024/Team%20Working%20Agreement.md)
- **Application Demo**: [Application Demo Video](https://youtu.be/2_s7YLV0lkk)

### Sprint Documentation:
- **Sprint 1**: 
  - **Goal**: Setup and understand the project, get client data, and enable user login and authentication.
  - [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/documentation/documentation/Fall2024/Sprint_1_Plan.pdf)
  - [Retrospective](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint%201%20Retrospective.pdf)

- **Sprint 2**:
  - **Goal**: Create raw views for all data uploads.
  - [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_2_Plan.pdf)
  - [Retrospective](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_2_Retrospective.pdf)

- **Sprint 3**:
  - **Goal**: Implement the algorithm on actual client-provided data.
  - [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_3_Plan.pdf)
  - [Retrospective](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_3_Retrospective.pdf)
 
- **Sprint 4**:
  - **Goal**: Integrate the algorithm and soft constraints, straighten out some issues, and get the app running end to end.
  - [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_4_Plan.pdf)

---




## Build Instructions

### Prerequisites
- **Ruby**: Version `>= 2.7.0`
- **C Compiler**: Required for native extensions (e.g., `gcc` or `clang`)
- **wget**: Used for downloading assets

Clone repository:
```
git clone git@github.com:tamu-edu-students/Faculty-Teaching-Assignment.git
```
Download gems and other dependencies:
```
cd Faculty-Teaching-Assignment
bundle install
rake glpk:install
```
The schedule builder relies on [GLPK](https://www.gnu.org/software/glpk/), an open-source linear program solver. This is downloaded, configured, and installed by the `glpk:install` Rake task. By default, it is installed to the top-level app directory, as to prevent the user from having to add the required binaries to their path. See `lib/tasks/glpk.rake` for details.
<details>
  <summary>Facing issues?</summary>
  <ul>
    <li>Install <code>wget</code> on your system so that the GLPK solver can be installed correctly</li>
    <li>On Linux/macOS, use:</li>
    <pre><code>sudo apt install wget</code></pre>
    <li>Or:</li>
    <pre><code>brew install wget</code></pre>
  </ul>
</details>

# Getting Started with Setup and Deployment

## Prerequisites
1. **Heroku Account**: [Sign up for a Heroku account](https://signup.heroku.com/).
2. **Heroku CLI**: Download and install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).
3. **GitHub Repository**: Ensure you have access to the github repository.
4. **Rails and Ruby**: Check that you have Ruby and Rails installed locally to set up the app.
5. **OAuth Configuration**: Ensure you have Google OAuth API keys

---

## Setting up the app locally
### 1. Clone the GitHub Repository (If Needed)
If you're setting up the project locally, clone the repository:

```bash
git clone https://github.com/tamu-edu-students/Faculty-Teaching-Assignment.git
cd Faculty-Teaching-Assignment
```

---

### 2. Install Dependencies and setup Rails Master Key
To install all required dependencies, run:

```bash
bundle config set --local without 'production' && bundle install
```

Setup your Google OAuth Rails Credentials using Google Developer Console.
For a more detailed explantion, see 
[Setup Google OAuth on Google's End](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#setup-google-oauth-on-googles-end) 
and 
[Add OAuth ID and Secret to Rails Credentials](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#create-an-initializer-for-omniauth).

If steps are followed correctly you would have your ```RAILS_MASTER_KEY``` in ```config/master.key```. NEVER EVER COMMIT THIS TO GIT.
<details>
  <summary>Facing issues?</summary>
  You might need to delete the <code>credentials.yml.enc</code> file which in the <code>config/</code> folder and try to configure the master key again
</details>
---

### 3. Set Up Database (Locally)
Run database migrations and set up the database:

```bash
rails db:create
rails db:migrate
rails db:seed 
```

### 4. Run the server (Locally)
```bash
rails server # To run locally
```

### 5. Access the Application
Open your browser and navigate to [http://localhost:3000](http://localhost:3000) to view the app running.

## Prepare Application for Heroku

1. **Add a `Procfile`**: Create a file named `Procfile` in the root directory with the following line:

   ```plaintext
   web: bundle exec puma -C config/puma.rb
   ```

2. **Add the Heroku Postgres Add-on**: Heroku uses PostgreSQL as the default database for Rails apps. Check your `Gemfile` for the `pg` gem. (https://elements.heroku.com/addons/heroku-postgresql)

3. **Environment Variables**: Use `dotenv` for local testing and set variables on Heroku using the CLI.

---

## 5. Deploy to Heroku

1. **Login to Heroku**:

   ```bash
   heroku login
   ```

2. **Create a New Heroku App**:

   ```bash
   heroku create <YOUR_APP_NAME> # Optionally specify an app name
   ```

3. **Add Heroku as a Git Remote**:

   ```bash
   git remote add heroku https://git.heroku.com/<YOUR_APP_NAME>.git
   ```

4. **Push to Heroku**:

   ```bash
   git push heroku main
   ```

5. **Run Database Migrations on Heroku**:

   ```bash
   heroku run rails db:migrate
   ```

---

## 6. Configure Environment Variables on Heroku and add redirect URI

Add the Heroku domain as an authorized redirect URI to your Google OAuth. Example:
```bash
https://<YOUR_APP_NAME>.herokuapp.com/auth/<PROVIDER>/callback
```

Set environment variables on Heroku for any API keys, secrets, or configuration variables, you will have to setup your Google Authentication key :

If you have used ```RAILS_MASTER_KEY``` to encrypt
```bash
heroku config:set RAILS_MASTER_KEY=<YOUR_MASTER_KEY>
```

If the above steps do not work, see [Deploy to Heroku](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#deploy-to-heroku) for OmniAuth documentation.

## Using the application
1. Login using your TAMU Email ID
2. The landing page shows the schedules you have been working on
3. Click on ```Create a New Schedule``` to create one with a name and semester
4. Click on the schedule card to upload required files
    - Sample files are in the ```db/sample``` folder of the project
    - Upload the rooms, courses and instructors csv files
5. Once the files are uploaded, click on ```View Data``` to view the available data for this schedule
6. Click on ```Add Predefined Courses``` to lock any course/instructor to a particular time slot
    - Click on the Lock icon to lock and unclock a particular time slot and room to ensure no courses are scheduled in that slot
    - Click on a particular cell and select a course from the sidebar to assign a course to a particular slot and room
7. Click on ```Generate Remaining``` to generate the schedule
8. If there is an error in the data that is highlighted, such as the number of courses being more than the instructor hours, go back to ```View Data``` and hide courses that don't need to be scheduled
9. Once the schedule is generated, room bookings can be deleted or locked to modify the schedule as needed
10. Click on ```Export``` to download the schedule as a csv

## Run Tests Locally
After cloning and setting up the repository, run tests from the project root:
1. To run the rspec tests, run
   ```bash
   bundle exec rspec
   ```
2. To run the cucumber tests, run
   ```bash
   bundle exec cucumber
   ```

Ensure that all tests pass with a coverage greater than 90%. Coverage reports are available in the ```coverage/``` folder.

## Contact
In case of any issues or queries, please contact the developers:
* Wahib Kapdi: [wahibkapdi@tamu.edu](mailto:wahibkapdi@tamu.edu)
* Colby Enders: [colby.endres@tamu.edu](mailto:colby.endres@tamu.edu)
* Navya Unnikrishnan: [navya_unni@tamu.edu](mailto:navya_unni@tamu.edu)
* Navya Priya Nandimandalam: [navyapriya_n@tamu.edu](mailto:navyapriya_n@tamu.edu)
* Pavithra Gopalakrishnan: [pgopal719@tamu.edu](mailto:pgopal719@tamu.edu)
* Yuqi Fan: [fan321@tamu.edu](mailto:fan321@tamu.edu)
* Abel Gizaw: [kingofkings441@tamu.edu](mailto:kingofkings441@tamu.edu)
