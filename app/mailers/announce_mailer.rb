class AnnounceMailer < ActionMailer::Base
  default from: 'Takeshi NISHIDA <tnishida@people.kobe-u.ac.jp>'

  def invite(user)
    @user = user
    @host = 'https://wiss2019-dinner.herokuapp.com'

    mail to: "#{@user.name} <#{@user.email}>", subject: 'WISS夕食席決めシステムのご案内'
  end
end
