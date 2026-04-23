class RouteStop {
  final String isim;
  final String konum;
  final String sure;
  final String tur;
  final String ulasim;

  RouteStop({
    required this.isim,
    required this.konum,
    required this.sure,
    required this.tur,
    this.ulasim = 'driving',
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      isim: json['isim'] ?? '',
      konum: json['konum'] ?? '',
      sure: json['sure'] ?? '',
      tur: json['tur'] ?? '',
      ulasim: json['ulasim'] ?? 'driving',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isim': isim,
      'konum': konum,
      'sure': sure,
      'tur': tur,
      'ulasim': ulasim,
    };
  }
}

class RouteModel {
  final String baslik;
  final String sure;
  final String aciklama;
  final bool enIyi;
  final List<RouteStop> duraklar;

  RouteModel({
    required this.baslik,
    required this.sure,
    required this.aciklama,
    required this.enIyi,
    required this.duraklar,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      baslik: json['baslik'] ?? '',
      sure: json['sure'] ?? '',
      aciklama: json['aciklama'] ?? '',
      enIyi: json['en_iyi'] ?? false,
      duraklar: (json['duraklar'] as List<dynamic>? ?? [])
          .map((d) => RouteStop.fromJson(d))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baslik': baslik,
      'sure': sure,
      'aciklama': aciklama,
      'en_iyi': enIyi,
      'duraklar': duraklar.map((d) => d.toJson()).toList(),
    };
  }
}