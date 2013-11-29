class AnnounceMailer < ActionMailer::Base
  default from: "Takeshi NISHIDA <nishida@tsg.jp>"

  def invite(user)
    @user = user
    @host = "wiss-dinner.herokuapp.com"

    mail to: "#{@user.name} <#{@user.email}>", subject: "WISS2013夕食席決めシステムのご案内"
  end
end
