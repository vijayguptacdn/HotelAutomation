require 'rspec'
require './hotel_automation_solid'


 DEFAULT_STATE = {"floor1"=> {"main_corridors"=>[{"1"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}],
   "sub_corridors"=> [{"1"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{:consume=>10, :status=>"ON"}}},
     {"2"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{ :consume=>10, :status=>"ON"}}}]}}

describe "Hotel Automation status" do
  it "Intial hotel status" do
    hotel_automation = HotelAutomationSolid.new(1,1,2)
    intial_state = hotel_automation.default_state
    expect(intial_state).to eq(DEFAULT_STATE)
  end
end

describe "Test per floor power consume" do 
  it "Per floor power consume units" do
    hotel_automation = FloorPowerConsume.new(1,2)
    floor_power_consume = hotel_automation.floor_power_consume
    expect(floor_power_consume).to eq(35)
  end
end

describe "Test corridor movements" do
  it "movement happening  on sub corridor 2" do
    hotel = HotelAutomationSolid.new(1,1,2).default_state
    floor_power_consume = FloorPowerConsume.new(1,2).floor_power_consume
    movement_state = CorridorMovement.new(floor_power_consume,hotel, 1,1,2).update_floor_status(1,2)
    expect(movement_state).to eq({"floor1"=> {"main_corridors"=>[{"1"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}],
   "sub_corridors"=> [{"1"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{:consume=>10, :status=>"OFF"}}},
     {"2"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}]}})
  end

  it "should say 'You have entered wrong values for floor or sub corridors'" do
    hotel = HotelAutomationSolid.new(1,1,2).default_state
    floor_power_consume = FloorPowerConsume.new(1,2).floor_power_consume
    expect do
      CorridorMovement.new(floor_power_consume,hotel, 1,1,2).update_floor_status(1,4)
    end.to output("You have entered wrong values for floor or sub corridors\n").to_stdout
  end

  it "movement happening - Enter 0 to exit" do
    hotel = HotelAutomationSolid.new(1,1,2).default_state
    floor_power_consume = FloorPowerConsume.new(1,2).floor_power_consume
    movement_state = CorridorMovement.new(floor_power_consume,hotel, 1,1,2).change_in_floor(0)   
    expect(movement_state).to eq(DEFAULT_STATE)
  end
end