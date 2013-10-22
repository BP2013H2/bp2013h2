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




  class CarData

    constructor: ->


    retrieveData: ->

      @retrieveModels()

    retrieveModels: ->

      year = 2000

      allModels = []

      i = 0

      for aMake in carMakes.dataset
        console.log("aMake.make_id",  aMake.make_id)
        make = aMake.make_id
        

        $.ajax({"url": "http://www.carqueryapi.com/api/0.3/?callback=data&cmd=getModels&make=#{make}&year=#{year}&sold_in_us=", dataType: "jsonp"})
          .done( (data) ->
            
            console.log("this", data.Models)

            allModels[i++] = data.Models

            window.allModels = allModels

          ).fail( ->
            console.error("error")
          )


      return



    retrieveManufactors: ->

      # already fetched
      return
      interestingCarManufacturers = []

      years = (x for x in [1900..2010] by 10)

      for aYear in years

        $.ajax({"url": "http://www.carqueryapi.com/api/0.3/?callback=data&cmd=getMakes&year=#{aYear}", dataType: "jsonp"})
          .done( (data) ->
            # data = [ {make_country : "UK", "make_is_common" : 0, "make_display" : "Acura" } ]

            interestingCarManufacturers[aYear] = []
            for d in data.Makes
              if d.make_is_common == "1"
                interestingCarManufacturers[aYear].push(d)

            console.log aYear, interestingCarManufacturers[aYear]

          ).fail( -> 
            console.log("error")
          )

      window.interestingCarManufacturers = interestingCarManufacturers

  # (new CarData).retrieveData()


  console.log("popularMovies", popularMovies)
  
  getColor = d3.scale.category20c()
  getColorCategory = d3.scale.category10()

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

      console.log("data", data)

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
          console.log "d", d
          d.position.x + 20
        )
        .attr("y", (d, i) => d.position.y + @HEIGHT / 2 )
        .attr("fill", "#ffffff")
      # <text x="20" y="20" font-family="sans-serif" font-size="20px" fill="red">Hello!</text>

      console.log "rects", rects

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
      # if @data == null

      # @data = {
      #   "entityCategories": [[], [], []],
      #   "percentages": [0, 10, 90]
      #   }

      newData = []

      i = 0

      while i < @data.entityCategories.length
        newData.push({
          "percentage": @data.percentages[i],
          "entities": @data.entityCategories[i],
          })
        i++

      @data = newData

      @drawPie()


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
            # console.log @
            # debugger

            # description = "Data description<br/>"

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
    console.log d3.event.translate, d3.event.scale
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

  data = {
    entities: [
      {name: "Adam", gender: "male", age: 63, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 46, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 39, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 27, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 40, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 63, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 42, "votedFor": "SPD"},
      {name: "Adam", gender: "male", age: 19, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 25, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 65, "votedFor": "Piraten"},
      {name: "Adam", gender: "male", age: 86, "votedFor": "CDU"},
      {name: "Adam", gender: "female", age: 35, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 45, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 51, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 78, "votedFor": "Piraten"},
      {name: "Adam", gender: "male", age: 38, "votedFor": "Piraten"},
      {name: "Adam", gender: "male", age: 69, "votedFor": "Grüne"},
      {name: "Adam", gender: "male", age: 21, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 74, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 86, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 38, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 44, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 20, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 19, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 18, "votedFor": "CDU"},
      {name: "Adam", gender: "female", age: 23, "votedFor": "CDU"},
      {name: "Adam", gender: "female", age: 64, "votedFor": "Sonstige"},
      {name: "Adam", gender: "female", age: 64, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 73, "votedFor": "SPD"},
      {name: "Adam", gender: "male", age: 60, "votedFor": "CDU"},
      {name: "Adam", gender: "female", age: 29, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 72, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 75, "votedFor": "CDU"},
      {name: "Adam", gender: "female", age: 18, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 41, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 45, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 33, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 86, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 23, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 72, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 39, "votedFor": "CDU"},
      {name: "Adam", gender: "male", age: 29, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 64, "votedFor": "Sonstige"},
      {name: "Adam", gender: "female", age: 48, "votedFor": "Grüne"},
      {name: "Adam", gender: "female", age: 24, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 35, "votedFor": "SPD"},
      {name: "Adam", gender: "female", age: 22, "votedFor": "Piraten"},
      {name: "Adam", gender: "male", age: 35, "votedFor": "Piraten"},
      {name: "Adam", gender: "male", age: 35, "votedFor": "FDP"},
      {name: "Adam", gender: "male", age: 74, "votedFor": "Grüne"},
      {name: "Adam", gender: "female", age: 27, "votedFor": "Sonstige"},
      {name: "Adam", gender: "male", age: 79, "votedFor": "Sonstige"}
    ],

    filterFunctions: {

      gender: (el) ->

        categories = {"male": 0, "female": 1}
        return categories[el.gender]
      

      age: (el) ->

        if 18 < el.age < 30
          0
        else if el.age < 40
          1
        else if el.age < 60
          2
        else
          3
      

      votedFor: (el) ->

        categories = {"CDU": 0, "FDP": 1, "SPD": 2, "Piraten": 3, "Grüne": 4, "Sonstige": 5}
        return categories[el.votedFor]

    },

    descriptors: {

      gender: (index) ->

        categories = ["männlich", "weiblich"]
        return categories[index]
      

      age: (index) ->

        categories = ["18 - 30", "30 - 40", "40 - 60", "> 60"]
        return categories[index] + " Jahre alt"


      votedFor: (index) ->

        categories = ["CDU", "FDP", "SPD", "Piraten", "Grüne", "Sonstige"]
        return categories[index]

    }

  }


  data.entities = popularMovies.dataset
  data.filterFunctions = {

    popularity: (el) ->

      parseInt((el.popularity - 27) / 28.5)
      # parseInt(el.popularity / 100) * 100

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