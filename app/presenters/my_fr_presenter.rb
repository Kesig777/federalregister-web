class MyFrPresenter
  def initialize
  end

  SECTIONS = {
    'My Clipboard' => '/my/',
    'My Subscriptions' => '/my/subscriptions',
    'My Comments' => '/my/comments',
    'Sign In' => '/my/auth/sign_in',
  }

  def sections
    SECTIONS
  end
end
