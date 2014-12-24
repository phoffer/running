json.array!(@shoes) do |shoe|
  json.extract! shoe, :id, :user_id, :miles, :expectation, :cost, :location
  json.url shoe_url(shoe, format: :json)
end
