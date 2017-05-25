module FoodProcessor

  class Invite
    def self.send_email(params)
      content = File.read(File.expand_path('views/email.erb'))
      t = ERB.new(content)
      result = t.result(binding)
      Pony.mail(
        :to => params[:email],
        :from => "brownbag@acquia.com",
        :subject => "Register for new brownbag #{params[:name]} event!",
        :body => result)
    end

  end

end
