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
      sleep 1
    end

    threads = []
    refresh_thread = Thread.new do
      loop do
        refresh_lock
        sleep TIMEOUT / 2
      end
    end

    threads << Thread.new do
      yield
      refresh_thread.kill
    end

    threads.each(&:join)
  ensure
    release_lock
  end

  def refresh_lock
    redis.set(key, instance_id, xx: true, ex: TIMEOUT)
  end

  def acquire_lock
    redis.set(key, instance_id, nx: true, ex: TIMEOUT)
  end

  def release_lock
    redis.del(key) if redis.get(key) == instance_id
  end
end
