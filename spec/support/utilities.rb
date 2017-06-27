# Sign in with the developer
def sign_in(user)
  visit 'auth/developer'
  find('#email').set user.uid
  click_button 'Sign In'
end



