# Sign in with the developer
def sign_in(user)
  visit 'auth/developer'
  fill_in 'Email',   with: user.uid
  click_button 'Sign In'
end
