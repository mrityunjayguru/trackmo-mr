/// AC : true
/// Door : true
/// Engine : true
/// Relay : true
/// GeoFencing : true
/// Parking : true
/// Network : true
/// Charging : true
/// GPS : true

class DisplayParameters {
  DisplayParameters({
      this.ac, 
      this.door, 
      this.engine, 
      this.relay, 
      this.geoFencing, 
      this.parking, 
      this.network, 
      this.charging, 
      this.gps,});

  DisplayParameters.fromJson(dynamic json) {
    ac = json['AC'];
    door = json['Door'];
    engine = json['Engine'];
    relay = json['Relay'];
    geoFencing = json['GeoFencing'];
    parking = json['Parking'];
    network = json['Network'];
    charging = json['Charging'];
    gps = json['GPS'];
  }
  bool? ac;
  bool? door;
  bool? engine;
  bool? relay;
  bool? geoFencing;
  bool? parking;
  bool? network;
  bool? charging;
  bool? gps;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['AC'] = ac;
    map['Door'] = door;
    map['Engine'] = engine;
    map['Relay'] = relay;
    map['GeoFencing'] = geoFencing;
    map['Parking'] = parking;
    map['Network'] = network;
    map['Charging'] = charging;
    map['GPS'] = gps;
    return map;
  }

}