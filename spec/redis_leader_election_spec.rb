require_relative '../lib/redis_leader_election'

RSpec.describe RedisLeaderElection do
  let(:key) { "leader" }
  let(:redis) { Redis.new }
  let(:leader) { RedisLeaderElection.new(key: key) }

  before do
    redis.del(key)
  end

  it "acquires and releases the lock" do
    leader.mutually_exclusive do
      expect(redis.get(key)).to eq(leader.instance_id)
    end

    expect(redis.get(key)).to be_nil
  end

  it "executes the block" do
    expect { |b| leader.mutually_exclusive(&b) }.to yield_control
  end

  describe "when an exception is raised" do
    it "releases the lock" do
      begin
        leader.mutually_exclusive do
          raise "error"
        end
      rescue
      end

      expect(redis.get(key)).to be_nil
    end
  end
end
