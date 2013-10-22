define( ["libs/jquery"], ->
  
  class FootballDataPreprocessor

    # repo is private so this shouldn't be a problem
    WEATHER_API_KEY: "2f3ae3bff45f8da6"
    REQUESTS_PER_MIN: 9
    CITY_TO_TEAM: {
      "Dortmund": "Borussia Dortmund"
      "Bremen": "Werder Bremen"
      "Augsburg": "FC Augsburg"
      "Duesseldorf": "Fortuna Düsseldorf"
      "Frankfurt": "Eintracht Frankfurt"
      "Leverkusen": "Bayer Leverkusen"
      "Freiburg": "SC Freiburg"
      "Erlangen": "Greuther Fürth"
      "Mainz": "Mainz 05"
      "Munich": "Bayern München"
      "Hamburg": "Hamburger SV"
      "Nuremberg": "1.FC Nürnberg"
      "Moenchengladbach": "Mönchengladbach"
      "Sinsheim": "1899 Hoffenheim"
      "Hannover": "Hannover"
      "Bottrop": "Schalke 04"
      "Esslingen": "VfB Stuttgart"
      "Wolfsburg": "VfL Wolfsburg"
      "Cologne": "1.FC Köln"
      "Berlin": "Hertha BSC"
      "Kaiserslautern": "1.FC K'lautern"
      "Reinbek": "St Pauli"
    }


    setData: (json) ->

      @data = json
      @weatherDeferred = new $.Deferred()
      @dataDeferred = new $.Deferred()


    preprocessData: ->

      console.log "Querying weather data for #{@data.length} games..."

      # in case anything wents wrong, the already scraped data is available via window.data
      window.data = @data
      @addWeatherData(0)
      @weatherDeferred.done( =>
        console.log "Successfully queried weather data..."
        @addPercentageData()
      )


    addWeatherData: (i) ->

      if i >= @data.length
        return @weatherDeferred.resolve()

      unless @data[i].Weather

        game = @data[i]

        console.log "Game", i

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

        setTimeout((=> @addWeatherData(++i)), 60000 / @REQUESTS_PER_MIN)

      else

        @addWeatherData(++i)


    addPercentageData: ->

      @percentageData = {}
      for city, team of @CITY_TO_TEAM
        @percentageData[city] = {"name": team, "conditions": {}}

      # simply switch the percentage function for different measures
      #getPercentage = (args...) => @getGoalPercentage(args...)
      getPercentage = (args...) => @getWinPercentage(args...)

      getPercentage()
      getPercentage("rain", "rain", 1, 1)
      getPercentage("snow", "snow", 1, 1)
      getPercentage("conds", "sun", "Clear", "Clear")
      getPercentage("tempm", "cold", -40, 9.999)
      getPercentage("tempm", "mild", 10, 19.999)
      getPercentage("tempm", "hot", 20, 40)

      # maximum value, so we can calculate the deviation and adapt the scale dynamically ;)
      @maxValue = _.max(_.collect(@percentageData, (team) -> _.max(_.collect(team.conditions, (c) -> c.p))))

      console.log "Percentage data added..."

      @dataDeferred.resolve(@percentageData)


    getWinPercentage: (condition, conditionName, lowerBoundary, upperBoundary) ->

      for city, team of @CITY_TO_TEAM

        count = 0
        pOverall = _.reduce(@data, ((sum, game) =>
          unless game.Weather then return sum

          if (
            game["HomeTeam"] == city and
            (not condition or lowerBoundary <= game.Weather[condition] <= upperBoundary)
          )
            count++
            if game["FTHG"] > game["FTAG"]
              return ++sum
            else
              return sum
          else if (
            game["AwayTeam"] == city and
            (not condition or lowerBoundary <= game.Weather[condition] <= upperBoundary)
          )
            count++
            if game["FTAG"] > game["FTHG"]
              return ++sum
            else
              return sum
          else
            return sum
        ), 0)

        if not condition
          @percentageData[city]["overall"] = {p: pOverall / count, count: count}
        else if count and not isNaN(pOverall)
          @percentageData[city]["conditions"][conditionName] = {p: pOverall / count, count: count}
        else
          @percentageData[city]["conditions"][conditionName] = {p: -1}


    getGoalPercentage: (condition, conditionName, lowerBoundary, upperBoundary) ->

      for city, team of @CITY_TO_TEAM

        count = 0
        pOverall = _.reduce(@data, ((sum, game) =>
          unless game.Weather then return sum

          if (
            game["HomeTeam"] == city and
            (not condition or lowerBoundary <= game.Weather[condition] <= upperBoundary)
          )
            count++
            return sum + game["FTHG"]
          else if (
            game["AwayTeam"] == city and
            (not condition or lowerBoundary <= game.Weather[condition] <= upperBoundary)
          )
            count++
            return sum + game["FTAG"]
          else
            return sum
        ), 0)

        if not condition
          @percentageData[city]["overall"] = {p: pOverall / count, count: count}
        else if count and not isNaN(pOverall)
          @percentageData[city]["conditions"][conditionName] = {p: pOverall / count, count: count}
        else
          @percentageData[city]["conditions"][conditionName] = {p: -1}


    getPercentageData: ->

      @dataDeferred.promise()


    getMaxValue: ->

      @maxValue or 1
)