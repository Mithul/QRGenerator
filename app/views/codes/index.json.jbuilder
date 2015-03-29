json.array!(@codes) do |code|
  json.extract! code, :id, :qr
  json.url code_url(code, format: :json)
end
