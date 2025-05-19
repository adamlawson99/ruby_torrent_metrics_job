require 'net/http'
require 'open-uri'

class TorrentMetricsCollectorJob < ApplicationJob
  queue_as :default
  class << self
    def producer
      @producer ||= begin
                      kafka_bootstrap_servers = Rails.configuration.kafka[:bootstrap_servers]
                      Rdkafka::Config.new({ "bootstrap.servers": kafka_bootstrap_servers }).producer
                    end
    end
  end

  def perform(*args)
    producer = self.class.producer
    torrents = QbittorrentClient::Torrent.info.data
    torrent_metrics = {
      torrents: []
    }
    torrents.each do |torrent|
      metrics = {
        "hash": torrent[:hash],
        "download_speed": torrent[:dlspeed],
        "upload_speed": torrent[:upspeed],
        "state": torrent[:state],
        "progress": torrent[:progress]
      }
      torrent_metrics[:torrents] << metrics
    end
    producer.produce(
      topic: "torrent_metrics",
      payload: torrent_metrics.to_json,
    ).wait
  end
end
