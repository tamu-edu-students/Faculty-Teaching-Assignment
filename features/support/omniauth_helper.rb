# frozen_string_literal: true

def mock_google_oauth_login(non_tamu_account: false)
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123456789',
    info: {
      email: non_tamu_account ? 'non-tamu@gmail.com' : 'user@tamu.edu',
      first_name: 'John',
      last_name: 'Doe'
    }
  })

  # Ensures user is found or created with these attributes
  User.find_or_create_by!(email: non_tamu_account ? 'non-tamu@gmail.com' : 'user@tamu.edu') do |user|
    user.first_name = 'John'
    user.last_name = 'Doe'
    user.provider = 'google_oauth2'
    user.uid = '123456789'
  end
end
