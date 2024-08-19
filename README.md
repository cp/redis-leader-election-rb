# Redis leader election with Ruby

This is a simple example of how to use Redis to implement a leader election algorithm in Ruby.

## How to run it

```sh
$ make setup
$ foreman start 1
$ foreman start 2
```

You can then kill the leader and observe a follower being elected as the new leader.

## Docs

- https://redis.io/docs/latest/develop/use/patterns/distributed-locks/
