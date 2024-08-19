require 'redis'
require 'securerandom'

$stdout.sync = true

class RedisLeaderElection
  def self.run
    new.run
  end

  def initialize
    @redis = Redis.new
  end

  def application_id
    @application_id ||= SecureRandom.uuid
  end

  def acquire_lock
    @redis.set('leader-election', application_id, nx: true)
  end

  def release_lock
    if @redis.get('leader-election') == application_id
      puts "releasing lock for #{application_id}"

      @redis.del('leader-election')
    end
  end

  def run_task
    loop do
      puts "doing work"
      sleep 1
    end
  end

  def run
    # Try and acquire the lock until elected leader
    puts "booting application #{application_id}"
    loop do
      break if acquire_lock
      puts "waiting for lock"
      sleep 1
    end

    puts "acquired lock"
    run_task
  ensure
    puts "releasing lock"
    release_lock
  end
end

RedisLeaderElection.run
