/* //<>//

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org)
 
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

ScreenManager screen_manager = new ScreenManager(new Geography());
  // Handles change over of screens and entities
float draw_last_millis;
  // Determine delta between frames

void setup() {
  size(1000, 1000, P3D);
  screen_manager.setup();
  draw_last_millis = millis();
}

void draw() {
  background(0);
  lights();
  float draw_millis = millis();
  screen_manager.update(draw_millis - draw_last_millis);
  textSize(32);
  fill(150);
  text(
    String.format("Screen '%s', %.3f / %.1f", screen_manager.screen.name, screen_manager.screen.elapsed / 1000, screen_manager.screen.duration),
    width * 0.25,
    height * 0.95);
  draw_last_millis = draw_millis;
}

/* */
class Point {
  float x, y, z;
    // 3 dimensional space

  Point(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Entity extends Point {
  String symbol, name, sector, industry;
    // Key identifier, full name, sector partition, industry partition
  float longitude, latitude;
    // headquarter location
  float x_init, y_init;
    // Initial values at screen setup
  float capitalization, radius;

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
  }

  void screen_update() {
    this.x_init = x;
    this.y_init = y;
  }

  void draw() {
    ellipse(this.x, this.y, this.radius, this.radius);
  }
}

/* Abstract */
abstract class Screen {
  String name;
    // Title
  float duration;
    // Total seconds screen will be displayed

  protected ArrayList<Entity> entities;
    // Our main items to transition between Screens
  float elapsed = 0;
    // Seconds screen has been displayed
  protected Screen[] screens_next;
    // Screens that are next
  protected int[] screens_chance;
    // Chance for transition to be selected, sum to 100

  Screen(String name, float duration) {
    this.name = name;
    this.duration = duration;
  }

  boolean is_time_elapsed() {
    return this.elapsed / 1000 >= this.duration;
  }

  void setup(ArrayList<Entity> entities) {
    this.entities = entities; 
  }

  abstract void update_and_draw(float delta);
  
  void update(float delta){
    elapsed += delta;
  }
  
  void draw() {
    for (Entity e : this.entities) {
      e.draw();
    }
  }

  void teardown() {
  }

  Screen screen_next() {
     float chance = random(100);
     int chance_total = 0;
     for (int i = 0; i < screens_chance.length; i++) {
       int c = screens_chance[i];
       if (chance > chance_total && chance < chance_total + c) {
         return screens_next[i];
       }

       chance_total += c;
     }

     return null;
  }
}

/* Concrete */
class Geography extends Screen {
  private int state_index = 0;
    // transition stage between scenes
  private float[] state_times = new float[] {7.5, 2.5, 5, 2.5};
    // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
    // Current time on this state
    
  private float[] entity_transition_times;
    // How long should each item spend moving
    
  public Geography() {
    super("Geography", 17.5);
      // Duration = Sum of state_times
  }

  void setup(ArrayList<Entity> entities) {
    super.setup(entities);
    this.screens_next = new Screen[] {new Geography()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(this.state_times[0]);
    }
  }

  void update_and_draw(float delta) {
    super.update(delta);
    noFill();
    stroke(0, 200, 200);
    for (int i = 0; i < this.entities.size(); i++) {
      Entity e = this.entities.get(i);
      if (this.state_index == 0) {
        // MOVE
        float x = 0;
        if (e.longitude < -60) {
          x = map(e.longitude, -124, -60, 0, width * 0.65);
        } else {
          x = map(e.longitude, -20, 9, width * 0.75, width);
        }
    
        // leave 10% x for the ocean, remove the rest
        float y = map(e.latitude, 54, 12, 0, height);
        EntityTransitions.linear_interpolation_2d(e, x, y, this.entity_transition_times[i], this.state_time);
      } else if (this.state_index == 2) {
        // Grow
        e.radius = 5.0 + (e.capitalization - 5.0) * this.state_time / 1000 / this.state_times[this.state_index];
      } else if (this.state_index == 3) {
        // Fade out
        stroke(0, 200, 200, 255 - 255 * this.state_time / 1000 / this.state_times[this.state_index]);
      }

      e.draw();
    }

    this.state_time += delta;
    if (this.state_time / 1000 > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }

  void teardown() {
      // Sloppy reset for looping demo
    for (Entity e : this.entities) {
      e.radius = 5.0;
      e.x = 0;
      e.y = 0;
    }
  }
}

static class EntityTransitions {
  static void linear_interpolation_2d(Entity e, float x_end, float y_end, float transition_time, float elapsed) {
    if (elapsed / 1000 >= transition_time) {
      e.x = x_end;
      e.y = y_end;
    } else {
      e.x = e.x_init + (x_end - e.x_init) * (elapsed / 1000 / transition_time);
      e.y = e.y_init + (y_end- e.y_init) * (elapsed / 1000 / transition_time);
    }
  }

}

class ScreenManager {
  Screen screen;
    // Active screen being displayed
  int entity_count = 0;
    // Sets max entities to create

  private ArrayList<Entity> entities = new ArrayList<Entity>();
    // Our main items to transition between Screens

  ScreenManager(Screen screen) {
    this.screen = screen;
  }

  ScreenManager(int entity_count, Screen screen) {
    this.entity_count = entity_count;
    this.screen = screen;
  }

  void setup() {
    Table table = loadTable("../../data/constituents.csv", "header");
    int i = 0;
    for (TableRow row : table.rows()) {
      float x = random(200);
      x = x < 100 ? x * -1 : x - 100 + width;
      //TODO: too far reaching - display should be passed in
      float y = random(200);
      y = y < 100 ? y * -1 : y - 100 + height;
        // Place entities outside of the display
      
      this.entities.add(new Entity(
        row.getString("Symbol"),
        row.getString("Name"),
        row.getString("Sector"),
        row.getString("Industry"),
        row.getFloat("Longitude"),
        row.getFloat("Latitude"),
        //x, y, 0.0
        0.0, 0.0, 0.0
      ));
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
      this.screen.teardown();
      this.entities = this.screen.entities;
      for (Entity e : this.entities) {
        e.screen_update(); 
      }
      this.screen = this.screen.screen_next();
      this.screen.setup(this.entities);
    }
  }
}