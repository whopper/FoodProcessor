module FoodProcessor
  class Invite
    def self.send_email(event, guest, type)
      content = File.read(File.expand_path('views/email.erb'))
      t = ERB.new(content)
      result = t.result(binding)
      Pony.mail(
        to: guest.email,
        from: 'crunch@acquia.com',
        subject: "Register for new Crunch #{event.name} event!",
        body: result
      )
    end
  end
end
