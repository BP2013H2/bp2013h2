define( ["libs/jquery"], ->
  
  class FootballDataPreprocessor

    # repo is private so this shouldn't be a problem
    WEATHER_API_KEY: "2f3ae3bff45f8da6"
    REQUESTS_PER_MIN: 10

    constructor: ->

      console.log "Preprocessor created"


    setData: (json) ->

      @data = json


    preprocessData: ->

      unless @data[0]["Weather"]
        @addWeatherData(0)

      #@addPercentageData()


    addWeatherData: (i) ->

      if i >= @data.length then return

      game = @data[i]

      console.log i

      dateParts = game["Date"].split(".")
      date = "#{dateParts[2]}#{dateParts[1]}#{dateParts[0]}"
      
      cityName = game["HomeTeam"]

      $.ajax({
        url: "http://api.wunderground.com/api/#{@WEATHER_API_KEY}/history_#{date}/q/Germany/#{cityName}.json"
        dataType: "jsonp"
      }).done( (d) ->
        if d?.history?.observations?
          # preferrably take the weather at 4pm, if that doesn't exist just get any time
          game["Weather"] = 
            _.find(d.history.observations, (o) -> o.date.hour == "16") or 
            _.find(d.history.observations, (o) -> o.date.hour)
      )

      if i < 18
        setTimeout((=> @addWeatherData(++i)), 60000 / @REQUESTS_PER_MIN)
      else
        console.log @data
        console.log JSON.stringify(@data)


    addPercentageData: ->

      console.log "preprocessing..."
)