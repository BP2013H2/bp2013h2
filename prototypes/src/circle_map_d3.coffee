require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->
  
  DURATION = 250
  AMOUNT = 299
  WIDTH = 3
  HEIGHT = 100
  INCREASEDHEIGHT = 150
  RADIUS = 250
  OFFSET = RADIUS + INCREASEDHEIGHT

  fitMapToCircle = ->
    map = d3.select("#map")
    mapBB = map[0][0].getBBox()
    h = mapBB.height
    w = mapBB.width
    magicIncreasement = 1.25
    scale = magicIncreasement * Math.sqrt(2)*RADIUS / h

    diff = scale*(h - w)

    offsetMap = (OFFSET - RADIUS/Math.sqrt(2)) / magicIncreasement
    map.attr("transform",
      "translate(#{offsetMap + diff/2}, #{offsetMap})
       scale(#{scale}, #{scale})")

  genericMouseHandler = (evt, elementType) ->

    return (data, index, indirect) ->
      svgElement = d3.select("##{elementType}_#{index}")

      if elementType == "line"
        attribute = {"height" : if evt == "over" then INCREASEDHEIGHT else data * HEIGHT / 100 }
      else
        attribute = {"fill" :  if evt == "over" then "blue" else "white" }

      svgElement.transition()
        .delay(if evt + elementType == "outline" then DURATION/2 else 0)
        .duration(DURATION)
        .attr(attribute)

      unless indirect
        id = svgElement.attr("id").slice(elementType.length + 1)
        otherElementType = if elementType == "line" then "county" else "line"

        genericMouseHandler(evt, otherElementType)(d3.select("##{otherElementType}_#{id}").data(), id, true)


  getDataset = ->
    
    dataset = []
    for i in [0...AMOUNT]
      dataset.push(Math.random() * 100)

    dataset.sort( (a, b) -> a - b )
    return dataset


  
  drawLines = (dataset) ->

    d3.select("svg").append("g")
      .selectAll("rect")
      .data(dataset)
      .enter()
      .append("rect")
      .attr("width", WIDTH)
      .attr("height", (d, i) -> d * HEIGHT / 100)
      .attr("fill", "black")
      .attr("transform", (d, i) ->
        angleRad = i * 2 * Math.PI / AMOUNT
        angleDegree = i * 360 / AMOUNT

        marginTop = Math.cos(angleRad) * RADIUS + OFFSET
        marginRight = - Math.sin(angleRad) * RADIUS + OFFSET

        return "translate( #{marginRight}, #{marginTop} )   rotate(#{angleDegree})"
      )
      .attr("id", (d, i) -> return "line_" + i)
      .on("mouseover", genericMouseHandler("over", "line"))
      .on("mouseout", genericMouseHandler("out", "line"))

  addCountyMouseEvents = (dataset) ->

    d3.selectAll("path").data(dataset)
      .on("mousemove", genericMouseHandler("over", "county"))
      .on("mouseout", genericMouseHandler("out", "county"))

  setUp = ->

    dataset = getDataset()
    drawLines(dataset)
    addCountyMouseEvents(dataset)

    fitMapToCircle()

  setUp()

)