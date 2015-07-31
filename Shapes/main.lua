
rectangle = display.newRect(110, 100, 50, 50)
rectangle.translate( rectangle, 50, 50 )
--using . needs to pass reference as parameter
rectangle:setFillColor(255, 255, 255)
rectangle:translate( 50, 50 )
--using : its is not necessary

--changing object properties
rectangle.alpha = .65
rectangle.height = 200
rectangle.width = 100
rectangle.rotation = 45

--changing through methods
rectangle:rotate( 45 )
rectangle:scale( .8 , .8 ) --Changes the scalar size rectangle in 80% of actual size for width and height
rectangle:translate(10,45)
--rectangle:removeSelf() removes the object and frees memory

