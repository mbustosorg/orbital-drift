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

class EntityLabel {
  Entity entity;
  PVector position;
  float timeElapsed = 0.0;
  boolean is_done = false;
  
  float first_growCap = 2000.0;
  float second_expandRect = first_growCap + 1000.0;
  float third_populateText = second_expandRect + 2000.0;

  float doneFadeElapsed = 0.0, doneFadeTotal = 1000.0;
  float doneFadeOut = 1.0;

  EntityLabel(Entity entity, PVector position) {
    this.entity = entity;
    this.position = position;
  }

  void setDone() {
    this.is_done = true;
    this.doneFadeElapsed = 0.0;
  }

  void draw(float delta) {
    this.timeElapsed += delta;
    
    if (this.is_done) {
      this.doneFadeElapsed += delta;
      if (this.doneFadeElapsed > this.doneFadeTotal) {
        return;
      }
      
      this.doneFadeOut = 1.0 - EntityTransitions.CUBIC_OUT.calcEasing(this.doneFadeElapsed, 0.0, 1.0, this.doneFadeTotal);
    }
    
    pushStyle();
    pushMatrix();

    hint(DISABLE_DEPTH_TEST);
    resetMatrix();
    applyMatrix(originalMatrix);
    strokeWeight(2);

    String header = String.format("%s  $%3.2f B", this.entity.name, this.entity.capitalization);
    String detailSymbolPerf = String.format("%s  %4.2f%%", this.entity.symbol, Float.isNaN(this.entity.dayChangePercentage) ? 0.0 : this.entity.dayChangePercentage);
    String detailVolume = String.format("Vol vs Avg %5.2f%%", this.entity.volumeAvg > 0.0 ? (float)(this.entity.volumeDay / this.entity.volumeAvg) : 0.0);
    String detailSector = this.entity.sector;
    String detailHQ = String.format("HQ: %4.2f,  %4.2f", this.entity.latitude, this.entity.longitude);
    
    textFont(headingFont);
    float msgWidth = textWidth(header);
    textFont(detailFont);
    msgWidth = max(new float[] {msgWidth, textWidth(detailSymbolPerf), textWidth(detailVolume), textWidth(detailSector), textWidth(detailHQ)});

    textFont(headingFont);
    int messageRows = 4;
    float fillAlphaMax = 180.0;

    translate(this.position.x, this.position.y);
    if (this.timeElapsed < first_growCap) {
      fill(9,26,80, EntityTransitions.LINEAR.calcEasing(this.timeElapsed, 0, 155, first_growCap) * this.doneFadeOut);
      stroke(140,209,146, EntityTransitions.LINEAR.calcEasing(this.timeElapsed, 0, 255, first_growCap) * this.doneFadeOut);
      rect(0, 0, msgWidth * 1.2, 48, 10, 10, 0, 0);
      line(0, 48, msgWidth * 1.2, 48);
      fill(140,209,146, EntityTransitions.LINEAR.calcEasing(this.timeElapsed, 0, 255, first_growCap) * this.doneFadeOut);
      text(String.format("%s  $%3.2f B",
          this.entity.name,
          EntityTransitions.LINEAR.calcEasing(this.timeElapsed, 0, this.entity.capitalization, first_growCap)),
          msgWidth * 0.1, 6 + textAscent());
    } else {
      fill(9,26,80, fillAlphaMax * this.doneFadeOut);
      stroke(140,209,146, 255 * this.doneFadeOut);

      float t = this.timeElapsed > second_expandRect ? second_expandRect : this.timeElapsed;
      float rounding = EntityTransitions.LINEAR.calcEasing(t - first_growCap, 0, 10, second_expandRect - first_growCap);
      rect(0, 0, msgWidth * 1.2, 48 + 32 * EntityTransitions.LINEAR.calcEasing(t - first_growCap, 0, messageRows + 0.1, second_expandRect - first_growCap), 10, 10, rounding, rounding);
      line(0, 48, msgWidth * 1.2, 48);
      fill(140,209,146, 255 * this.doneFadeOut);
      text(header, msgWidth * 0.1, 6 + textAscent());
      
      if (this.timeElapsed > second_expandRect) {
        t = this.timeElapsed > third_populateText ? third_populateText : this.timeElapsed;
        fill(209, 161, 140, EntityTransitions.LINEAR.calcEasing(t - second_expandRect, 0, 255,  third_populateText - second_expandRect) * this.doneFadeOut);
        textFont(detailFont);
        text(detailSymbolPerf, 7, 48 + textAscent());
        text(detailVolume, 7, 48 + 32 + textAscent());
        text(detailSector, 7, 48 + 32 * 2 + textAscent());
        text(detailHQ, 7, 48 + 32 * 3 + textAscent());
      }
    }

    hint(ENABLE_DEPTH_TEST);
    popMatrix();
    popStyle();
  }
}