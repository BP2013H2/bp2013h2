require.config(
  baseUrl: 'js/libs'
)

require(["jquery", "d3.v3"],  ->

  
  getColor = d3.scale.category20c()
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
        .attr("fill", (d, i) -> getColor(i))
        .call(d3.behavior.drag().on("drag", drag).on("dragend", dragend))


    drag = ->

      dragTarget = d3.select(this)
      dragTarget
        .attr("x", -> d3.event.dx + +dragTarget.attr("x"))
        .attr("y", -> d3.event.dy + +dragTarget.attr("y"))
                

    dragend = ->

      dragTarget = d3.select(this)
      dragTarget
        .attr("x", (d, i) -> d.position.x)
        .attr("y", (d, i) -> d.position.y)

        
      



  class InfinitePie

    WIDTH: 50

    constructor: (@innerRadius, @outerRadius, @startAngle = 0, @endAngle = 2 * Math.PI) ->
      
      @drawPie()


    drawPie: ->

      @data = [{"label":"one", "value":20},
               {"label":"two", "value":50},
               {"label":"three", "value":30}]


      pie = d3.layout.pie().value( (d) -> d.value ).startAngle(@startAngle).endAngle(@endAngle)
      arc = d3.svg.arc().outerRadius(@outerRadius).innerRadius(@innerRadius)

      @arcContainer = pieContainer
        .append("g")
        .data([@data])

      arcs = @arcContainer
              .selectAll("g.slice")
              .data(pie)
              .enter()
              .append("g")
              .attr("class", "slice")

      arcs.append("path")
          .attr("d", arc)
          .attr("fill", (d, i) -> getColor(colorIndex++))


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

      pies = []

      slices.each( (d, i) => 
        
        startAngle = d.startAngle
        endAngle = d.endAngle
        newPie = new InfinitePie(@outerRadius, @outerRadius + @WIDTH, startAngle, endAngle)
        pies.push(newPie)
      )

      pieCollection = new PieCollection(pies)
      return pieCollection

    getBiggestRadius: ->

      return @outerRadius

 
  class PieCollection

    constructor : (@pies) ->

    stackPie : ->

      newPies = []

      for eachPie in @pies
          newPies.push(eachPie.stackPie())

      pieCollection = new PieCollection(newPies)
      return pieCollection

    getBiggestRadius: ->

      biggestRadius = 0

      for eachPie in @pies
        biggestRadius = Math.max(biggestRadius, eachPie.getBiggestRadius())

      return biggestRadius


  pieContainer = d3.select("svg").append("g")
    

  pie = new InfinitePie(50, 100)
  pieCollection = pie.stackPie()#.stackPie().stackPie().stackPie()

  biggestRadius = pieCollection.getBiggestRadius()

  marginTop = 150
  
  window.pieCollection = pieCollection

  pieContainer.attr("transform", "translate(#{biggestRadius}, #{biggestRadius + marginTop})")

  HEIGHT = 500


  zoomed = ->
    # pieContainer.translate(d3.event.translate).scale(d3.event.scale);

    console.log "d3.event.translate", d3.event.translate
    console.log "d3.event.scale", d3.event.scale

    # g.selectAll("path").attr("d", path);


  # zoom = d3.behavior.zoom()
  #   # .translate([100, 100] )
  #   # .scale(-> console.log "scale", arguments )
  #   # .scaleExtent(-> console.log "scaleExtent", arguments )
  #   .on("zoom", zoomed)

  # # pieContainer.call(zoom, zoomed)
  # pieContainer.call(d3.behavior.zoom().on("zoom"), zoomed);

    # .translate(pieContainer.translate())
    # .scale(pieContainer.scale())
    # .scaleExtent([HEIGHT, 8 * HEIGHT])
    # .on("zoom", zoomed);

  c = new Category()



)