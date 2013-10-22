require.config(
  baseUrl: 'js'
)

require(["libs/jquery", "libs/d3.v3", "libs/lodash", "data/car_makes", "data/popular_movies"],  (_a, _b, _c, carMakes, popularMovies) ->


  colors = [
   ["#1f77b4", "#3182bd", "#6baed6", "#9ecae1", "#c6dbef"],
   ["#ff7f0e", "#e6550d", "#fd8d3c", "#fdae6b", "#fdd0a2"],
   ["#2ca02c", "#31a354", "#74c476", "#a1d99b", "#c7e9c0"],
   ["#9467bd", "#7b4173", "#a55194", "#ce6dbd", "#de9ed6"],
   ["#8c564b", "#8c6d31", "#bd9e39", "#e7ba52", "#e7cb94"],
   ["#7f7f7f", "#636363", "#969696", "#bdbdbd", "#d9d9d9"],
   ["#bcbd22", "#8c6d31", "#bd9e39", "#e7ba52", "#e7cb94"],
   ["#17becf", "#9edae5", "#0f7f8a", "#1294a1", "#14a9b8"]
  ]

 
  getColor = (c, i=0) ->
    c = (c + colors.length)% colors.length
    i = (i + colors[c].length) % colors[c].length
    return colors[c][i]

  getColorCategory = (c) ->
    c = (c + colors.length) % colors.length
    return colors[c][0]

  colorIndex = 0

  class Category

    WIDTH: 150
    HEIGHT: 50
    MARGIN: 25

    constructor: (@data) ->

      @drawSquare()


    drawSquare: ->
  
      data = []
      for k, v of @data.descriptors
        data.push({"label" : v()})

      for d, i in data
        d.position =
          x: i * (@WIDTH + @MARGIN)
          y: @HEIGHT


      rectGroup = svg.append("g")
      rects = rectGroup
        .selectAll("rect")
        .data(data)
        .enter()
        .append("rect")

        .attr("width", @WIDTH)
        .attr("height", @HEIGHT)
        .attr("x", (d, i) -> d.position.x )
        .attr("y", (d, i) -> d.position.y )
        .attr("fill", (d, i) -> getColorCategory(i))
        .attr("id", (d, i) -> return "category_" + i)
        
        .on("mouseenter", (d, i) ->
          d3.select(this).attr("fill-opacity", 0.8) 
        )
        .on("mouseup", (d, i) =>
          @unuse(d3.select(` this `))
        )
        .call(d3.behavior.drag().on("drag", @drag).on("dragend", @dragend))
      
      rectGroup
        .selectAll("text")
        .data(data)
        .enter()
        .append("text")

        .text( (d, i) -> d.label )
        .attr("x", (d, i) =>
          d.position.x + 20
        )
        .attr("y", (d, i) => d.position.y + @HEIGHT / 2 )
        .attr("fill", "#ffffff")


    use: (el) ->

      el.transition().duration(500).attr("fill-opacity", 0.3)
      @used = true


    unuse: (el) ->

      el.attr("fill-opacity", 1) 
      @used = false

    drag: ->

      dragTarget = d3.select(this)
      dragTarget
        .attr("x", -> d3.event.dx + +dragTarget.attr("x"))
        .attr("y", -> d3.event.dy + +dragTarget.attr("y"))
              

    dragend: (d, i) ->

      dragTarget = d3.select(this)    
      dragTarget
        .attr("x", (d, i) -> d.position.x)
        .attr("y", (d, i) -> d.position.y)

      unless @used
        infinitePie.stackPie(i)


  class Pie

    WIDTH: 50

    constructor: (@data, @descriptor, @attributes, @innerRadius, @outerRadius, @filterIndex, @startAngle = 0, @endAngle = 2 * Math.PI) ->
      
      @used = false      

      @restructureData()

      @drawPie()


    restructureData: ->

      newData = []

      i = 0

      while i < @data.entityCategories.length
        newData.push({
          "percentage": @data.percentages[i],
          "entities": @data.entityCategories[i],
          })
        i++

      @data = newData


    drawPie: ->

      pie = d3.layout.pie().value( (d) -> d.percentage ).startAngle(@startAngle).endAngle(@endAngle).sort(null)
      arc = d3.svg.arc().outerRadius(@outerRadius).innerRadius(@innerRadius)

      @pieFn = pie

      @arcContainer = pieContainer
        .append("g")
        .data([@data])

      arcs = @arcContainer
              .selectAll("g.slice")
              .data(pie)
              .enter()
              .append("g")
              .attr("class", "slice")

      arcs
          .append("path")
          .on("mouseenter", (d, i) ->
            d3.select(this).attr("fill-opacity", 0.8)
          )
          .on("mouseover", (d, i) =>

            if @attributes.length > 0 
              caption = @descriptor(d.data.entities[0])
              description = "<ul><li>" + @attributes.slice(1).concat(caption).join(" </li><li> ") + "</li></ul>"

              div.transition()
                 .duration(200)
                 .style("opacity", .9)
              div.html(description)
                 .style("left", (d3.event.pageX) + "px")
                 .style("top", (d3.event.pageY - 28) + "px")
            else
              console.warn "no attributes"
          )
          .on("mouseout", (d) ->
            div.transition()
               .duration(500)
               .style("opacity", 0)
          )
          .on("mouseleave", (d, i) ->
            d3.select(this).attr("fill-opacity", 1)
          )
          .on("dblclick", (d, i) =>
            infinitePie.unstackPie()
          )
          .transition()
          .attr("d", arc)
          .attr("fill", (d, i) => getColor(@filterIndex, i))


    filterData: (categoryIndex, filterFunction) ->

      partitionedData = []
      percentages = []

      elements = @data[categoryIndex].entities


      if !elements or elements.length == 0
        console.error "elements empty?"

      for d in elements

        bucketIndex = filterFunction(d)
        bucket = partitionedData[bucketIndex]

        if bucket
          bucket.push(d)
          percentages[bucketIndex]++
        else
          partitionedData[bucketIndex] = [d]
          percentages[bucketIndex] = 1

      partitionedData = _.compact(partitionedData)
      percentages = _.compact(percentages)

      for aValue, index in percentages
        percentages[index] = Math.round(aValue / elements.length * 100)
   

      model = {
        "entityCategories" : partitionedData,
        "percentages" : percentages
      }

      return model


    stackPie: (filterFunction, descriptorFunction, filterIndex) ->

      slices = @arcContainer.selectAll("g.slice")
      newPies = []

      slices.each( (d, i) => 
        
        filteredData = @filterData(i, filterFunction)

        startAngle = d.startAngle
        endAngle = d.endAngle
        caption = @descriptor(d.data.entities[0])
        newPie = new Pie(filteredData, descriptorFunction, @attributes.concat(caption), @outerRadius, @outerRadius + @WIDTH, filterIndex, startAngle, endAngle)
        newPies.push(newPie)
      )

      return newPies

    remove: ->

      @arcContainer.remove()

 

  class InfinitePie

    constructor : (@data) ->

      new Category(@data)

      @filterFunctionsToUse = []
      for k, v of @data.filterFunctions
        @filterFunctionsToUse.push(k)

      @currentFilterIndex = 0


      model = {
        "entityCategories": [@data.entities],
        "percentages": [100]
        }


      @layers = [[new Pie(model, (-> ""), [], 50, 100, -1)]]
      @updatePosition()


    getFilterFunctions: (index) ->

      if @filterFunctionsToUse.length > index
        identifier = @filterFunctionsToUse[index]

        return [@data.filterFunctions[identifier], @data.descriptors[identifier]]

      return [null, null]

    getNextFilterFunction: ->

      if @filterFunctionsToUse.length > @currentFilterIndex
        identifier = @filterFunctionsToUse[@currentFilterIndex++]

        return [@data.filterFunctions[identifier], @data.descriptors[identifier]]

      return null


    stackPie : (filterIndex) ->


      newPies = []
      [currentFilter, currentDescriptor] = @getFilterFunctions(filterIndex)

      if currentFilter

        for eachPie in _.last(@layers)

          pies = eachPie.stackPie(currentFilter, currentDescriptor, filterIndex)
          newPies = newPies.concat(pies)

        @layers.push(newPies)
        
        @updatePosition()

      return @

    unstackPie: ->

      if @layers.length > 1

        for eachPie in _.last(@layers)

          eachPie.remove()

        @layers = @layers.slice(0, -1)

        @updatePosition()
        @currentFilterIndex--

    getBiggestRadius: ->

      return _.last(@layers)[0].outerRadius

    updatePosition: ->

      biggestRadius = @getBiggestRadius()
      pieContainer.transition().duration(100).attr("transform", "translate(
        #{biggestRadius},
        #{biggestRadius + marginTop}
      )")

  zoom = ->
    translate = [d3.event.translate[0] * d3.event.scale, d3.event.translate[1] * d3.event.scale]
    zoomContainer.attr("transform", "translate(" + translate + ")scale(" + d3.event.scale + ")")

  svg = d3.select("svg")
  div = d3.select("body").append("div")   
    .attr("class", "tooltip")               
    .style("opacity", 0);

  zoomContainer = svg.append("g")
    .attr("height", 800)
    .attr("width", 850)

  pieContainer = zoomContainer.append("g")


  zoomContainer
    .call(d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", zoom)).on("dblclick.zoom", null)

  marginTop = 150

  data = {}

  data.entities = popularMovies.dataset
  data.filterFunctions = {

    popularity: (el) ->

      parseInt((el.popularity - 27) / 28.5)

    vote_average: (el) ->
      parseInt(el.vote_average)

    vote_count: (el) ->
      parseInt(el.vote_count / 100) * 100

    release_date_year: (el) ->
      parseInt(el.release_date.slice(0, 4))

    release_date_month: (el) ->
      parseInt(el.release_date.slice(5, 7))

  }

  data.descriptors = {


    popularity: (el) ->
      if el?
        "Popularity: " + data.filterFunctions.popularity(el)
      else
        "Popularity"

    vote_average: (el) ->
      if el?
        "Average Voting: " + data.filterFunctions.vote_average(el)
      else
        "Average Voting"
      
    vote_count: (el) ->
      if el?
        roundedCount = data.filterFunctions.vote_count(el)
        "Vote Count: " + roundedCount + " - " + (roundedCount + 100)
      else
        "Vote Count"

    release_date_year: (el) ->
      if el?
        "Year of Release: " + data.filterFunctions.release_date_year(el)
      else
        "Year of Release"

    release_date_month: (el) ->
      months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

      if el?
        "Month of Release: " + months[data.filterFunctions.release_date_month(el) - 1]
      else
        "Month of Release"

  }
  
  infinitePie = new InfinitePie(data)
)