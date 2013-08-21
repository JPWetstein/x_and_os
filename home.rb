require 'sinatra/base'
require 'fontaine/canvas'
require 'fontaine/bootstrap'
require 'sinatra-websocket'
require 'haml'

class Home < Sinatra::Base
  register Sinatra::Fontaine::Bootstrap::Assets
  set :server, 'thin'
  set :sockets, []
  @canvas = nil
  @state = nil
  
  get '/' do
    setup if @canvas.nil?
    
    if !request.websocket?
      haml :index
    else
      @canvas.listen(request, settings)
    end
  end
  
  
  def setup
    @canvas = Fontaine::Canvas.new("ABC", 240, 240, "tic_tac_toe_canvas") do |canvas|
    @state = 'playing'
    @moves = 0
      
      canvas.on_open do
        @player = "X"
        @board = Array.new(3){Array.new(3)}
        canvas.line_width 5
        canvas.stroke_style "blue"
        canvas.begin_path
        canvas.move_to 80, 0
        canvas.line_to 80, 240
        canvas.stroke
        canvas.move_to 160, 0
        canvas.line_to 160, 240
        canvas.stroke
        canvas.move_to 0, 80
        canvas.line_to 240, 80
        canvas.stroke
        canvas.move_to 0, 160
        canvas.line_to 240, 160
        canvas.stroke
      end
          
      canvas.on_click do |x,y|
        
        if(@state == 'playing')
          
          my_x = (x.to_i/80).to_i
          my_y = (y.to_i/80).to_i
          if @board[my_x][my_y].nil?
            @moves +=1
            @board[my_x][my_y] = @player
            draw_x = ((my_x*80)) + 15
            draw_y = ((my_y+1) *80) - 15
            canvas.font "70px Verdana"
            canvas.fill_text(@player, draw_x, draw_y)
            @state = 'winner' if check_if_winner @board, my_x, my_y, @player, canvas
            @state = 'draw' if (@state != 'winner') && (@moves >8)
            
            if(@player == "X")
              @player = "O"
            else
              @player = "X"
            end
            
          end
        end
        
        if @state == 'draw'
           canvas.font "70px Verdana"
           canvas.fill_style("white")
           canvas.fill_text("TIE", 60, 100)       
           canvas.fill_text("GAME", 20, 170)
           canvas.stroke_style("red")
           canvas.stroke_text("TIE", 60, 100)       
           canvas.stroke_text("GAME", 20, 170)
        end
        
      end
      
      
    end
    
  end
  
  def check_if_winner board, x, y, value, canvas
    winner = false
    temp = "" 
       
    (0..2).each do |i|
      temp = board[x][i]
      break if temp != value
     
      winner = true if i == 2
      
      if winner
        draw_x = (x*80) + 40
        canvas.stroke_style "red"
        canvas.begin_path
        canvas.move_to draw_x, 10 
        canvas.line_to draw_x, 230
        canvas.stroke
        return winner
      end
      #verticle line
    end
    
    (0..2).each do |i|
      temp = board[i][y]
      break if temp != value
      winner = true if i == 2
      
      if winner
        draw_y = (y*80) + 40
        canvas.stroke_style "red"
        canvas.begin_path
        canvas.move_to 10, draw_y
        canvas.line_to 230, draw_y
        canvas.stroke
        return winner
      end
      #horizontal line
    end
    
    if (x==y) || ((x==0) && (y==2)) || ((y==2) && (x==0))
      (0..2).each do |i|
        temp = board[i][i]
        break if temp != value
        winner = true if i == 2
        
        #top left to bottom right
        if winner
          draw_y = (y*80) + 40
          canvas.stroke_style "red"
          canvas.begin_path
          canvas.move_to 10, 10
          canvas.line_to 230, 230
          canvas.stroke
          return winner
        end
      end
      
      #not working... why?
      if(board[0][2]==value)&&(board[1][1]==value)&&(board[2][0]==value)
        winner = true
        
        #top right to bottom left
         if winner
          draw_y = (y*80) + 40
          canvas.stroke_style "red"
          canvas.begin_path
          canvas.move_to 10, 230
          canvas.line_to 230, 10
          canvas.stroke
          return winner
        end
      end
      
    end
    
    return winner
    
  end
end