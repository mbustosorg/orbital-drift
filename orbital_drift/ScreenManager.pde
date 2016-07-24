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

class ScreenManager {
  ArrayList<Entity> entities = new ArrayList<Entity>();
    // Our main items to transition between Screens

  IntDict sector_to_index = new IntDict(new Object[][] {
    { "Consumer Discretionary", 0},
    { "Consumer Staples", 1},
    { "Energy", 2},
    { "Financials", 3},
    { "Health Care", 4},
    { "Industrials", 5},
    { "Information Technology", 6},
    { "Materials", 7},
    { "Telecommunications Services", 8},
    { "Utilities", 9}
  });
    // Lookup from Sector to allow for lookups for color or partition
  color[] sector_colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};
    // established for use across screens
  ArrayList<ArrayList<Entity>> entities_by_sector = new ArrayList<ArrayList<Entity>>();
    // Entities partitioned by sector
  Camera orbitalCamera = new Camera();

  private Screen screen;
    // Active screen being displayed
  private int entity_count = 0;
    // Sets max entities to create when not 0

  private float AngleBoundary = 2.2;
  private float AngularRotationBoundary = 0.05;
  
  private boolean is_paused = false;

  ScreenManager(Screen screen) {
    this(0, screen);
  }

  ScreenManager(int entity_count, Screen screen) {
    this.entity_count = entity_count;
    this.screen = screen;
    for (int i = 0; i < this.sector_to_index.size(); i++) {
      this.entities_by_sector.add(new ArrayList<Entity>());
    }
    for (int i = 0; i < 1 / EntityTransitions.TransitioningStep - 1; i++) {
      float step = float(i) / (1.0 / EntityTransitions.TransitioningStep / 2.0);
      if (step < 1) {
        EntityTransitions.TransitionSteps[i] = step * step * step / 2.0;
      } else {
        step -= 2;
        EntityTransitions.TransitionSteps[i] = (step * step * step + 2) / 2.0;      
      }
    }
  }
  
  void keyPressed() {
    if (key == 'p') {
      this.is_paused = !this.is_paused; 
    }
    println(key, this.is_paused);
    screen.keyPressed();
  }

  void setup() {
    Table table = loadTable("../data/constituents.csv", "header");
    int i = 0;
    for (TableRow row : table.rows()) {
      Entity e = new Entity(
          row.getString("Symbol"),
          row.getString("Name"),
          row.getString("Sector"),
          this.sector_to_index.get(row.getString("Sector")),
          row.getString("Industry"),
          row.getFloat("Longitude"),
          row.getFloat("Latitude"),
          0.0, 0.0, 0.0,
          new Rotation(0.0, 0.0, 0.0), new Rotation(0.0, 0.0, 0.0)
          //new Rotation(random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary), random(-AngleBoundary, AngleBoundary)), 
          //new Rotation(0.0, 0.0, random(-AngularRotationBoundary, AngularRotationBoundary))
      );
      e.screen_update();
      this.entities.add(e);
      this.entities_by_sector.get(this.sector_to_index.get(e.sector)).add(e);
      i++;
      if (this.entity_count > 0 && i >= this.entity_count) {
        break;
      }
    }

    this.screen.setup(this);
  }

  void update(float delta) {
    this.screen.update_and_draw(delta, this.is_paused);
    textSize(12);
    fill(150);

    PVector vCameraEye = this.orbitalCamera.eye();
    println(this.orbitalCamera.eyeX, this.orbitalCamera.eyeY, this.orbitalCamera.eyeZ, vCameraEye.mag());
    PVector vTextEye = this.orbitalCamera.eye().setMag(700);
    println(vTextEye, vTextEye.mag());
    String message = String.format("Screen '%s', %.3f / %.1f", this.screen.name, this.screen.elapsed , this.screen.duration);
    float mWidth = textWidth(message);
    text(message,
      vTextEye.x - mWidth/2,
      vTextEye.y,
      vTextEye.z);
    if (this.screen.is_time_elapsed()) {
      for (Entity e : this.entities) {
        e.screen_update(); 
      }

      this.screen = this.screen.screen_next();
      this.screen.setup(this);
    }
  }
}