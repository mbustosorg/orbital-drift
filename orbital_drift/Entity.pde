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

class Entity implements Comparable<Entity> {
  String exchange, symbol, name, sector, industry;
    // Exchange, Key identifier, full name, sector partition, industry partition
  float longitude, latitude;
    // headquarter location

  
  Date lastTradeDate;
  float capitalization, dayChangePercentage;
  Integer volumeDay, volumeAvg;
    
  PVector position;
  PVector initPosition = new PVector(0.0, 0.0, 0.0);
    // Initial values at screen setup
  float radius;
  color fillColor;
  float colorAlpha;

  PVector UniverseCenter = new PVector(0, 0, 0); // Center of the Universe 
  PVector categoryCenter; // Center of sector sphere
  Rotation rotation; // Current rotation
  int sectorIndex = 0;
  int trailIndex = 0;
  int TrailCount = 30;

  Rotation rotationIncrement;

  Entity(String exchange, String symbol, String name, String sector, int sectorIndex, String industry, float capitalization,
         float longitude, float latitude, float x, float y, float z, Rotation initRotation, Rotation initRotationIncrement) {
    this.position = new PVector(x, y, z);
    this.exchange = exchange;
    this.symbol = symbol;
    this.name = name;
    this.sector = sector;
    this.industry = industry;
    this.longitude = longitude;
    this.latitude = latitude;
    this.capitalization = capitalization;
    this.radius = 3.0;
    this.fillColor = #00C8C8;
    this.colorAlpha = 255;
    this.sectorIndex = sectorIndex;
    this.categoryCenter = new PVector(UniverseCenter.x + EntityTransitions.ZeroMarketSize * 1.5 * cos(this.sectorIndex * PI / 5), UniverseCenter.y + EntityTransitions.ZeroMarketSize * 1.5 * sin(this.sectorIndex * PI / 5), 0.0);
    this.rotation = initRotation;
    this.rotationIncrement = initRotationIncrement;
  }

  public int compareTo(Entity other) {
    if(this.capitalization < other.capitalization) {
      return -1;
    } else if (this.capitalization > other.capitalization) {
      return 1;
    } else {
      return 0; 
    }
  }

  void screen_update() {
      //Resets initial position on screen change
    initPosition = new PVector(this.position.x, this.position.y, this.position.z);
  }

  void ticker_update(TickerData td) {
      // TODO: Trigger display animation
    if (lastTradeDate == null || lastTradeDate.before(td.lastTradeDate)) {
      this.lastTradeDate = td.lastTradeDate;
      this.capitalization = td.capitalizationB;
      this.volumeDay = td.volumeDay;
      this.volumeAvg = td.volumeAvg;
    }
  }

  void draw() {
    noStroke();
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);   
    rotateX(rotation.x);
    rotateY(rotation.y);
    rotateZ(rotation.z);
    float trail = (float(TrailCount) - float(trailIndex)) / float(TrailCount);
    fill(this.fillColor, trail * this.colorAlpha);
    ellipse(0, 0, trail * this.radius, trail * this.radius);
    popMatrix();
  }
}