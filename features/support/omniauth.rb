# Mock the OAuth authentication, since we don't want to use an actual email/password

OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '12345',
  info: {
    name: 'John Doe',
    email: 'johndoe@tamu.edu'
  },
  credentials: {
    token: 'mock_token',
    refresh_token: 'mock_refresh_token',
    expires_at: Time.now + 1.week
  }
})