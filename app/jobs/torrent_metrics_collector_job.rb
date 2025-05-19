require 'net/http'
require 'open-uri'

class TorrentMetricsCollectorJob < MetricCollectorJob
  queue_as :default

  def initialize
    super
    qbittorrent_api_base = Rails.configuration.qbittorrent[:api_base]
    kafka_bootstrap_servers = Rails.configuration.kafka[:bootstrap_servers]
    qbittorrent_username = Rails.application.credentials.qbittorrent_username
    qbittorrent_password = Rails.application.credentials.qbittorrent_password
    @torrent_client = QbittorrentClient.new(qbittorrent_username, qbittorrent_password, true, qbittorrent_api_base)
    @producer = Rdkafka::Config.new({ "bootstrap.servers": kafka_bootstrap_servers }).producer
  end

  def perform(*args)
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
    @producer.produce(
      topic: "torrent_metrics",
      payload: torrent_metrics.to_json,
    ).wait
  end
end
