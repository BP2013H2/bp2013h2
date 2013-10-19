require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3", "lodash"],  ->

  
  getColor = d3.scale.category20c()
  getColorCategory = d3.scale.category10()
  colorIndex = 0

  class Category

    WIDTH: 100
    HEIGHT: 50
    MARGIN: 25

    constructor: () ->

      @drawSquare()


    drawSquare: ->
  

      data = [{"label":"Wahlenscheidung"},
              {"label":"Ost/West"},
              {"label":"Alter"},
              {"label":"Tätigkeit"},
              {"label":"Geschlecht"},
              {"label":"Beruf"},
              {"label":"Schulabschluss"},
              {"label":"Haushaltseinkommen"}]


      for d, i in data
        d.position =
          x: i * (@WIDTH + @MARGIN)
          y: @HEIGHT

      rects = d3.select("svg").append("g")
        .selectAll("rect")
        .data(data)
        .enter()
        .append("rect")
        .attr("width", @WIDTH)
        .attr("height", @HEIGHT)
        .attr("x", (d, i) -> d.position.x )
        .attr("y", (d, i) -> d.position.y )
        .attr("fill", (d, i) -> getColorCategory(i))
        .call(d3.behavior.drag().on("drag", @drag).on("dragend", @dragend))
        # .on("mouseup", (d, i) ->
          # this.setAttributeNS(null, "pointer-events", "none");
        # )


    drag: ->

      dragTarget = d3.select(this)
      dragTarget
        .attr("x", -> d3.event.dx + +dragTarget.attr("x"))
        .attr("y", -> d3.event.dy + +dragTarget.attr("y"))
                

    dragend: ->

      dragTarget = d3.select(this)    
      dragTarget
        .attr("x", (d, i) -> d.position.x)
        .attr("y", (d, i) -> d.position.y)

      infinitePie.stackPie()


  class Pie

    WIDTH: 50

    constructor: (@innerRadius, @outerRadius, @startAngle = 0, @endAngle = 2 * Math.PI) ->
      
      @drawPie()


    drawPie: ->

      @data = [{"label":"one", "value":20},
               {"label":"two", "value":50},
               {"label":"three", "value":30}]


      pie = d3.layout.pie().value( (d) -> d.value ).startAngle(@startAngle).endAngle(@endAngle)
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
          .on("mouseleave", (d, i) ->
            d3.select(this).attr("fill-opacity", 1)
          )
          .on("mouseup", (d, i) ->
            infinitePie.stackPie()
          )
          .transition()
          .attr("d", arc)
          .attr("fill", (d, i) -> getColor(colorIndex++))

    drag: ->

      # console.log "drag of pie"
      dragTarget = d3.select(this)
      dragTarget
        .attr("x", -> d3.event.dx + +dragTarget.attr("x"))
        .attr("y", -> d3.event.dy + +dragTarget.attr("y"))
                

    dragend: ->

      # console.log "dragend of pie"
      dragTarget = d3.select(this)
      dragTarget
        .attr("x", (d, i) -> d.position.x)
        .attr("y", (d, i) -> d.position.y)


      # captions doesn't work?

      # arcs.append("svg:text")
      #     .attr("transform", (d) ->
      #         d.innerRadius = 0
      #         d.outerRadius = 100
      #         return "translate" + arc.centroid(d) + ")"
      #     )
      #     .attr("text-anchor", "middle")
      #     .text((d, i) => data[i].label)

    stackPie: ->

      
      # @data = [{"label":"one", "value":20},
      #          {"label":"two", "value":50},
      #          {"label":"three", "value":30}]

      slices = @arcContainer.selectAll("g.slice")
      data = slices.data()

      newPies = []

      slices.each( (d, i) => 
        
        startAngle = d.startAngle
        endAngle = d.endAngle
        newPie = new Pie(@outerRadius, @outerRadius + @WIDTH, startAngle, endAngle)
        newPies.push(newPie)
      )

      return newPies

    getBiggestRadius: ->

      return @outerRadius

 

  class InfinitePie

    constructor : (@data) ->

      @layers = [[new Pie(50, 100)]]
      @updatePosition()


    stackPie : ->

      newPies = []

      for eachPie in _.last(@layers)
        pies = eachPie.stackPie()
        newPies = newPies.concat(pies)

      @layers.push(newPies)
      
      @updatePosition()

      return @


    getBiggestRadius: ->

      return _.last(@layers)[0].outerRadius

    updatePosition: ->

      biggestRadius = @getBiggestRadius()
      pieContainer.transition().duration(100).attr("transform", "translate(
        #{biggestRadius},
        #{biggestRadius + marginTop}
      )")


  marginTop = 150

  pieContainer = d3.select("svg").append("g")
  infinitePie = new InfinitePie()
  

  c = new Category()


)