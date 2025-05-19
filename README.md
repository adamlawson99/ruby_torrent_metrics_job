# Torrent Metrics Publisher

A Ruby on Rails application that scrapes torrent metrics from qBittorrent and publishes them to a Kafka stream using ActiveJob.

## Overview

This project automatically collects metrics from qBittorrent and streams them to Kafka for further processing and analysis. It uses ActiveJob to schedule and manage the scraping jobs.

## Prerequisites

- Ruby 3.0+
- Rails 7.0+
- Docker and Docker Compose
- Git

## Dependencies

This project requires the [qBittorrent Client](https://github.com/adamlawson99/qbittorrent_client) to be checked out locally.

## Setup

### 1. Clone the required repositories

```bash
# Clone the qBittorrent client dependency
git clone https://github.com/adamlawson99/qbittorrent_client.git

# Clone this repository
git clone [your-repository-url]
cd [your-repository-name]
```

### 2. Start Docker services

```bash
docker compose up
```

Wait for all containers to initialize completely.

### 3. Configure the application

Edit the configuration files to point to your qBittorrent instance and Kafka broker:

#### `config/qbittorrent.yml`:
```yaml
default: &default
  api_base: "http://192.168.2.189:8080"

development:
  <<: *default

production:
  <<: *default
```

#### `config/kafka.yml`:
```yaml
default: &default
  bootstrap_servers: "127.0.0.1:9092"

development:
  <<: *default

production:
  <<: *default
```

Set your qbittorrent credentials, set keys `qbittorrent_username` and `qbittorrent_password`

```ruby
rails credentials:edit
```
example
```yaml
qbittorrent_username: admin
qbittorrent_password: adminadmin
```

## Running the Application

Start the ActiveJob workers to begin scraping and publishing metrics:

```bash
bin/jobs start
```

## Job Configuration

By default, the metrics scraper job runs every 15 seconds. You can modify the schedule in `config/recurring.yml`.

## Data Format

The metrics are published to Kafka in the following JSON format:

```json
{
  "torrents": [
    {
      "hash": string,
      "download_speed": int,
      "upload_speed": int,
      "state": string,
      "progress": float
    },
    {
      "hash": string,
      "download_speed": int,
      "upload_speed": int,
      "state": string,
      "progress": float
    }
  ]
}
```
