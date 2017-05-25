require 'sinatra'
require 'securerandom'
require 'data_mapper'

get '/' do
  @events = Event.all :order => :id.desc
  erb :home
end

get '/item/:id' do
  @item = Item.get params[:id]
  erb :item
end

get '/item/:id/delete' do
  @item = Item.get params[:id]
  @title= "Confirm deletion of item ##{params[:id]}"
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

post '/events/create' do
  event = Event.new
  event.name = params[:eventname]
  event.date = params[:eventdate]
  event.location = params[:location]
  link = Link.new
  link.save
  event.link = link.id
  event.save
  redirect '/events'
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/foodprocessor.db")


class Unit
  include DataMapper::Resource

  property :id, Serial
  property :name, Text, :required => true, :unique => true
  belongs_to :item
end

class Item
  include DataMapper::Resource

  has 1, :unit
  property :id, Serial
  property :name, Text, :required => true, :unique => true
  property :required, Boolean, :required => true, :default => false
  property :quantity, Integer, :required => true, :default => 1
  belongs_to :event
end

class Event
  include DataMapper::Resource

  has n, :items
  has 1, :link
  property :id, Serial
  property :name, Text, :required => true, :unique => true
  property :date, DateTime, :required => true
  property :created_at, DateTime, :required => true, :default => lambda{ |p,s| DateTime.now}
  property :location, Text
end

class Link
  include DataMapper::Resource

  property :id, Serial
  property :url, Text, :required => true, :unique => true, :default => SecureRandom.hex(6)
  belongs_to :event
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, Text, :required => true
  property :email, Text, :required => true
end

DataMapper.finalize.auto_upgrade!
