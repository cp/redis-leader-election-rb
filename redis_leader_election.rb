require 'redis'
require 'securerandom'

class RedisLeaderElection
  TIMEOUT = 10

  def self.run
    new.run
  end

  attr_reader :key, :redis

  def initialize(key:)
    @key = key
    @redis = Redis.new
  end

  def instance_id
    @instance_id ||= SecureRandom.uuid
  end

  def self.mutually_exclusive(key:)
    new(key: key).mutually_exclusive { yield }
  end

  def mutually_exclusive
    loop do
      break if acquire_lock
      puts "waiting for lock"
      sleep 1
    end

    puts "acquired lock"
    threads = []
    threads << Thread.new { yield }
    threads << Thread.new { refresh_lock }

    threads.each(&:join)
  ensure
    puts "releasing lock"
    release_lock
  end

  def refresh_lock
    loop do
      redis.set(key, instance_id, xx: true, ex: TIMEOUT)
      puts "refreshed lock"
      sleep TIMEOUT / 2
    end
  end

  def acquire_lock
    redis.set(key, instance_id, nx: true, ex: TIMEOUT)
  end

  def release_lock
    if redis.get(key) == instance_id
      puts "releasing lock for #{instance_id}"

      redis.del(key)
    end
  end
end
