require 'sinatra'
require 'securerandom'
require 'data_mapper'
require 'pony'
require 'pry'
require_relative 'lib/foodprocessor.rb'
require_relative 'models/schema.rb'

get '/' do
  @events = Event.all order: :id.desc
  erb :home
end

get '/item/:id' do
  @item = Item.get params[:id]
  erb :item
end

get '/item/:id/delete' do
  @item = Item.get params[:id]
  @title = "Confirm deletion of item ##{params[:id]}"
  erb :delete
end

get '/events/create' do
  erb :create_event
end

delete '/item/:id' do
  item = Item.get params[:id]
  item.destroy
  redirect '/'
end

get '/invite/:url' do
  @link = Link.first(url: "#{request.base_url}/invite/#{params[:url]}")
  @event = Event.get @link.id
  # TODO: place for guest to claim ingredients. For now, it redirects to events/:id
  redirect "/events/#{@event.id}"
end

get '/events' do
  @events = Event.all order: :id.desc
  erb :events
end

get '/events/:id' do
  @event = Event.get params[:id]
  if @event
    @owner = Owner.get @event.owner.id
    @link = Link.get @event.link.id
    @guests = User.all(event_id: @event.id)
    @items = Item.all(event_id: @event.id)
  end
  erb :event
end

get '/events/:id/add_ingredients' do
  @event = Event.get params[:id]
  erb :add_ingredients
end

post '/events/:id/add_ingredients' do
  items = params.keys.length / 4
  item_hash = {}
  (1..items).each do |n|
    temp_hash = params.select { |key, value| key.match(/_#{n}/) }
    top_key = temp_hash["item_#{n}"]
    item_hash[temp_hash["item_#{n}"]] = {'quantity' => temp_hash["quantity_#{n}"], 'price' => temp_hash["price_#{n}"], 'required' => temp_hash["required_#{n}"] == 'Required' ? true : false}
  end
  @event = Event.get params[:id]
  item_hash.each do |k,v|
    item = Item.new
    item.name = k
    item.quantity = v["quantity"]
    item.required = v["required"]
    item.price = v["price"]
    item.event_id = @event.id
    item.save
    @event.items << item
    @event.save
  end

  redirect "/events/#{params[:id]}"
end

get '/events/:id/invite' do
  @event = Event.get params[:id]
  erb :invite_users
end

post '/events/:id/invite' do
  @event = Event.get params[:id]
  guest = User.first(email: params[:email])
  unless guest
    guest = User.new
    guest.email = params[:email]
    guest.name = params[:name]
  end
  guest.event_id = @event.id
  guest.save
  @event.guests << guest
  @event.save
  FoodProcessor::Invite.send_email(@event, guest)
  redirect "/events/#{@event.id}"
end

post '/events/create' do
  event = Event.new
  event.name = params[:title]
  event.date = params[:date]
  event.location = params[:location]
  link = Link.new
  link.url = "#{request.base_url}/invite/#{SecureRandom.hex(6)}"
  link.save
  event.link = link

  # make an owner
  owner = User.first(email: params[:email])
  unless owner
    owner = Owner.new
    owner.name = params[:name]
    owner.email = params[:email]
    owner.save
  end
  event.owner = owner

  # make a guest
  # guest = User.new
  # guest.name = 'William Van Hevelingen'
  # guest.email = 'william.vanhevelingen@acquia.com'
  # guest.save
  # event.guests << guest

  # save
  event.save

  # event.guests.each do |guest|
  #   FoodProcessor::Invite.send_email(event, guest)
  # end

  @title = event.name
  redirect "/events/#{event.id}/add_ingredients"
end
