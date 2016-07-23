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

class Sector2d extends Screen {
  private int state_index = 0;
    // transition stage between scenes
  private float[] state_times = new float[] {12500, 2500};
    // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
    // Current time on this state
    
  private float[] entity_transition_times;
    // How long should each item spend moving

  private ArrayList<entityTransition> transitions = new ArrayList<entityTransition>();

  public Sector2d() {
    super("Sector 2d", 15000);
      // Duration = Sum of state_times
  }

  void setup(ScreenManager screen_manager) {
    super.setup(screen_manager);

    this.screens_next = new Screen[] {new PerformanceScreen()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.screen_manager.entities.size()];
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = random(this.state_times[0]);
    }

    float delay = 0.0;
    for (int i = 0; i < this.screen_manager.entities_by_sector.size(); i++) {
      transitions.add(new entityTransition(this.screen_manager.entities_by_sector.get(i), delay, 1050, this.screen_manager.sector_colors[i]));
      delay += 750;
    }
  }

  void update_and_draw(float delta) {
    // Per Industry, color all companies on a delay
    // After an industry is colored, start moving
    super.update(delta);
    ArrayList<entityTransition> toberemoved = new ArrayList<entityTransition>();
    for (entityTransition et : this.transitions) {
      et.update(delta);
      if (et.elapsed > et.delay + et.transition + 5 * et.entities.size()) {
        toberemoved.add(et);
      }
    }
    
    this.transitions.removeAll(toberemoved);
    // If you are being removed, queue up for next transition
    
    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      Entity e = this.screen_manager.entities.get(i);
      e.draw();
    }

    this.state_time += delta;
    if (this.state_time > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }
}

class entityTransition {
  ArrayList<Entity> entities;
  float delay, elapsed, transition;
  color fillColor;
  
  entityTransition (ArrayList<Entity> entities, float delay, float transition, color fillColor) {
    this.entities = entities;
    this.delay = delay;
    this.elapsed = 0;
    this.transition = transition;
    this.fillColor = fillColor;
  }
  
  void update(float delta) {
    this.elapsed += delta;
    if (this.elapsed >= this.delay) {
      for (int i = 0; i < this.entities.size(); i++) {
        Entity e = this.entities.get(i);
        if (this.elapsed  >= this.delay + 5 * i) {
          float t = (this.elapsed - this.delay) / (this.transition);
          e.fillColor = lerpColor(#000000, this.fillColor, t);
        }
      }
    }    
  }
}