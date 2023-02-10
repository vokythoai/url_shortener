# README

## 1. Setup and install
  - Framework: Ruby on Rails, ( Ruby 3.1.2 )
  - Database: Postgresql

  + Run project
    - Run `bundle install` - install gems
    - Run `rake db:create` - create database
    - Run `rake db:migrate` - run project migration
    - Run `rails s` - starting server

  - Project can be built with Docker
  - Live demo: https://aged-rain-9962.fly.dev/

  + Testing
    - Run `rspec`
    - Create new short url:
      `curl -X POST \
  https://aged-rain-9962.fly.dev/encode \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{
	"original_url": "https://codesubmit.io/library/react"
}'`
    - Decode url:
      `curl -X POST \
  https://aged-rain-9962.fly.dev/decode \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{
	"url": "https://aged-rain-9962.fly.dev/35ZE7g"
}'`

## 2. Solution
  - Each url need to be shorten will be stored in database with a unique hash_id, link with hash_id will be returned to user for using.
  - Algorithm:
    - MD5(original_url + counter) -> base62Encode -> hash ( store hash and original_link to Url table)
  - When user retrive original_link from shorted link, we will find it in DB by provided hash_id.

## 3. Problems and solution:
  - Read/Write-heavy
    + Using 2 different read/write databases.
    + We can using NoSQL like Cassandra or MongoDB in place of Postgresql for faster insert and query.
    + In our system relational queries occur rarely => NoSQL is a good choice and easier for scaling system.
    + LRU (Least Recently Used) is the good caching strategy for system. Caching about 20% of the most used URLs for better performance.
    + Indexing column when using RDBMS for faster query.

  - Security:
    - System can be attacked by DDoS or spamming requests.
      + We can using Cloudflare DDos protection.
      + Implement a request rate-limiting service, limit requests per minutes/user's ip for prevent spamming and secure our system. ( It can be a API Gateway )
    - Implement a user system. Each user will have different permission to access a specific URL

  - Collision:
    + Base62 encode consists of the capital letters A-Z, the lower case letters a-z, and the numbers 0-9. We will have `62^N` URL ( N is the number of characters in the generated URL). With 7 characters, we will have 62^7 ∼3.5 trillion URLs
    + Have an expired date for each url to increasing available hash_id.
    + We also use a counter_number (each request will have an unique number) for encoding original_url to make sure there is no conflict between each request.
      + MD5(original_url + counter) -> base62Encode -> hash
      + Using couter service can quickly become a single point for failure so we should have distributed system manager such as Zookeeper which can provide distributed synchronization. Zookeeper can maintain multiple ranges for our counter servers.
    ```
        Range 1: 1→1,000,000
        Range 2: 1,000,001→2,000,000
        Range 3: 2,000,001→3,000,000
        .
        .
    ```

    + We also can create a standalone Key Generation Service (KGS) that generates a unique key ahead of time and stores it in a separate database for later use. Make things simpler.

## 4. Scaling

  - Assumption we will have 100:1 ratio between read and write and server is read-heavy ( more redirection requests compared to new URL shortenings.)
  - Traffic:
    + 500M new URL shortenings per month, 100 * 500M => 50B redirections per month.
    + New URL shortenings per second
      500 million / (30 days * 24 hours * 3600 seconds) = ~200 URLs/s
    + URLs redirections per second
      50 billion / (30 days * 24 hours * 3600 sec) = ~19K/s
  - Storage estimates:
    + Assume storing every URL shortening request for 5 years, each object takes 500 bytes
    + Total objects: 500 million * 5 years * 12 months = 30 billion
    + Total storage: 30 billion * 500 bytes = 15 TB

  - Bandwidth estimates
    + Write: 200 URL/s * 500 bytes/URL = 100 KB/s
    + Read: 19K URL/s * 500 bytes/URL = ~9 MB/s

  - Cache memory estimates
    + Assuming 20% of URLs generate 80% of traffic, cache 20% hot URLs
    + Requests per day: 19K * 3600 seconds * 24 hours = ~1.7 billion/day
    + Cache 20%: 0.2 * 1.7 billion * 500 bytes = ~170GB

  - Sharding database:
    + Hash-Based Partitioning
    + List-Based Partitioning
    + Range Based Partitioning
    + Composite Partitioning

  - Consistent Hashing for caching instances ( build a distributed caching system ) for a better performance.

  - Database Clean Up
    + Removed expired link by 2 ways:
    + Active clean up: using cron job to remove expired urls
    + Passive clean up: when users tries to access an expired link, we will remove it from DB.

  + Using multiple read replicas for our database.
  + Using a load balancer with Least Connection method, client requests are distributed to the application server with the least number of active connections at the time the client request is received.

  - Metric and analytic:
    + We can store and update metadata like user's country, platform ... alongside URL to have an overview of user needs. It could be useful in case we need to choose server location, CDN ...
    + Metric and analytic hot urls for perform caching more efficiently
