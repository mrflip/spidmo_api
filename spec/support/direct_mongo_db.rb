class DirectMongoDb
  attr_accessor :mongo

  def initialize
    self.mongo = EM::Mongo::Connection.new('localhost', 27017, 1, {:reconnect_in => 1}).db('spidmo_api_test')
  end

  def find(collection, selector={}, opts={}, &block)
    EM::Synchrony.sleep(0.01)
    f = Fiber.current
    mongo.collection(collection).find(selector, opts) do |result|
      f.resume(result)
    end
    res = Fiber.yield
    yield res if block_given?
    res
  end

  def first(collection, selector={}, opts={}, &block)
    opts[:limit] = 1
    res = find(collection, selector, opts).first
    yield res if block_given?
    res
  end

  def insert(collection, *args)
    mongo.collection(collection).insert(*args)
    EM::Synchrony.sleep(0.01)
  end
  def update(collection, *args)
    mongo.collection(collection).update(*args)
    EM::Synchrony.sleep(0.01)
  end
  def save(collection, *args)
    mongo.collection(collection).save(*args)
    EM::Synchrony.sleep(0.01)
  end
  def remove(collection, *args)
    mongo.collection(collection).remove(*args)
    EM::Synchrony.sleep(0.01)
  end
end
