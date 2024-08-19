$stdout.sync = true

require './lib/redis_leader_election'

class App
  def self.run
    new.run
  end

  def app_name
    "my-fun-app"
  end

  def run
    RedisLeaderElection.mutually_exclusive(key: app_name) do
      while true
        puts "doing work"
        sleep 1
      end
    end
  end
end

App.run
