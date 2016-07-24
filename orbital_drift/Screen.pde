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

abstract class Screen {
  String name;
    // Title
  float duration;
    // Total millis screen will be displayed

  protected ScreenManager screen_manager;
    // Parent containing Entities, camera, and lookup tables
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
    return this.elapsed >= this.duration;
  }

  void setup(ScreenManager screen_manager) {
      // Responsible for entities, camera, and lights
    this.screen_manager = screen_manager;
  }

  abstract void update_and_draw(float delta, boolean is_paused);

  void update(float delta){
    elapsed += delta;
  }
  
  void draw() {
    for (Entity e : this.screen_manager.entities) {
      e.draw();
    }
  }

  void keyPressed() {
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