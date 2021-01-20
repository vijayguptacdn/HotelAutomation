class Hotel

  def default_state(floors, main_cooridoors, sub_cooridoors)
  	@floors = floors
  	@main_cooridoors = main_cooridoors
  	@sub_cooridoors = sub_cooridoors
  	@hotel = {}
  	(1..floors).each do |floor|
  		@hotel["floor#{floor}"] = set_cooridoors(main_cooridoors, sub_cooridoors)
  	end
  	@total_power_consume = (@main_cooridoors *15)+(@sub_cooridoors *10)
  	#puts @hotel
  	defalut_hotel_state
  	
  end

  def defalut_hotel_state
  	@hotel.each do |floor, cooridoor|
  		puts floor
  		cooridoor['main_cooridoors'].each do |main_cori|
  			main_cori.each do |key ,value|
  				puts "Main cooridoors: #{key}, Light #{key}: #{value[:light][:status]}, AC: #{value[:AC][:status]}"
  			end
  		end
  		cooridoor['sub_cooridoors'].each do |sub_cori|
  			sub_cori.each do |key, value|
  				puts "Sub cooridoors: #{key}, Light #{key}: #{value[:light][:status]}, AC: #{value[:AC][:status]}"
  			end
  		end
  	end
  end

  def set_cooridoors(main_cooridoors, sub_cooridoors)
  	mc_sc_hash, mc_array, sc_array = {}, [], []
  	(1..main_cooridoors).each do |mc|
  		mc_hash= {}
			mc_hash["#{mc}"] = {
				"light": {
					"count": 1,
					"consume": 5,
					"status": "ON"
				},
				"AC": {
					"count": 1,
					"consume": 10,
					"status": "ON"
				}
			}
			mc_array << mc_hash
		 	mc_sc_hash['main_cooridoors'] = mc_array
		end

		(1..sub_cooridoors).each do |sc|
			sc_hash = {}
			sc_hash["#{sc}"] = {
				"light": {
					"count": 1,
					"consume": 5,
					"status": "OFF"
				},
				"AC": {
					"count": 1,
					"consume": 10,
					"status": "ON"
				}
			}
			sc_array <<  sc_hash 
			mc_sc_hash['sub_cooridoors'] = sc_array
		end
	  mc_sc_hash
  end


  def movement_in_cooridoor(any_movement)
  	if any_movement == 1
  		default_state(@floors, @main_cooridoors, @sub_cooridoors)
  		puts "Moment on floor"
  		floor = STDIN.gets.chomp.to_i 
  		puts "Moment on sub cooridoor"
  		sub_coor = STDIN.gets.chomp.to_i

  	  update_floor_status(floor, sub_coor)
      t1 = Time.now 
  		puts "Enter 1 to continue or for exit enter 0"
	  	moment_value = STDIN.gets.chomp.to_i
  		if Time.now >= t1 + 10
  			puts "Time out"
  			default_state(@floors, @main_cooridoors, @sub_cooridoors)
  		else 
	  		movement_in_cooridoor(moment_value)
  		end 
  	else
  		default_state(@floors, @main_cooridoors, @sub_cooridoors)
  	end
  end


  def update_floor_status(floor, sub_coor)
  	puts "Total power consume #{@total_power_consume} units"

    @hotel["floor#{floor}"]['sub_cooridoors'].each do |sub_cooridoor|
    	sub_cooridoor["#{sub_coor}"][:light][:status] = "ON" unless sub_cooridoor["#{sub_coor}"].nil?
    end
    
    sub_light_on, sub_ac_on = 0, 0
    @hotel["floor#{floor}"]['sub_cooridoors'].each_with_index do |sub_cooridoor, index|
    	sub_light_on += 1 if sub_cooridoor["#{index.to_i+1}"][:light][:status] == "ON"
    	sub_ac_on += 1 if sub_cooridoor["#{index.to_i+1}"][:AC][:status] == "ON"
    end
    
    floor_power_consume = (@main_cooridoors*5) + (@main_cooridoors *10) + (sub_light_on*5) + (sub_ac_on*10)
    if floor_power_consume > @total_power_consume
    	@hotel["floor#{floor}"]['sub_cooridoors'].each_with_index do |sub_cooridoor, index|
    		sub_cooridoor["#{index.to_i+1}"][:AC][:status] = "OFF" if  sub_cooridoor["#{index.to_i+1}"][:light][:status] == "OFF"
    	end
    end
    defalut_hotel_state
  end
end


hotel = Hotel.new
puts "Enter number of Floors"
floors = STDIN.gets.chomp.to_i
puts "Enter number of Main cooridoors"
main_cooridoors = STDIN.gets.chomp.to_i
puts "Enter number of Sub cooridoors"
sub_cooridoors = STDIN.gets.chomp.to_i

#Set the default stats of hotel floors.
hotel.default_state(floors, main_cooridoors, sub_cooridoors)

puts "Any movement in cooridoor press 1 else 0"
any_movement = STDIN.gets.chomp.to_i
hotel.movement_in_cooridoor(any_movement)

