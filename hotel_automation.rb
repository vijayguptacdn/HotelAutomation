require 'pry'
class HotelAutomation
  MAIN_CORRIDOR_POWER_UNIT = 15
  SUB_CORRIDOR_POWER_UNIT = 10
  LIGHT_POWER_UNIT = 5
  AC_POWER_UNIT = 10
  TIME_INTERVAL = 60

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

  def floor_power_consume
    @total_power_consume_per_floor = (@main_corridors * MAIN_CORRIDOR_POWER_UNIT)+(@sub_corridors * SUB_CORRIDOR_POWER_UNIT)
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
          "consume": LIGHT_POWER_UNIT,
          "status": light_status
        },
        "AC": {
          "consume": AC_POWER_UNIT,
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

  def movement_in_corridor(any_movement)
    if any_movement == 1
      puts "Movement on floor"
      floor = STDIN.gets.chomp.to_i 
      puts "Movement on sub corridor"
      sub_corr = STDIN.gets.chomp.to_i

      update_floor_status(floor, sub_corr)
      t1 = Time.now 
      puts "Enter 1 to continue or for exit enter 0"
      movement_value = STDIN.gets.chomp.to_i
      if Time.now >= t1 + TIME_INTERVAL
        puts "No movement happen in sub corridors for more than 1 minute."
        default_state
      else 
        movement_in_corridor(movement_value)
      end 
    else
      default_state
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
      
      floor_power_consume = (@main_corridors * LIGHT_POWER_UNIT) + (@main_corridors * AC_POWER_UNIT) + (sub_light_on * LIGHT_POWER_UNIT) + (sub_ac_on * AC_POWER_UNIT)
      @hotel["floor#{floor}"]['sub_corridors'].each_with_index do |sub_corridor, index|
        sub_corridor["#{index.to_i+1}"][:AC][:status] = (floor_power_consume > @total_power_consume_per_floor ? "OFF" : "ON") if sub_corridor[sub_corr.to_s].nil?
        floor_power_consume -= AC_POWER_UNIT if sub_corridor[sub_corr.to_s].nil?
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
hotel_automation = HotelAutomation.new(floors, main_corridors, sub_corridors)

#Set the default stats of hotel floors.
hotel_automation.default_state
hotel_automation.floor_power_consume

puts "Any movement in corridor press 1 else 0" 
hotel_automation.movement_in_corridor(STDIN.gets.chomp.to_i)
