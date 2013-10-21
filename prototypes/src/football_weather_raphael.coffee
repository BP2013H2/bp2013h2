require(["libs/raphael-min", "libs/lodash.min", "football_weather_data_2012", "football_preprocessor"], (Raphael, underscoreDummy, {dataset}, Preprocessor) ->

  WIDTH = 1200
  HEIGHT = 1000
  CONDITIONS_RECT_WIDTH = 500
  CONDITIONS_RECT_HEIGHT = 50
  CONDITIONS_RECT_X = 400
  CONDITIONS_RECT_Y = 400
  TEAM_ELLIPSE_RX = 50
  TEAM_ELLIPSE_RY = 25
  LINE_WIDTH = 50

  paper = Raphael("chart", WIDTH, HEIGHT)

  teamEllipses = []
  conditionRects = []
  percentageLines = []

  hoverStart = ->

    for lineObject in percentageLines

      switch this.hoverType 
        when "condition"
          if this != conditionRects[lineObject.target]
            lineObject.line.attr("opacity", 0.1)
        when "condition_text"
          if this.rectIndex != lineObject.target
            lineObject.line.attr("opacity", 0.1)
        when "team"
          if this != teamEllipses[lineObject.source]
            lineObject.line.attr("opacity", 0.1)
        when "team_text"
          if this.ellipseIndex != lineObject.source
            lineObject.line.attr("opacity", 0.1)
        when "line"
          if this != lineObject.line
            lineObject.line.attr("opacity", 0.1)

  hoverEnd = ->

    for lineObject in percentageLines

      lineObject.line.attr("opacity", 1)

  drawConditionRects = ->

    rectWidth = CONDITIONS_RECT_WIDTH / _.size(_.sample(data).conditions)
    rectX = CONDITIONS_RECT_X
    rectY = CONDITIONS_RECT_Y

    i = 0
    for key,value of _.sample(data).conditions

      rect = paper.rect(i * rectWidth + rectX, rectY, rectWidth, CONDITIONS_RECT_HEIGHT)
      rect.attr(fill: "#FFFFFF", stroke: "#000000")
      text = paper.text(rectX + i * rectWidth + rectWidth / 2, rectY + CONDITIONS_RECT_HEIGHT / 2, key)
      rect.hoverType = "condition"
      text.hoverType = "condition_text"
      text.rectIndex = i
      rect.hover(hoverStart, hoverEnd)
      text.hover(hoverStart, hoverEnd)

      i++

      conditionRects.push(rect)


  drawTeams = ->

    numberOfTeams = _.size(data)
    numberOfTeamsPerLine = Math.ceil(numberOfTeams / 2)
    widthPerTeam = (CONDITIONS_RECT_WIDTH + 2 * 300) / numberOfTeamsPerLine

    i = 0
    for city, team of data

      # need to adapt some things for the bottom row
      if i < numberOfTeamsPerLine
        ellipseY = CONDITIONS_RECT_Y - 200
      else
        ellipseY = CONDITIONS_RECT_Y + CONDITIONS_RECT_HEIGHT + 200

      ellipseX = (CONDITIONS_RECT_X - 300) + ((i % numberOfTeamsPerLine) * widthPerTeam) + widthPerTeam / 2
      ellipse = paper.ellipse(ellipseX, ellipseY, TEAM_ELLIPSE_RX, TEAM_ELLIPSE_RY)
      ellipse.attr(fill: "#FFE073", stroke: "#FFC700")
      text = paper.text(ellipseX, ellipseY, team.name)

      ellipse.hoverType = "team"
      text.hoverType = "team_text"
      text.ellipseIndex = i
      ellipse.hover(hoverStart, hoverEnd)
      text.hover(hoverStart, hoverEnd)

      teamEllipses.push(ellipse)
      i++


  drawPercentageLines = ->

    numberOfTeams = _.size(data)
    numberOfTeamsPerLine = Math.ceil(numberOfTeams / 2)

    i = 0
    for city, team of data

      # need to adapt some things for the bottom row
      if i < numberOfTeamsPerLine
        yShift = 0
        yMultiplier = -1
      else
        yShift = CONDITIONS_RECT_HEIGHT
        yMultiplier = 1

      j = 0
      for condition, value of team.conditions

        if value < 0 then continue

        path = paper.path([
          [
            "M"
            conditionRects[j].attr("x") + conditionRects[j].attr("width") / 2
            conditionRects[j].attr("y") + yShift
          ]
          [
            "C"
            conditionRects[j].attr("x") + conditionRects[j].attr("width") / 2
            conditionRects[j].attr("y") + yShift + yMultiplier * 75
            teamEllipses[i].attr("cx")
            teamEllipses[i].attr("cy") - yMultiplier * 75
            teamEllipses[i].attr("cx")
            teamEllipses[i].attr("cy")
          ]
        ])

        deviation = Math.abs(team.p - value) / preprocessor.getMaxValue()
        color = Raphael.hsl((Math.pow(1 - deviation, 2)) * 120, 100, 50)
        path.attr({"stroke-width": Math.max(1, Math.pow(deviation, 2) * LINE_WIDTH), "stroke": color})
        path.toBack()
        path.hoverType = "line"
        path.hover(hoverStart, hoverEnd)
        percentageLines.push({line: path, source: i, target: j})
        j++
      i++


  drawLegend = ->

    width = 30
    height = 120
    paper.rect(10, 10, width, height)
      .attr({"fill": "90-#f00:0-#fd0:30-#ff0:50-#df0:70-#0f0:100", "stroke-width": 0.1})
    paper.text(60 + width, 10, "0% deviation")
    paper.text(60 + width, 10 + height, "100% deviation")


  preprocessor = new Preprocessor()
  preprocessor.setData(dataset)
  preprocessor.preprocessData()

  data = preprocessor.getPercentageData()

  console.debug "Dataset:", data

  drawConditionRects()
  drawTeams()
  drawPercentageLines()
  drawLegend()

)