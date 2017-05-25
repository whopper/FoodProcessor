module FoodProcessor
  class Invite
    def self.send_email(event, guest, type)
      if type == "all_claimed"
        subject = "All items claimed for Crunch #{event.name} event!"
      else
        subject = "Register for new Crunch #{event.name} event!"
      end 
        content = File.read(File.expand_path("views/#{type}.erb"))
      t = ERB.new(content)
      result = t.result(binding)
      Pony.mail(
        to: guest.email,
        from: 'crunch@acquia.com',
        subject: "#{subject}",
        body: result
      )
    end
  end
end
