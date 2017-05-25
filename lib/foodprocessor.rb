module FoodProcessor
  class Invite
    def self.send_email(event, guest, type)
      subject = if type == 'all_claimed'
                  "All items claimed for Crunch #{event.name} event!"
                else
                  "Register for new Crunch #{event.name} event!"
                end
      content = File.read(File.expand_path("views/#{type}.erb"))
      t = ERB.new(content)
      result = t.result(binding)
      Pony.mail(
        to: guest.email,
        from: 'crunch@acquia.com',
        subject: subject.to_s,
        body: result
      )
    end
  end
end
