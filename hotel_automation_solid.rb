require 'pry'
require 'timeout'

class HotelAutomationSolid
	LIGHT_POWER_CONSUME = 5
  AC_POWER_CONSUME = 10

	def initialize(floors, main_corridors, sub_corridors)
    @floors = floors
    @main_corridors = main_corridors
    @sub_corridors = sub_corridors
  end

  def default_state
    @hotel = {}
    (1..@floors).each do |floor|
      @hotel["floor#{floor}"] = set_corridors(@main_corridors, @sub_corridors)
    end
    hotel_status
  end

  def set_corridors(main_corridors, sub_corridors)
    mc_sc_hash = {}
    mc_sc_hash['main_corridors'] = corridor_dataset(main_corridors)
    mc_sc_hash['sub_corridors'] = corridor_dataset(sub_corridors, "OFF")
    mc_sc_hash
  end

  def corridor_dataset(corridors, light_status='ON', ac_status='ON')
    corridor_array = []
    (1..corridors).each do |corridor|
      corridor_hash= {}
      corridor_hash["#{corridor}"] = {
        "light": {
          "consume": LIGHT_POWER_CONSUME,
          "status": light_status
        },
        "AC": {
          "consume": AC_POWER_CONSUME,
          "status":  ac_status
        }
      }
      corridor_array << corridor_hash
    end  
    corridor_array
  end

  def hotel_status
    @hotel.each do |floor, corridor|
      puts floor
      corridor_status(corridor['main_corridors'], 'Main corridors')
      corridor_status(corridor['sub_corridors'], 'Sub corridors')
    end
  end

  def corridor_status(corridor, corridor_name)
    corridor.each do |corri|
      corri.each do |key ,value|
        puts "#{corridor_name}: #{key}, Light #{key}: #{value[:light][:status]}, AC: #{value[:AC][:status]}"
      end
    end
  end
end


class FloorPowerConsume
	MAIN_CORRIDOR_POWER_CONSUME = 15
  SUB_CORRIDOR_POWER_CONSUME = 10

	def initialize(main_corridors, sub_corridors)
		@main_corridors = main_corridors
		@sub_corridors = sub_corridors
	end

	def floor_power_consume
    return (@main_corridors * MAIN_CORRIDOR_POWER_CONSUME)+(@sub_corridors * SUB_CORRIDOR_POWER_CONSUME)
  end
end

class CorridorMovement < HotelAutomationSolid
	TIME_INTERVAL = 60
	
	def initialize(floor_power_consume, hotel, floors, main_corridors, sub_corridors)
		@total_power_consume_per_floor = floor_power_consume
		@hotel = hotel
		@main_corridors = main_corridors
		@sub_corridors = sub_corridors
		@floors = floors
	end

	def movement_in_corridor
		puts "Any movement in corridor press 1 else 0"
		begin
		  Timeout::timeout(TIME_INTERVAL) do
		    change_in_floor(STDIN.gets.chomp.to_i)
		  end
		rescue Timeout::Error => e
			puts "No movement happen in sub corridors for more than 1 minute."
		  HotelAutomationSolid.instance_method(:default_state).bind(self).call
		end
	end

	def change_in_floor(any_movement)
		case any_movement
		when 1
			puts "Movement in floor:"
      floor = STDIN.gets.chomp.to_i 
      puts "Movement in sub corridor:"
      sub_corr = STDIN.gets.chomp.to_i
      update_floor_status(floor, sub_corr)
      movement_in_corridor
    else
    	HotelAutomationSolid.instance_method(:default_state).bind(self).call
		end
	end

	def update_floor_status(floor, sub_corr)
    unless @hotel["floor#{floor}"].nil? || sub_corr > @sub_corridors
      puts "Total power consume on floor#{floor} is #{@total_power_consume_per_floor} units"

      sub_light_on, sub_ac_on = 0, 0
      @hotel["floor#{floor}"]['sub_corridors'].each_with_index do |sub_corridor, index|
        sub_corridor["#{index+1}"][:AC][:status] =  "ON" 
        sub_corridor["#{index+1}"][:light][:status] = sub_corridor["#{sub_corr}"].nil? ? "OFF" : "ON"
       
        sub_light_on += 1 if sub_corridor["#{index.to_i+1}"][:light][:status] == "ON"
        sub_ac_on += 1 if sub_corridor["#{index.to_i+1}"][:AC][:status] == "ON"
      end
      
      floor_power_consume = (@main_corridors * LIGHT_POWER_CONSUME) + (@main_corridors * AC_POWER_CONSUME) + (sub_light_on * LIGHT_POWER_CONSUME) + (sub_ac_on * AC_POWER_CONSUME)
      @hotel["floor#{floor}"]['sub_corridors'].each_with_index do |sub_corridor, index|
        sub_corridor["#{index.to_i+1}"][:AC][:status] = (floor_power_consume > @total_power_consume_per_floor ? "OFF" : "ON") if sub_corridor[sub_corr.to_s].nil?
        floor_power_consume -= AC_POWER_CONSUME if sub_corridor[sub_corr.to_s].nil?
      end
      hotel_status
    else
      puts "You have entered wrong values for floor or sub corridors"
    end
  end
end

puts "Enter number of Floors:"
floors = STDIN.gets.chomp.to_i
puts "Enter Main corridors per floors:"
main_corridors = STDIN.gets.chomp.to_i
puts "Enter Sub corridors per floors:"
sub_corridors = STDIN.gets.chomp.to_i
hotel = HotelAutomationSolid.new(floors, main_corridors, sub_corridors).default_state
power_consumer_per_floor = FloorPowerConsume.new(main_corridors, sub_corridors).floor_power_consume
CorridorMovement.new(power_consumer_per_floor, hotel, floors, main_corridors, sub_corridors).movement_in_corridor