class Temprature
    include Mongoid::Document
    store_in collection: "Forecast_Temp",database:"WeatherForecast"
    field :loc, type: Array
    field :year, type: Float
    field :daily_values, type: Array
    field :month, type: Float
end
