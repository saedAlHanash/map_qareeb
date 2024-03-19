import 'package:google_maps_flutter/google_maps_flutter.dart';

class AtherResponse {
  AtherResponse({
    required this.imes,
  });

  final List<Ime> imes;

  factory AtherResponse.fromJson(Map<String, dynamic> json, List<String> ime) {
    return AtherResponse(
      imes: ime
          .map(
            (e) => Ime.fromJson(json[e] ?? {})..ime = e,
          )
          .toList(),
    );
  }
}

class Ime {
  Ime({
    required this.name,
    required this.dtServer,
    required this.dtTracker,
    required this.lat,
    required this.lng,
    required this.altitude,
    required this.angle,
    required this.speed,
    required this.locValid,
    required this.protocol,
    required this.netProtocol,
    required this.ip,
    required this.port,
    required this.active,
    required this.objectExpire,
    required this.objectExpireDt,
    required this.dtLastStop,
    required this.dtLastIdle,
    required this.dtLastMove,
    required this.device,
    required this.simNumber,
    required this.model,
    required this.vin,
    required this.plateNumber,
    required this.odometer,
    required this.engineHours,
    required this.params,
  });

  final Params params;
  final String name;
  final DateTime? dtServer;
  final DateTime? dtTracker;
  final double lat;
  final double lng;
  final String altitude;
  final double angle;
  final String speed;
  final String locValid;

  final String protocol;
  final String netProtocol;
  final String ip;
  final String port;
  final String active;
  final String objectExpire;
  final DateTime? objectExpireDt;
  final DateTime? dtLastStop;
  final String dtLastIdle;
  final DateTime? dtLastMove;
  final String device;
  final String simNumber;
  final String model;
  final String vin;
  final String plateNumber;
  final String odometer;
  final String engineHours;
  String ime = '';

  LatLng getLatLng() => LatLng(lat, lng);

  factory Ime.fromJson(Map<String, dynamic> json) {
    return Ime(
      name: json["name"] ?? "",
      dtServer: DateTime.tryParse(json["dt_server"] ?? ""),
      dtTracker: DateTime.tryParse(json["dt_tracker"] ?? ""),
      lat: double.parse(json["lat"] ?? '0.0'),
      lng: double.parse(json["lng"] ?? '0.0'),
      altitude: json["altitude"] ?? "",
      angle: double.parse(json["angle"] ?? '0.0'),
      speed: json["speed"] ?? "",
      locValid: json["loc_valid"] ?? "",
      protocol: json["protocol"] ?? "",
      netProtocol: json["net_protocol"] ?? "",
      ip: json["ip"] ?? "",
      port: json["port"] ?? "",
      active: json["active"] ?? "",
      objectExpire: json["object_expire"] ?? "",
      objectExpireDt: DateTime.tryParse(json["object_expire_dt"] ?? ""),
      dtLastStop: DateTime.tryParse(json["dt_last_stop"] ?? ""),
      dtLastIdle: json["dt_last_idle"] ?? "",
      dtLastMove: DateTime.tryParse(json["dt_last_move"] ?? ""),
      device: json["device"] ?? "",
      simNumber: json["sim_number"] ?? "",
      model: json["model"] ?? "",
      vin: json["vin"] ?? "",
      plateNumber: json["plate_number"] ?? "",
      odometer: json["odometer"] ?? "",
      engineHours: json["engine_hours"] ?? "",
      params: Params.fromJson(json["params"] is! Map ? {} : json["params"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        "params": params.toJson(),
        "name": name,
        "dt_server": dtServer?.toIso8601String(),
        "dt_tracker": dtTracker?.toIso8601String(),
        "lat": lat,
        "lng": lng,
        "altitude": altitude,
        "angle": angle,
        "speed": speed,
        "loc_valid": locValid,
      };
}

class Params {
  Params({
    required this.gpslev,
    required this.io239,
    required this.io240,
    required this.io80,
    required this.gsmlev,
    required this.io200,
    required this.io69,
    required this.io1,
    required this.io179,
    required this.io2,
    required this.io3,
    required this.io180,
    required this.io113,
    required this.io248,
    required this.io175,
    required this.io236,
    required this.io252,
    required this.io253,
    required this.pdop,
    required this.hdop,
    required this.io66,
    required this.io24,
    required this.io205,
    required this.io206,
    required this.io67,
    required this.io68,
    required this.io13,
    required this.io17,
    required this.io18,
    required this.io19,
    required this.io6,
    required this.io15,
    required this.io241,
    required this.io199,
    required this.io16,
    required this.io12,
    required this.io72,
    required this.io73,
    required this.io74,
    required this.io75,
    required this.io4,
    required this.io5,
    required this.io11,
    required this.io76,
    required this.io77,
    required this.io79,
    required this.io71,
    required this.io78,
    required this.io238,
    required this.io14,
    required this.io251,
    required this.io9,
    required this.io246,
    required this.io250,
    required this.io247,
    required this.io254,
    required this.io255,
    required this.io30,
    required this.io31,
    required this.io32,
    required this.io33,
    required this.io35,
    required this.io37,
    required this.io38,
    required this.io39,
    required this.io41,
    required this.io53,
    required this.io36,
    required this.io42,
    required this.io43,
    required this.io49,
    required this.io52,
    required this.io249,
    required this.pump,
    required this.track,
    required this.bats,
    required this.acc,
    required this.defense,
    required this.batl,
  });

  final String pump;
  final String track;
  final String bats;
  final String acc;
  final String defense;
  final String batl;
  final String gpslev;

  final String io239;
  final String io240;
  final String io80;
  final String gsmlev;
  final String io200;
  final String io69;
  final String io1;
  final String io179;
  final String io2;
  final String io3;
  final String io180;
  final String io113;
  final String io248;
  final String io175;
  final String io236;
  final String io252;
  final String io253;
  final String pdop;
  final String hdop;
  final String io66;
  final String io24;
  final String io205;
  final String io206;
  final String io67;
  final String io68;
  final String io13;
  final String io17;
  final String io18;
  final String io19;
  final String io6;
  final String io15;
  final String io241;
  final String io199;
  final String io16;
  final String io12;
  final String io72;
  final String io73;
  final String io74;
  final String io75;
  final String io4;
  final String io5;
  final String io11;
  final String io76;
  final String io77;
  final String io79;
  final String io71;
  final String io78;
  final String io238;
  final String io14;
  final String io251;
  final String io9;
  final String io246;
  final String io250;
  final String io247;
  final String io254;
  final String io255;
  final String io30;
  final String io31;
  final String io32;
  final String io33;
  final String io35;
  final String io37;
  final String io38;
  final String io39;
  final String io41;
  final String io53;
  final String io36;
  final String io42;
  final String io43;
  final String io49;
  final String io52;
  final String io249;

  factory Params.fromJson(Map<String, dynamic> json) {
    try {
      return Params(
        gpslev: json["gpslev"] ?? "",
        io239: json["io239"] ?? "",
        io240: json["io240"] ?? "",
        io80: json["io80"] ?? "",
        gsmlev: json["gsmlev"] ?? "",
        io200: json["io200"] ?? "",
        io69: json["io69"] ?? "",
        io1: json["io1"] ?? "",
        io179: json["io179"] ?? "",
        io2: json["io2"] ?? "",
        io3: json["io3"] ?? "",
        io180: json["io180"] ?? "",
        io113: json["io113"] ?? "",
        io248: json["io248"] ?? "",
        io175: json["io175"] ?? "",
        io236: json["io236"] ?? "",
        io252: json["io252"] ?? "",
        io253: json["io253"] ?? "",
        pdop: json["pdop"] ?? "",
        hdop: json["hdop"] ?? "",
        io66: json["io66"] ?? "",
        io24: json["io24"] ?? "",
        io205: json["io205"] ?? "",
        io206: json["io206"] ?? "",
        io67: json["io67"] ?? "",
        io68: json["io68"] ?? "",
        io13: json["io13"] ?? "",
        io17: json["io17"] ?? "",
        io18: json["io18"] ?? "",
        io19: json["io19"] ?? "",
        io6: json["io6"] ?? "",
        io15: json["io15"] ?? "",
        io241: json["io241"] ?? "",
        io199: json["io199"] ?? "",
        io16: json["io16"] ?? "",
        io12: json["io12"] ?? "",
        io72: json["io72"] ?? "",
        io73: json["io73"] ?? "",
        io74: json["io74"] ?? "",
        io75: json["io75"] ?? "",
        io4: json["io4"] ?? "",
        io5: json["io5"] ?? "",
        io11: json["io11"] ?? "",
        io76: json["io76"] ?? "",
        io77: json["io77"] ?? "",
        io79: json["io79"] ?? "",
        io71: json["io71"] ?? "",
        io78: json["io78"] ?? "",
        io238: json["io238"] ?? "",
        io14: json["io14"] ?? "",
        io251: json["io251"] ?? "",
        io9: json["io9"] ?? "",
        io246: json["io246"] ?? "",
        io250: json["io250"] ?? "",
        io247: json["io247"] ?? "",
        io254: json["io254"] ?? "",
        io255: json["io255"] ?? "",
        io30: json["io30"] ?? "",
        io31: json["io31"] ?? "",
        io32: json["io32"] ?? "",
        io33: json["io33"] ?? "",
        io35: json["io35"] ?? "",
        io37: json["io37"] ?? "",
        io38: json["io38"] ?? "",
        io39: json["io39"] ?? "",
        io41: json["io41"] ?? "",
        io53: json["io53"] ?? "",
        io36: json["io36"] ?? "",
        io42: json["io42"] ?? "",
        io43: json["io43"] ?? "",
        io49: json["io49"] ?? "",
        io52: json["io52"] ?? "",
        io249: json["io249"] ?? '',
        pump: json["pump"] ?? "",
        track: json["track"] ?? "",
        bats: json["bats"] ?? "",
        acc: json["acc"] ?? "",
        defense: json["defense"] ?? "",
        batl: json["batl"] ?? "",
      );
    } catch (e) {
      return Params.fromJson({});
    }
  }

  Map<String, dynamic> toJson() => {
        "pump": pump,
        "track": track,
        "bats": bats,
        "acc": acc,
        "defense": defense,
        "batl": batl,
        "gpslev": gpslev,
        "io239": io239,
        "io240": io240,
        "io80": io80,
        "gsmlev": gsmlev,
        "io200": io200,
        "io69": io69,
        "io1": io1,
        "io179": io179,
        "io2": io2,
        "io3": io3,
        "io180": io180,
        "io113": io113,
        "io248": io248,
        "io175": io175,
        "io236": io236,
        "io252": io252,
        "io253": io253,
        "pdop": pdop,
        "hdop": hdop,
        "io66": io66,
        "io24": io24,
        "io205": io205,
        "io206": io206,
        "io67": io67,
        "io68": io68,
        "io13": io13,
        "io17": io17,
        "io18": io18,
        "io19": io19,
        "io6": io6,
        "io15": io15,
        "io241": io241,
        "io199": io199,
        "io16": io16,
        "io12": io12,
        "io72": io72,
        "io73": io73,
        "io74": io74,
        "io75": io75,
        "io4": io4,
        "io5": io5,
        "io11": io11,
        "io76": io76,
        "io77": io77,
        "io79": io79,
        "io71": io71,
        "io78": io78,
        "io238": io238,
        "io14": io14,
        "io251": io251,
        "io9": io9,
        "io246": io246,
        "io250": io250,
        "io247": io247,
        "io254": io254,
        "io255": io255,
        "io30": io30,
        "io31": io31,
        "io32": io32,
        "io33": io33,
        "io35": io35,
        "io37": io37,
        "io38": io38,
        "io39": io39,
        "io41": io41,
        "io53": io53,
        "io36": io36,
        "io42": io42,
        "io43": io43,
        "io49": io49,
        "io52": io52,
        "io249": io249,
      };
}
