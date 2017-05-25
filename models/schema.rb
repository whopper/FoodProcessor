
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/foodprocessor.db")

class Unit
  include DataMapper::Resource

  property :id, Serial
  property :name, Text, required: true, unique: true
  belongs_to :item
end

class Item
  include DataMapper::Resource

  has 1, :unit
  property :id, Serial
  property :name, Text, required: true, unique: true
  property :required, Boolean, required: true, default: false
  property :price, Float, required: true, default: 0
  property :quantity, Integer, required: true, default: 1
  belongs_to :event
  belongs_to :user
end

class Event
  include DataMapper::Resource

  has n, :items
  has 1, :link
  has 1, :owner
  has n, :eventRelGuest
  has n, :guests, 'User', through: :eventRelGuest, via: :user
  property :id, Serial
  property :name, Text, required: true
  property :date, DateTime, required: true
  property :created_at, DateTime, required: true, default: ->(_p, _s) { DateTime.now }
  property :location, Text
end

class Link
  include DataMapper::Resource

  property :id, Serial
  property :url, Text, required: true, unique: true
  belongs_to :event
end

class User
  include DataMapper::Resource

  has n, :items
  property :id, Serial
  property :name, Text, required: true
  property :email, Text, required: true, unique: true
  belongs_to :event
end

class EventRelGuest
  include DataMapper::Resource

  belongs_to :event, key: true
  belongs_to :user, key: true
end

class Owner < User
end

DataMapper.finalize.auto_upgrade!
User.raise_on_save_failure = true
Event.raise_on_save_failure = true
