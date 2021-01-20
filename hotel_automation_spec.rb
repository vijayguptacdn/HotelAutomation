require 'rspec'
require './hotel_automation'
require 'pry'


describe "Hotel Automation status" do
  it "Intial hotel status" do
    hotel_automation = HotelAutomation.new(1,1,2)
    intial_state = hotel_automation.default_state
    expect(intial_state).to eq({"floor1"=> {"main_corridors"=>[{"1"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}],
   "sub_corridors"=> [{"1"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{:consume=>10, :status=>"ON"}}},
     {"2"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{ :consume=>10, :status=>"ON"}}}]}} )
  end

  it "Per floor power consume units" do
    hotel_automation = HotelAutomation.new(1,1,2)
    floor_power_consume = hotel_automation.floor_power_consume
    expect(floor_power_consume).to eq(35)
  end


  it "movement happening on sub corridor 2" do
    hotel_automation = HotelAutomation.new(1,1,2)
    hotel_automation.floor_power_consume
    hotel_automation.default_state
    movement_state = hotel_automation.update_floor_status(1,2)
    expect(movement_state).to eq({"floor1"=> {"main_corridors"=>[{"1"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}],
   "sub_corridors"=> [{"1"=>{:light=>{:consume=>5, :status=>"OFF"}, :AC=>{:consume=>10, :status=>"OFF"}}},
     {"2"=>{:light=>{:consume=>5, :status=>"ON"}, :AC=>{:consume=>10, :status=>"ON"}}}]}})
  end
end