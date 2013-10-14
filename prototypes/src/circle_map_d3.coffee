require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->
  
  duration = 250
  amount = 299
  width = 3
  height = 100
  increasedHeight = 150
  radius = 250
  offset = radius + increasedHeight

  fitMapToCircle = ->
    map = d3.select("#map")
    mapBB = map[0][0].getBBox()
    h = mapBB.height
    w = mapBB.width
    magicIncreasement = 1.25
    scale = magicIncreasement * Math.sqrt(2)*radius / h

    diff = scale*(h - w)

    offsetMap = (offset - radius/Math.sqrt(2)) / magicIncreasement
    map.attr("transform",
      "translate(#{offsetMap + diff/2}, #{offsetMap})
       scale(#{scale}, #{scale})")

  genericMouseHandler = (evt, elementType) ->

    return (data, index, indirect) ->
      svgElement = d3.select("##{elementType}_#{index}")

      if elementType == "line"
        attribute = {"height" : if evt == "over" then increasedHeight else data * height / 100 }
      else
        attribute = {"fill" :  if evt == "over" then "blue" else "white" }

      svgElement.transition()
        .delay(if evt + elementType == "outline" then duration/2 else 0)
        .duration(duration)
        .attr(attribute)

      unless indirect
        id = svgElement.attr("id").slice(elementType.length + 1)
        otherElementType = if elementType == "line" then "county" else "line"

        genericMouseHandler(evt, otherElementType)(d3.select("##{otherElementType}_#{id}").data(), id, true)


  getDataset = ->
    
    dataset = []
    for i in [0...amount]
      dataset.push(Math.random() * 100)

    dataset.sort( (a, b) -> a - b )
    return dataset

  
  drawLines = (dataset) ->

    d3.select("svg").append("g")
      .selectAll("rect")
      .data(dataset)
      .enter()
      .append("rect")
      .attr("width", width)
      .attr("height", (d, i) -> d * height / 100)
      .attr("fill", "black")
      .attr("transform", (d, i) ->
        angleRad = i * 2 * Math.PI / amount
        angleDegree = i * 360 / amount

        marginTop = Math.cos(angleRad) * radius + offset
        marginRight = - Math.sin(angleRad) * radius + offset

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