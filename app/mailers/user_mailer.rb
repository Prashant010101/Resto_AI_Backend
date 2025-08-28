class UserMailer < ApplicationMailer
  def email_verification(user)
    @user = user
    mail(to: @user.email, subject: "Verfiy your email address")
  end
end
