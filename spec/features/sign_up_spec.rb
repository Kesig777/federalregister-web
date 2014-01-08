require 'spec_helper'

feature "Signing up" do
  let(:user) { FactoryGirl.build(:user) }

  scenario "when providing a non-matching password confirmation the user sees an error" do
    visit '/my/sign_up'

    fill_in 'Email', with: user.email
    fill_in 'user_password', with: user.password
    fill_in 'user_password_confirmation', with: 'differentPassword'
    click_button 'Sign up'

    expect(page).to have_inline_error('#user_password_input', "doesn't match confirmation")
  end

  scenario "when providing an invalid email address the user sees an error and the sign up button is disabled, fixing the error allows submission", :js do
    visit '/my/sign_up'

    fill_in 'user_email', with: "this.isn't.valid"
    # trigger blur on email field
    fill_in 'user_password', with: user.password

    expect(page).to have_invalid_email_message('#user_email_input', 'Email address is not valid.')
    expect(page).to have_disabled_button('form#new_user', 'Sign up')

    fill_in 'user_email', with: user.email
    # trigger blur on email field
    fill_in 'user_password', with: user.password

    expect(page).to_not have_selector('#user_email_input .email_invalid')
    expect(page).to have_button('Sign up')

    fill_in 'user_password_confirmation', with: user.password

    click_button 'Sign up'

    expect(current_path).to eq('/my/')
    expect(page).to have_user_util('li', user.email)
    expect(page).to have_selector('.flash.notice', text: 'Welcome to My FR! You have signed up successfully. Some features of My FR require that you confirm your email address. A message with a confirmation link has been sent to your email address.')
  end
end
