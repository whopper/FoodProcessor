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
  if @event
    @owner = Owner.get @event.owner.id
    @link = Link.get @event.link.id
    @guests = User.all(event_id: @event.id)
    @items = Item.all(event_id: @event.id)
  end
  erb :invite
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

post '/events/claim/:id' do
  # assign/claim ingredients
  @event = Event.get params[:id]
  guest = User.first(email: params[:email])
  unless guest
    guest = User.new
    guest.email = params[:email]
    guest.name = params[:name]
  end

  guest.event_id = @event.id
  item = Item.get params[:item_id]
  guest.items << item
  guest.save
  item.user_id = guest.id
  item.save
  @event.guests << guest
  @event.save

  items = Item.all(event_id: @event.id)
  unclaimed = items.all(user_id: nil)
  FoodProcessor::Invite.send_email(@event, guest, 'all_claimed') if unclaimed == []
  redirect "/events/#{@event.id}"
end

get '/events/:id/add_ingredients' do
  @event = Event.get params[:id]
  erb :add_ingredients
end

post '/events/:id/add_ingredients' do
  items = params.keys.length / 4
  item_hash = {}
  (1..items).each do |n|
    temp_hash = params.select { |key, _value| key.match(/_#{n}/) }
    top_key = temp_hash["item_#{n}"]
    item_hash[temp_hash["item_#{n}"]] = { 'quantity' => temp_hash["quantity_#{n}"], 'price' => temp_hash["price_#{n}"], 'required' => temp_hash["required_#{n}"] == 'Required' ? true : false }
  end

  @event = Event.get params[:id]

  item_hash.each do |k, v|
    item = Item.new
    item.name = k
    item.quantity = v['quantity']
    item.required = v['required']
    item.price = v['price']
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
  FoodProcessor::Invite.send_email(@event, guest, 'invited')
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

  # save
  event.save

  event.guests.each do |guest|
    FoodProcessor::Invite.send_email(event, guest, 'invited')
  end

  @title = event.name
  redirect "/events/#{event.id}/add_ingredients"
end

get '/events/:id/delete' do
  require 'pry' ; binding.pry
  event = Event.get(params[:id])
  event.destroy
end
