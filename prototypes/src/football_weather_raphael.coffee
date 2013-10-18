require(["libs/raphael-min", "libs/lodash.min", "football_data_2012"], (Raphael, underscoreDummy, {data}) ->
  console.log "Football data:", data
  WIDTH = 1200
  HEIGHT = 1000
  CONDITIONS_RECT_WIDTH = 500
  CONDITIONS_RECT_HEIGHT = 50
  CONDITIONS_RECT_X = 400
  CONDITIONS_RECT_Y = 400
  TEAM_ELLIPSE_Y = CONDITIONS_RECT_Y - 200
  TEAM_ELLIPSE_RX = 50
  TEAM_ELLIPSE_RY = 25
  LINE_WIDTH = 50

  paper = Raphael("chart", WIDTH, HEIGHT)

  data = [
    {
      name: "Fc Plattner"
      p: 0.5
      conditions: {
        rain: 0.75
        snow: 0.6
        sun: 0
        cold: 0.7
        mild: 0.9
        hot: 0.95
      }
    },
    {
      name: "Fc Hirschfeld"
      p: 0.5
      conditions: {
        rain: 0.8
        snow: 0.75
        sun: 0.1
        cold: 0.85
        mild: 0.45
        hot: 0.04
      }
    }
  ]

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

    rectWidth = CONDITIONS_RECT_WIDTH / _.size(data[0].conditions)
    rectX = CONDITIONS_RECT_X
    rectY = CONDITIONS_RECT_Y

    i = 0
    for key,value of data[0].conditions
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

    numberOfTeams = data.length
    widthPerTeam = (CONDITIONS_RECT_WIDTH) / numberOfTeams
    ellipseY = TEAM_ELLIPSE_Y

    for team, i in data

      ellipseX = CONDITIONS_RECT_X + (i * widthPerTeam) + widthPerTeam / 2
      ellipse = paper.ellipse(ellipseX, ellipseY, TEAM_ELLIPSE_RX, TEAM_ELLIPSE_RY)
      ellipse.attr(fill: "#FFE073", stroke: "#FFC700")
      text = paper.text(ellipseX, ellipseY, team.name)

      ellipse.hoverType = "team"
      text.hoverType = "team_text"
      text.ellipseIndex = i
      ellipse.hover(hoverStart, hoverEnd)
      text.hover(hoverStart, hoverEnd)

      teamEllipses.push(ellipse)


  drawPercentageLines = ->

    for team, i in data
      j = 0
      for condition, value of team.conditions

        path = paper.path([
          ["M", conditionRects[j].attr("x") + conditionRects[j].attr("width") / 2, conditionRects[j].attr("y")]
          ["S", conditionRects[j].attr("x") + conditionRects[j].attr("width") / 2, teamEllipses[i].attr("cy"), teamEllipses[i].attr("cx"), teamEllipses[i].attr("cy")]
        ])
        deviation = Math.abs(team.p - value)
        color = Raphael.hsl((Math.pow(1 - deviation, 2)) * 120, 100, 50)
        path.attr({"stroke-width": Math.max(1, Math.pow(deviation, 2) * LINE_WIDTH), "stroke": color})
        path.toBack()
        path.hoverType = "line"
        path.hover(hoverStart, hoverEnd)
        percentageLines.push({line: path, source: i, target: j})
        j++


  drawLegend = ->

    width = 30
    height = 120
    paper.rect(CONDITIONS_RECT_X + CONDITIONS_RECT_WIDTH + 50, TEAM_ELLIPSE_Y, width, height)
      .attr("fill", "90-#f00:0-#fd0:30-#ff0:50-#df0:70-#0f0:100")
    paper.text(CONDITIONS_RECT_X + CONDITIONS_RECT_WIDTH + 100 + width, TEAM_ELLIPSE_Y, "0% Abweichung")
    paper.text(CONDITIONS_RECT_X + CONDITIONS_RECT_WIDTH + 100 + width, TEAM_ELLIPSE_Y + height, "100% Abweichung")


  drawConditionRects()
  drawTeams()
  drawPercentageLines()
  drawLegend()

)