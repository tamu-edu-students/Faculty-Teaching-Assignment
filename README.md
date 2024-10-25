# README

## Team Name: AggieAssign

## Summary
The main customer need is to have an application that creates an **efficient classroom schedule** which for each course section, assigns a time, a room, and an instructor, while satisfying a range of constraints. These constraints include room capacity, instructor availability, teaching style requirements, and course conflicts. The system also needs to consider instructor preferences, such as desired teaching times and course preferences, in order to maximize their satisfaction. The application provides a solution by providing an easy to understand interface which allows the user to upload data, preferences and constraints as csv files. It then automatically generates a schedule that meets both hard constraints and soft preferences, while minimizing wasted classroom space and balancing instructor workloads. The application will have additional features such as the ability to manually override schedules and see detailed schedule views, as well as export the generated schedules for easy sharing.

The key stakeholder for this application is the Associate Department Head, who is responsible for creating the teaching schedule before every semester. The secondary stakeholders are the Instructors and Students, who benefit indirectly from having flexible course schedules. The application integrates all scheduling requirements into one platform, allowing for streamlined data input, constraint satisfaction, and schedule optimization, while being scalable for future adjustments.

## Links
- **App** : https://faculty-teaching-assignment-31f5f9c405bc.herokuapp.com
- **Code Climate Report**: https://codeclimate.com/github/tamu-edu-students/Faculty-Teaching-Assignment
- **Team Working agreement** : https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/documentation/documentation/Fall2024/Team%20Working%20Agreement.md
- **Sprint Documentation**:
	* Sprint 1: 
		* Goal: Setup and understand the project, get client data and enable user login and authentication
		* [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/documentation/documentation/Fall2024/Sprint_1_Plan.pdf)
		* [Retrospective](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint%201%20Retrospective.pdf)
	* Sprint 2:
		* Goal: Have a raw views for all the data upload.
		* [Sprint Plan](https://github.com/tamu-edu-students/Faculty-Teaching-Assignment/blob/main/documentation/Fall2024/Sprint_2_Plan.pdf)

# Getting Started with Setup and Deployment

## Prerequisites
1. **Heroku Account**: [Sign up for a Heroku account](https://signup.heroku.com/).
2. **Heroku CLI**: Download and install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli).
3. **GitHub Repository**: Ensure your Rails application is committed and pushed to a GitHub repository.
4. **Rails and Ruby**: Check that you have Ruby and Rails installed locally to set up the app.
5. **OAuth Configuration**: Ensure you have Google OAuth API keys

---

## 1. Clone the GitHub Repository (If Needed)
If you're setting up the project locally, clone the repository:

```bash
git clone https://github.com/tamu-edu-students/Faculty-Teaching-Assignment.git
cd Faculty-Teaching-Assignment
```

---

## 2. Install Dependencies and setup Rails Master Key
Run `bundle install` to install all required dependencies.

```bash
bundle install
```
Setup your Google OAuth Rails Credentials using Google Developer Console.
For a more detailed explantion, see 
[Setup Google OAuth on Google's End](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#setup-google-oauth-on-googles-end) 
and 
[Add OAuth ID and Secret to Rails Credentials](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#create-an-initializer-for-omniauth).

If steps are followed correctly you would have your ```RAILS_MASTER_KEY``` in ```config/master.key```. NEVER EVER COMMIT THIS TO GIT.

---

## 3. Set Up Database (Locally)
Run database migrations and set up the database:

```bash
rails db:create
rails db:migrate
rails db:seed # If there are any seed files
rails server # To run locally
```

## 4. Prepare Application for Heroku

1. **Add a `Procfile`**: Create a file named `Procfile` in the root directory with the following line:

   ```plaintext
   web: bundle exec puma -C config/puma.rb
   ```

2. **Add the Heroku Postgres Add-on**: Heroku uses PostgreSQL as the default database for Rails apps. Check your `Gemfile` for the `pg` gem.

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
# Or whatever it may be
```

Set environment variables on Heroku for any API keys, secrets, or configuration variables, you will have to setup your Google Authentication key :

If you have used ```RAILS_MASTER_KEY``` to encrypt
```bash
heroku config:set RAILS_MASTER_KEY=<YOUR_MASTER_KEY>
```

If the above steps do not work, see [Deploy to Heroku](https://github.com/tamu-edu-students/Google-Auth-Ruby-By-JD?tab=readme-ov-file#deploy-to-heroku) for OmniAuth documentation.
