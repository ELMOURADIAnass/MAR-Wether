// Approximate "inside Morocco" check for GPS positions.
//
// The polygon below is a coarse border outline (mainland + Southern
// Provinces, sea excluded where practical). It is intentionally
// approximate: it only decides whether to show a "nearest Moroccan
// city" or an "Outside Morocco" notice — never for anything legal or
// navigational. Points are (latitude, longitude).
const List<(double, double)> _moroccoPolygon = <(double, double)>[
  (35.92, -5.36), // Tangier strait
  (35.82, -2.19), // Saïdia / Med coast
  (34.65, -1.70), // eastern border, north
  (33.00, -1.50), // eastern border
  (31.30, -2.70), // south-east
  (29.50, -5.50), // south-east step
  (27.67, -8.67), // Smara region
  (26.00, -10.50), // southern border
  (24.00, -13.50), // southern border
  (21.50, -16.50), // Guerguerat approach
  (20.77, -17.05), // southern tip
  (31.00, -17.50), // Atlantic offset (sea, keeps coast inside)
  (35.60, -7.50), // Atlantic offset north
];

/// Ray-casting point-in-polygon test against [_moroccoPolygon].
bool isInsideMorocco(double lat, double lon) {
  bool inside = false;
  for (int i = 0, j = _moroccoPolygon.length - 1;
      i < _moroccoPolygon.length;
      j = i++) {
    final (double, double) a = _moroccoPolygon[i];
    final (double, double) b = _moroccoPolygon[j];
    final bool crosses =
        (a.$2 > lon) != (b.$2 > lon) &&
        lat < (b.$1 - a.$1) * (lon - a.$2) / (b.$2 - a.$2) + a.$1;
    if (crosses) {
      inside = !inside;
    }
  }
  return inside;
}
