def mock_google_oauth_login(non_tamu_account: false)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: 'google_oauth2',
      uid: '123545',
      info: {
        email: non_tamu_account ? "non-tamu@gmail.com" : "user@tamu.edu",
        name: 'Test User'
      }
    })
  end
  