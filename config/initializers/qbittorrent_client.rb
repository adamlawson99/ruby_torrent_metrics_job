QbittorrentClient.new(
  Rails.configuration.qbittorrent[:username],
  Rails.configuration.qbittorrent[:password],
  true,
  Rails.configuration.qbittorrent[:api_base]
)