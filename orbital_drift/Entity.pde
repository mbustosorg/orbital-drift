class Entity extends PVector {
  String symbol, name, sector, industry;
    // Key identifier, full name, sector partition, industry partition
  float longitude, latitude;
    // headquarter location
  float x_init, y_init;
    // Initial values at screen setup
  float capitalization, radius;
  color fillColor;//, strokeColor;

  Entity(String symbol, String name, String sector, String industry,
    float longitude, float latitude, float x, float y, float z) {
    super(x, y, z);
    this.symbol = symbol;
    this.name = name;
    this.sector = sector;
    this.industry = industry;
    this.longitude = longitude;
    this.latitude = latitude;
    this.capitalization = random(80) + 5.0;
    this.radius = 5.0;
    this.fillColor = #00C8C8;
    //this.strokeColor = #00C8C8;
  }

  void screen_update() {
    this.x_init = x;
    this.y_init = y;
  }

  void draw() {
    /*if (this.strokeColor != -16777216) {
      stroke(this.strokeColor);
    } else {
      noStroke();
    }*/
    noStroke();
    fill(this.fillColor);
    ellipse(this.x, this.y, this.radius, this.radius);
  }
}