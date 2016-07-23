/*

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org), Matthew Yeager
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
*/

class Entity extends PVector {
  String symbol, name, sector, industry;
    // Key identifier, full name, sector partition, industry partition
  float longitude, latitude;
    // headquarter location
  PVector initPosition = new PVector(0.0, 0.0, 0.0);
    // Initial values at screen setup
  float capitalization, radius;
  color fillColor;//, strokeColor;

  PVector UniverseCenter = new PVector(0, 0, 0); // Center of the Universe 
  PVector categoryCenter; // Center of sector sphere
  Rotation rotation; // Current rotation
  float ZeroMarketSize = 200; // Radius of the nominal universe
  int sectorIndex = 0;
  int trailIndex = 0;
  int TrailCount = 30;

  Rotation rotationIncrement;

  Entity(String symbol, String name, String sector, int sectorIndex, String industry,
         float longitude, float latitude, float x, float y, float z, Rotation initRotation, Rotation initRotationIncrement) {
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
    this.sectorIndex = sectorIndex;
    this.categoryCenter = new PVector(UniverseCenter.x + ZeroMarketSize * 1.5 * cos(this.sectorIndex * PI / 5), UniverseCenter.y + ZeroMarketSize * 1.5 * sin(this.sectorIndex * PI / 5), 0.0);
    this.rotation = initRotation;
    this.rotationIncrement = initRotationIncrement;
    //this.strokeColor = #00C8C8;
  }

  void screen_update() {
    initPosition = new PVector(x, y, z);
  }

  void draw() {
    /*if (this.strokeColor != -16777216) {
      stroke(this.strokeColor);
    } else {
      noStroke();
    }*/
    noStroke();
    pushMatrix();
    translate(x, y, z);   
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    float trail = (float(TrailCount) - float(trailIndex)) / float(TrailCount);
    fill(this.fillColor, trail * 255.0);
    ellipse(0, 0, trail * this.radius, trail * this.radius);
    ellipse(0, 0, this.radius, this.radius);
    popMatrix();
  }
}