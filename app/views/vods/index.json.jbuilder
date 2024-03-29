# frozen_string_literal: true

json.array!(@vods) do |vod|
  json.extract! vod, :id
  json.url vod_url(vod, format: :json)
end
