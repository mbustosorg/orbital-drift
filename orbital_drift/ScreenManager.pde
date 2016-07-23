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
  Screen screen;
    // Active screen being displayed
  int entity_count = 0;
    // Sets max entities to create
  private float AngleBoundary = 2.2;
  private float AngularRotationBoundary = 0.05;

  private ArrayList<Entity> entities = new ArrayList<Entity>();
    // Our main items to transition between Screens

  ScreenManager(Screen screen) {
    this.screen = screen;
  }

  ScreenManager(int entity_count, Screen screen) {
    this.entity_count = entity_count;
    this.screen = screen;
  }
  
  void keyPressed() {
    screen.keyPressed();
  }

  void setup() {
    Table table = loadTable("../data/constituents.csv", "header");
    int i = 0;
    IntDict sectorIndexDict = new IntDict();
    int sectorIndex = 0;
    for (TableRow row : table.rows()) {
      float x = random(200);
      x = x < 100 ? x * -1 : x - 100 + width;
      //TODO: too far reaching - display should be passed in
      float y = random(200);
      y = y < 100 ? y * -1 : y - 100 + height;
        // Place entities outside of the display
      if (!sectorIndexDict.hasKey(row.getString("Sector"))) sectorIndexDict.set(row.getString("Sector"), sectorIndexDict.size());
      this.entities.add(new Entity(
                                  row.getString("Symbol"),
                                  row.getString("Name"),
                                  row.getString("Sector"),
                                  sectorIndexDict.get(row.getString("Sector")),
                                  row.getString("Industry"),
                                  row.getFloat("Longitude"),
                                  row.getFloat("Latitude"),
                                  //x, y, 0.0
                                  0.0, 0.0, 0.0, new Rotation(0.0, 0.0, 0.0), new Rotation(0.0, 0.0, 0.0)));
      this.entities.get(i).screen_update();
      i++;
      if (this.entity_count > 0 && i >= this.entity_count) {
        break;
      }
    }

    this.screen.setup(entities);
  }

  void update(float delta) {
    this.screen.update_and_draw(delta);
    if (this.screen.is_time_elapsed()) {
      //this.screen.teardown();
      this.entities = this.screen.entities;
      for (Entity e : this.entities) {
        e.screen_update(); 
      }
      this.screen = this.screen.screen_next();
      this.screen.setup(this.entities);
    }
  }
}